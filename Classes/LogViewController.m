//
//  LogViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "LogViewController.h"
#import "LogEntryViewController.h"
#import "Database.h"
#import "EWDate.h"
#import "MonthData.h"
#import "LogTableViewCell.h"
#import "GoToDateViewController.h"
#import "EWGoal.h"


@interface LogViewController ()
- (void)databaseDidChange:(NSNotification *)notice;
@end


EWMonthDay gCurrentMonthDay = 0; // for sync with chart


@implementation LogViewController

+ (void)setCurrentMonthDay:(EWMonthDay)monthday {
	gCurrentMonthDay = monthday;
}


+ (EWMonthDay)currentMonthDay {
	return gCurrentMonthDay;
}


- (id)init {
	if (self = [super initWithNibName:@"LogViewController" bundle:nil]) {
		self.title = NSLocalizedString(@"LOG_VIEW_TITLE", nil);
		self.tabBarItem.image = [UIImage imageNamed:@"TabIconLog.png"];
		scrollDestination = EWMonthDayFromDate([NSDate date]);

		sectionTitleFormatter = [[NSDateFormatter alloc] init];
		sectionTitleFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
		sectionTitleFormatter.dateFormat = NSLocalizedString(@"MONTH_YEAR_DATE_FORMAT", nil);
	}
	return self;
}


- (void)startObservingDatabase {
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(databaseDidChange:) 
												 name:EWDatabaseDidChangeNotification 
											   object:nil];
	[self databaseDidChange:nil];
}


- (void)stopObservingDatabase {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)databaseDidChange:(NSNotification *)notice {
	EWMonthDay today = EWMonthDayFromDate([NSDate date]);
	Database *db = [Database sharedDatabase];
	
	earliestMonth = db.earliestMonth;
	latestMonth = MAX(db.latestMonth, EWMonthDayGetMonth(today));

	NSUInteger row, section;
	section = latestMonth - earliestMonth;
	if (latestMonth == EWMonthDayGetMonth(today)) {
		row = EWMonthDayGetDay(today) - 1;
	} else {
		row = EWDaysInMonth(latestMonth) - 1;
	}
	[lastIndexPath release];
	lastIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
	[lastIndexPath retain];
	
	[tableView reloadData];
}


- (EWMonth)monthForSection:(NSInteger)section {
	return earliestMonth + section;
}


- (NSIndexPath *)indexPathForMonthDay:(EWMonthDay)monthday {
	NSInteger section = MIN((EWMonthDayGetMonth(monthday) - earliestMonth), 
							[self numberOfSectionsInTableView:tableView] - 1);
	NSInteger row = MIN((EWMonthDayGetDay(monthday) - 1), 
						[self tableView:tableView numberOfRowsInSection:section] - 1);
	return [NSIndexPath indexPathForRow:row inSection:section];
}


- (EWMonthDay)monthDayForIndexPath:(NSIndexPath *)indexPath {
	return EWMonthDayMake([self monthForSection:indexPath.section], 
						  indexPath.row + 1);
}


- (NSDate *)currentDate {
	NSArray *indexPathArray = [tableView indexPathsForVisibleRows];
	NSUInteger middleIndex = [indexPathArray count] / 2;
	NSIndexPath *indexPath = [indexPathArray objectAtIndex:middleIndex];
	return EWDateFromMonthAndDay([self monthForSection:[indexPath section]], 
								 [indexPath row] + 1);
}


- (void)viewWillAppear:(BOOL)animated {
	[self startObservingDatabase];
	
	[auxControl setEnabled:[EWGoal isBMIEnabled] forSegmentAtIndex:kBMIAuxiliaryInfoType];
	
	NSIndexPath *tableSelection = [tableView indexPathForSelectedRow];
	if (tableSelection) {
		[tableView deselectRowAtIndexPath:tableSelection animated:NO];
	}

	if (scrollDestination != 0) {
		[tableView scrollToRowAtIndexPath:[self indexPathForMonthDay:scrollDestination]
						 atScrollPosition:UITableViewScrollPositionMiddle
								 animated:animated];
		scrollDestination = 0;
	} else {
		EWMonthDay md = [LogViewController currentMonthDay];
		[tableView scrollToRowAtIndexPath:[self indexPathForMonthDay:md]
						 atScrollPosition:UITableViewScrollPositionBottom
								 animated:animated];
	}
}


- (UIView *)findSubviewOfView:(UIView *)parent ofClass:(Class)viewClass {
	for (UIView *subview in [parent subviews]) {
		if ([subview isKindOfClass:viewClass]) {
			return subview;
		} else {
			UIView *subsubview = [self findSubviewOfView:subview ofClass:viewClass];
			if (subsubview) return subsubview;
		}
	}
	return nil;
}


- (void)viewWillDisappear:(BOOL)animated {
	[self stopObservingDatabase];
	NSIndexPath *path = [[tableView indexPathsForVisibleRows] lastObject];
	EWMonthDay md = [self monthDayForIndexPath:path];
	[LogViewController setCurrentMonthDay:md];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
	[lastIndexPath release];
	[sectionTitleFormatter release];
	[super dealloc];
}


- (IBAction)goToDateAction {
	GoToDateViewController *viewController = [[GoToDateViewController alloc] initWithDate:self.currentDate];
	viewController.target = self;
	viewController.action = @selector(scrollToDate:);
	[self presentModalViewController:[viewController autorelease] animated:YES];
}


- (void)scrollToDate:(NSDate *)date {
	scrollDestination = EWMonthDayFromDate(date);
	if (earliestMonth > EWMonthDayGetMonth(scrollDestination)) {
		[[Database sharedDatabase] dataForMonth:EWMonthDayGetMonth(scrollDestination)];
		[self databaseDidChange:nil];
	}
}


- (IBAction)auxControlAction {
	[LogTableViewCell setAuxiliaryInfoType:auxControl.selectedSegmentIndex];
	for (UITableViewCell *cell in [tableView visibleCells]) {
		UIView *contentView = [[cell.contentView subviews] lastObject];
		[contentView setNeedsDisplay];
	}
}


#pragma mark UITableViewDataSource (Required)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return latestMonth - earliestMonth + 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == [lastIndexPath section]) {
		return [lastIndexPath row] + 1;
	} else {
		EWMonth month = [self monthForSection:section];
		return EWDaysInMonth(month);
	}
}


#pragma mark UITableViewDataSource (Optional)

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	EWMonth month = [self monthForSection:section];
	NSDate *theDate = EWDateFromMonthAndDay(month, 1);
	return [sectionTitleFormatter stringFromDate:theDate];
}


#pragma mark UITableViewDelegate (Required)

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	LogTableViewCell *cell = nil;
	
	id availableCell = [tableView dequeueReusableCellWithIdentifier:kLogCellReuseIdentifier];
	if (availableCell != nil) {
		cell = (LogTableViewCell *)availableCell;
	} else {
		cell = [[[LogTableViewCell alloc] init] autorelease];
	}
	
	MonthData *monthData = [[Database sharedDatabase] dataForMonth:[self monthForSection:[indexPath section]]];
	EWDay day = 1 + [indexPath row];
	[cell updateWithMonthData:monthData day:day];
	
	return cell;
}


#pragma mark UITableViewDelegate (Optional)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	EWMonth month = [self monthForSection:[indexPath section]];
	MonthData *monthData = [[Database sharedDatabase] dataForMonth:month];
	EWDay day = 1 + [indexPath row];
	LogEntryViewController *controller = [LogEntryViewController sharedController];
	controller.monthData = monthData;
	controller.day = day;
	controller.weighIn = NO;
	[self presentModalViewController:controller animated:YES];
}

@end
