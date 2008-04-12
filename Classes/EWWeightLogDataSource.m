//
//  EWWeightLogDataSource.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/15/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "EWWeightLogDataSource.h"
#import "LogTableViewCell.h"
#import "LogViewController.h"
#import "LogEntryViewController.h"
#import "MonthData.h"
#import "Database.h"

@implementation EWWeightLogDataSource

@synthesize viewController;

- (id)initWithDatabase:(Database *)db {
	if ([super init]) {
		database = [db retain];

		sectionTitleFormatter = [[NSDateFormatter alloc] init];
		sectionTitleFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
		sectionTitleFormatter.dateFormat = @"MMMM yyyy";
		
		EWMonth earliestMonth = [database earliestMonth];
		EWMonth currentMonth = EWMonthFromDate([NSDate date]);
		NSLog(@"Months from %d to %d", earliestMonth, currentMonth);
		
		numberOfSections = MAX(1, currentMonth - earliestMonth + 1);
		
		NSDateComponents *components;
		
		components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit 
													 fromDate:[NSDate date]];
		lastIndexPath = [NSIndexPath indexPathForRow:(components.day - 1)
										   inSection:(numberOfSections - 1)];
		[lastIndexPath retain];
	}
	return self;
}

- (void)dealloc {
	[lastIndexPath release];
	[sectionTitleFormatter release];
	[database release];
	[super dealloc];
}

- (NSIndexPath *)lastIndexPath
{
	return lastIndexPath;
}

- (EWMonth)monthForSection:(NSInteger)section
{
	return [database earliestMonth] + section;
}

#pragma mark UITableViewDataSource (Required)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == numberOfSections - 1) {
		return [lastIndexPath row] + 1;
	} else {
		EWMonth month = [self monthForSection:section];
		return EWDaysInMonth(month);
	}
}

#pragma mark UITableViewDataSource (Optional)

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	EWMonth month = [self monthForSection:section];
	NSDate *theDate = NSDateFromEWMonthAndDay(month, 1);
	return [sectionTitleFormatter stringFromDate:theDate];
}

#pragma mark UITableViewDelegate (Required)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	LogTableViewCell *cell = nil;
	
	id availableCell = [tableView dequeueReusableCellWithIdentifier:@"LogCell"];
	if (availableCell != nil) {
		cell = (LogTableViewCell *)availableCell;
	} else {
		cell = [[[LogTableViewCell alloc] init] autorelease];
	}
		
	MonthData *monthData = [database dataForMonth:[self monthForSection:[indexPath section]]];
	
	EWDay day = 1 + [indexPath row];
	
	cell.day = day;
	cell.measuredWeight = [monthData measuredWeightOnDay:day];
	cell.trendWeight = [monthData trendWeightOnDay:day];
	cell.flagged = [monthData isFlaggedOnDay:day];
	cell.note = [monthData noteOnDay:day];
	[cell updateLabels];

	return cell;
}

#pragma mark UITableViewDelegate (Optional)

- (void)tableView:(UITableView *)tableView selectionDidChangeToIndexPath:(NSIndexPath *)newIndexPath fromIndexPath:(NSIndexPath *)oldIndexPath
{
	if (newIndexPath) {
		MonthData *monthData = [database dataForMonth:[self monthForSection:[newIndexPath section]]];
		EWDay day = 1 + [newIndexPath row];
		[viewController presentLogEntryViewForMonthData:monthData onDay:day];
	}
}

@end
