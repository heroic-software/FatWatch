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

- (NSDate *)firstDateInMonthOfDate:(NSDate *)someDate
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit
											   fromDate:someDate];
	return [calendar dateFromComponents:components];
}

- (id)initWithDatabase:(Database *)db {
	if ([super init]) {
		database = [db retain];

		NSDate *oldDate = [database earliestDate];
		beginDate = [[self firstDateInMonthOfDate:oldDate] retain];

		endDate = [[NSDate alloc] init];
		if ([beginDate compare:endDate] == NSOrderedDescending) {
			[endDate release];
			endDate = [beginDate retain];
		}

		sectionTitleFormatter = [[NSDateFormatter alloc] init];
		sectionTitleFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
		sectionTitleFormatter.dateFormat = @"MMMM yyyy";
		
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *components = [calendar components:NSMonthCalendarUnit
												   fromDate:beginDate
													 toDate:endDate
													options:0];
		numberOfSections = 1 + components.month;
		
		components = [calendar components:NSDayCalendarUnit 
								 fromDate:endDate];
		lastIndexPath = [NSIndexPath indexPathForRow:(components.day - 1)
										   inSection:(numberOfSections - 1)];
		[lastIndexPath retain];
	}
	return self;
}

- (void)dealloc {
	[lastIndexPath release];
	[sectionTitleFormatter release];
	[endDate release];
	[beginDate release];
	[database release];
	[super dealloc];
}

- (NSIndexPath *)lastIndexPath
{
	return lastIndexPath;
}

- (NSDate *)beginDateForSection:(NSInteger)section {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.month = section;
	//components.day = row;
	NSDate *theDate = [calendar dateByAddingComponents:components toDate:beginDate options:0];
	[components release];
	return theDate;
}

#pragma mark UITableViewDataSource (Required)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == numberOfSections - 1) {
		return [lastIndexPath row] + 1;
	} else {
		NSDate *theDate = [self beginDateForSection:section];
		NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit 
														   inUnit:NSMonthCalendarUnit
														  forDate:theDate];
		return range.length;
	}
}

#pragma mark UITableViewDataSource (Optional)

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSDate *theDate = [self beginDateForSection:section];
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
		
	MonthData *monthData = [database monthDataForDate:[self beginDateForSection:[indexPath section]]];
	
	unsigned int day = 1 + [indexPath row];
	
	cell.day = day;
	cell.measuredWeight = [monthData measuredWeightOnDay:day];
	cell.trendWeight = [monthData trendWeightOnDay:day];
	cell.flagged = [monthData isFlaggedOnDay:day];
	cell.note = [monthData noteOnDay:day];
	[cell updateLabels];

	return cell;
}

#pragma mark UITableViewDelegate (Optional)

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MonthData *monthData = [database monthDataForDate:[self beginDateForSection:[indexPath section]]];
	unsigned int day = 1 + [indexPath row];

	if ([monthData noteOnDay:day] != nil) {
		return 64;
	} else {
		return 44;
	}
}

- (void)tableView:(UITableView *)tableView selectionDidChangeToIndexPath:(NSIndexPath *)newIndexPath fromIndexPath:(NSIndexPath *)oldIndexPath
{
	if (newIndexPath) {
		MonthData *monthData = [database monthDataForDate:[self beginDateForSection:[newIndexPath section]]];
		unsigned int day = 1 + [newIndexPath row];
		[viewController presentLogEntryViewForMonthData:monthData onDay:day];
	}
}

//- (void)tableView:(UITableView *)tableView willDisplayRowsAtIndexPaths:(NSArray *)indexPaths
//- (void)tableView:(UITableView *)tableView willLoadVisibleCellsInRowAtIndexPaths:(NSArray *)rows
//- (void)tableView:(UITableView *)tableView didLoadVisibleCellsInRowsAtIndexPaths:(NSArray *)rows nextPredictedRowsAtIndexPaths:(NSArray *)rows

@end
