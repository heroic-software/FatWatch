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


static EWMonthDay gCurrentMonthDay = 0; // for sync with chart


@implementation LogViewController


+ (void)setCurrentMonthDay:(EWMonthDay)monthday {
	gCurrentMonthDay = monthday;
}


+ (EWMonthDay)currentMonthDay {
	return gCurrentMonthDay;
}


@synthesize tableView;
@synthesize auxControl;


- (id)init {
	if (self = [super initWithNibName:@"LogViewController" bundle:nil]) {
		self.title = NSLocalizedString(@"LOG_VIEW_TITLE", nil);
		self.tabBarItem.image = [UIImage imageNamed:@"TabIconLog.png"];
		scrollDestination = EWMonthDayToday();

		sectionTitleFormatter = [[NSDateFormatter alloc] init];
		sectionTitleFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
		sectionTitleFormatter.dateFormat = NSLocalizedString(@"MONTH_YEAR_DATE_FORMAT", nil);
	}
	return self;
}


- (void)dealloc {
	[tableView release];
	[auxControl release];
	[lastIndexPath release];
	[sectionTitleFormatter release];
	[super dealloc];
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
	EWMonthDay today = EWMonthDayToday();
	Database *db = [Database sharedDatabase];
	
	earliestMonth = db.earliestMonth;
	latestMonth = MAX(db.latestMonth, EWMonthDayGetMonth(today));

	NSUInteger row, section;
	section = latestMonth - earliestMonth + 1;
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
	return earliestMonth + (section - 1);
}


- (NSIndexPath *)indexPathForMonthDay:(EWMonthDay)monthday {
	NSInteger section = 1 + MIN((EWMonthDayGetMonth(monthday) - earliestMonth), 
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
	return EWDateFromMonthAndDay([self monthForSection:indexPath.section], 
								 indexPath.row + 1);
}


- (void)viewWillAppear:(BOOL)animated {
	[self startObservingDatabase];
	
	[auxControl setEnabled:[EWGoal isBMIEnabled] forSegmentAtIndex:kBMIAuxiliaryInfoType];
	
	if (scrollDestination != 0) {
		[tableView scrollToRowAtIndexPath:[self indexPathForMonthDay:scrollDestination]
						 atScrollPosition:UITableViewScrollPositionMiddle
								 animated:animated];
		scrollDestination = 0;
	}
}


- (void)viewDidAppear:(BOOL)animated {
	NSIndexPath *tableSelection = [tableView indexPathForSelectedRow];
	if (tableSelection) {
		[tableView deselectRowAtIndexPath:tableSelection animated:animated];
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
	NSArray *visibleRows = [tableView indexPathsForVisibleRows];
	if ([visibleRows count] > 0) {
		NSIndexPath *path = [visibleRows objectAtIndex:0];
		EWMonthDay md = [self monthDayForIndexPath:path];
		[LogViewController setCurrentMonthDay:md];
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)goToDateAction {
	GoToDateViewController *viewController = [[GoToDateViewController alloc] initWithDate:self.currentDate];
	viewController.target = self;
	viewController.action = @selector(scrollToDate:);
	[self presentModalViewController:viewController animated:YES];
	[viewController release];
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
		[[cell viewWithTag:kLogContentViewTag] setNeedsDisplay];
	}
}


#pragma mark UITableViewDataSource (Required)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1 + (latestMonth - earliestMonth + 1);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1;
	} else if (section == [lastIndexPath section]) {
		return [lastIndexPath row] + 1;
	} else {
		EWMonth month = [self monthForSection:section];
		return EWDaysInMonth(month);
	}
}


#pragma mark UITableViewDataSource (Optional)

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) return nil;
	EWMonth month = [self monthForSection:section];
	NSDate *theDate = EWDateFromMonthAndDay(month, 1);
	return [sectionTitleFormatter stringFromDate:theDate];
}


#pragma mark UITableViewDelegate (Required)

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		UITableViewCell *helpCell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
		helpCell.selectionStyle = UITableViewCellSelectionStyleNone;

		UILabel *helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		helpLabel.text = NSLocalizedString(@"LOG_HELP_CELL", nil);
		helpLabel.textColor = [UIColor darkGrayColor];
		helpLabel.textAlignment = UITextAlignmentCenter;
		helpLabel.adjustsFontSizeToFitWidth = YES;
		[helpCell.contentView addSubview:helpLabel];
		[helpLabel release];
		
		return [helpCell autorelease];
	}
	
	LogTableViewCell *cell = nil;
	
	id availableCell = [tableView dequeueReusableCellWithIdentifier:kLogCellReuseIdentifier];
	if (availableCell != nil) {
		cell = (LogTableViewCell *)availableCell;
	} else {
		cell = [[[LogTableViewCell alloc] init] autorelease];
	}
	
	MonthData *monthData = [[Database sharedDatabase] dataForMonth:[self monthForSection:indexPath.section]];
	EWDay day = 1 + indexPath.row;
	[cell updateWithMonthData:monthData day:day];
	
	return cell;
}


#pragma mark UITableViewDelegate (Optional)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) return;
	
	EWMonth month = [self monthForSection:indexPath.section];
	MonthData *monthData = [[Database sharedDatabase] dataForMonth:month];
	EWDay day = 1 + indexPath.row;
	LogEntryViewController *controller = [LogEntryViewController sharedController];
	controller.monthData = monthData;
	controller.day = day;
	controller.weighIn = NO;
	[self presentModalViewController:controller animated:YES];
}


@end
