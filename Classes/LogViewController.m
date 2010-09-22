//
//  LogViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "EWDBMonth.h"
#import "EWDatabase.h"
#import "EWDate.h"
#import "LogDatePickerController.h"
#import "LogEntryViewController.h"
#import "LogInfoPickerController.h"
#import "LogTableViewCell.h"
#import "LogViewController.h"


static NSString * const kBadgeValueNoDataToday = @"!";
static NSString	* const kCellFlashAnimationID = @"LogCellFlash";


@interface LogViewController ()
- (void)databaseDidChange:(NSNotification *)notice;
@end


@implementation LogViewController


@synthesize database;
@synthesize tableView;
@synthesize infoPickerController;
@synthesize datePickerController;


- (void)awakeFromNib {
	[super awakeFromNib];
	sectionTitleFormatter = [[NSDateFormatter alloc] init];
	sectionTitleFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
	sectionTitleFormatter.dateFormat = NSLocalizedString(@"MMMM y", @"Month Year date format");
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(databaseDidChange:) 
												 name:EWDatabaseDidChangeNotification 
											   object:nil];
	[self databaseDidChange:nil];
}


- (void)setButton:(UIButton *)button backgroundImageNamed:(NSString *)name forState:(UIControlState)state {
	UIImage *base = [UIImage imageNamed:name];
	UIImage *image = [base stretchableImageWithLeftCapWidth:5 topCapHeight:6];
	[button setBackgroundImage:image forState:state];
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[database release];
	[tableView release];
	[infoPickerController release];
	[lastIndexPath release];
	[sectionTitleFormatter release];
	[super dealloc];
}


- (void)databaseDidChange:(NSNotification *)notice {
	EWMonthDay today = EWMonthDayToday();

	if ([database hasDataForToday]) {
		self.tabBarItem.badgeValue = nil;
	} else {
		self.tabBarItem.badgeValue = kBadgeValueNoDataToday;
	}
	
	if ((database.earliestMonth != earliestMonth) || (latestMonth == 0)) {
		earliestMonth = database.earliestMonth;
		latestMonth = MAX(database.latestMonth, EWMonthDayGetMonth(today));

		NSUInteger row, section;
		section = latestMonth - earliestMonth;
		if (latestMonth == EWMonthDayGetMonth(today)) {
			row = EWMonthDayGetDay(today) - 1;
		} else {
			row = EWDaysInMonth(latestMonth) - 1;
		}
		[lastIndexPath release];
		lastIndexPath = [[NSIndexPath indexPathForRow:row inSection:section] retain];
		
		[tableView reloadData];
	}
}


- (EWMonth)monthForSection:(NSInteger)section {
	return earliestMonth + section;
}


- (NSIndexPath *)indexPathForMonthDay:(EWMonthDay)monthday {
	EWMonth month = EWMonthDayGetMonth(monthday);
	EWDay day = EWMonthDayGetDay(monthday);
	NSUInteger section = MIN((month - earliestMonth), [self numberOfSectionsInTableView:tableView] - 1);
	NSUInteger row = MIN(day, (NSUInteger)[self tableView:tableView numberOfRowsInSection:section]) - 1;
	return [NSIndexPath indexPathForRow:row inSection:section];
}


- (EWMonthDay)monthDayForIndexPath:(NSIndexPath *)indexPath {
	return EWMonthDayMake([self monthForSection:indexPath.section], 
						  indexPath.row + 1);
}


- (NSIndexPath *)indexPathForMiddle {
	NSArray *indexPathArray = [tableView indexPathsForVisibleRows];
	if ([indexPathArray count] > 0) {
		NSUInteger middleIndex = [indexPathArray count] / 2;
		return [indexPathArray objectAtIndex:middleIndex];
	} else {
		return nil;
	}
}


- (NSDate *)currentDate {
	NSIndexPath	*indexPath = [self indexPathForMiddle];
	return EWDateFromMonthAndDay([self monthForSection:indexPath.section], 
								 indexPath.row + 1);
}


- (void)deselectSelectedRow {
	NSIndexPath *tableSelection = [tableView indexPathForSelectedRow];
	if (tableSelection) {
		[tableView deselectRowAtIndexPath:tableSelection animated:YES];
	}
}


- (void)flashAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if ([kCellFlashAnimationID isEqualToString:animationID]) {
		UITableViewCell *cell = (UITableViewCell *)context;
		[cell setHighlighted:NO animated:YES];
		[cell release];
	}
}


// Called by the date picker popup
- (void)scrollToDate:(NSDate *)date {
	EWMonthDay md = EWMonthDayFromDate(date);
	if (earliestMonth > EWMonthDayGetMonth(md)) {
		[database getDBMonth:EWMonthDayGetMonth(md)];
		[self databaseDidChange:nil];
	}
	
	/* We want to flash the row that the user picked. In most cases, we will
	 call selectRowAtIndexPath: to take care of the scrolling and the
	 highlighting, and undo the change in scrollViewDidEndScrollingAnimation:.
	 However, if the table does not scroll (because the user picked a date in 
	 the middle of the view), the delegate method will not be called, and the
	 cell will remain highlighted. To avoid this problem, we animate the 
	 highlight ourselves in this situation.
	 */

	NSIndexPath *middlePath = [self indexPathForMiddle];
	NSIndexPath *targetPath = [self indexPathForMonthDay:md];
	
	if ([targetPath isEqual:middlePath]) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:targetPath];
		[UIView beginAnimations:kCellFlashAnimationID context:[cell retain]];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(flashAnimationDidStop:finished:context:)];
		[cell setHighlighted:YES];
		[UIView commitAnimations];
	} else {
		[tableView selectRowAtIndexPath:targetPath 
							   animated:YES
						 scrollPosition:UITableViewScrollPositionMiddle];
	}
}
													  

#pragma mark UIScrollViewDelegate


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	// Deselect in response to a scrollToDate: selection.
	[self deselectSelectedRow];
}


#pragma mark UIViewController


- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
								  UIViewAutoresizingFlexibleHeight);
	
	UIButton *button = infoPickerController.infoTypeButton;
	[self setButton:button backgroundImageNamed:@"NavButton0" 
		   forState:UIControlStateNormal];
	[self setButton:button backgroundImageNamed:@"NavButton1" 
		   forState:UIControlStateHighlighted];
	
	[infoPickerController setSuperview:self.tabBarController.view];
	[datePickerController setSuperview:self.tabBarController.view];

	scrollDestination = EWMonthDayToday();
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (scrollDestination != 0) {
		// If we do this in viewWillAppear:, we are sometimes off by 20px,
		// because the view is resized between 'WillAppear and 'DidAppear:.
		[tableView reloadData];
		NSIndexPath *path = [self indexPathForMonthDay:scrollDestination];
		[tableView scrollToRowAtIndexPath:path
						 atScrollPosition:UITableViewScrollPositionBottom
								 animated:NO];
		scrollDestination = 0;
	}
	[self deselectSelectedRow];
}


#pragma mark Tab Bar Double Tap


- (void)tabBarItemDoubleTapped {
	[tableView scrollToRowAtIndexPath:lastIndexPath 
					 atScrollPosition:UITableViewScrollPositionBottom
							 animated:YES];
}


#pragma mark UITableViewDataSource (Required)


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (latestMonth - earliestMonth + 1);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ((NSUInteger)section == [lastIndexPath section]) {
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
		cell.tableView = self.tableView;
	}
	
	EWDBMonth *monthData = [database getDBMonth:[self monthForSection:indexPath.section]];
	EWDay day = 1 + indexPath.row;
	[cell updateWithMonthData:monthData day:day];
	
	return cell;
}


#pragma mark UITableViewDelegate (Optional)


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	EWMonth month = [self monthForSection:indexPath.section];
	EWDBMonth *monthData = [database getDBMonth:month];
	EWDay day = 1 + indexPath.row;
	LogEntryViewController *controller = [LogEntryViewController sharedController];
	[controller configureForDay:day dbMonth:monthData];
	[self presentModalViewController:controller animated:YES];
}


@end
