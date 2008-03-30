//
//  EWWeightLogDataSource.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/15/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "EWWeightLogDataSource.h"
#import "LogTableViewCell.h"

@implementation EWWeightLogDataSource

- (NSDate *)firstDateInMonthOfDate:(NSDate *)someDate
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit
											   fromDate:someDate];
	return [calendar dateFromComponents:components];
}

- (id)init {
	if ([super init]) {
		// right now we pick an arbitrary date in the past but eventually this
		// will be the earliest date in our database
		NSDate *oldDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-(60 * 60 * 24 * 500)];
		beginDate = [[self firstDateInMonthOfDate:oldDate] retain];
		[oldDate release];

		endDate = [[NSDate alloc] init];

		sectionTitleFormatter = [[NSDateFormatter alloc] init];
		sectionTitleFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
		sectionTitleFormatter.dateFormat = @"MMMM yyyy";
		
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *
		
		components = [calendar components:NSMonthCalendarUnit
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
	[super dealloc];
}

- (NSIndexPath *)lastIndexPath
{
	return lastIndexPath;
}

- (NSDate *)dateForRow:(NSInteger)row inSection:(NSInteger)section {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.month = section;
	components.day = row;
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
		NSDate *theDate = [self dateForRow:0 inSection:section];
		NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit 
														   inUnit:NSMonthCalendarUnit
														  forDate:theDate];
		return range.length;
	}
}

#pragma mark UITableViewDataSource (Optional)

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSDate *theDate = [self dateForRow:0 inSection:section];
	return [sectionTitleFormatter stringFromDate:theDate];
}

#pragma mark UITableViewDelegate (Required)

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath 
			 withAvailableCell:(UITableViewCell *)availableCell {
	LogTableViewCell *cell = nil;
	if (availableCell != nil) {
		cell = (LogTableViewCell *)availableCell;
	} else {
		CGRect frame = CGRectMake(0, 0, 300, 44);
		cell = [[[LogTableViewCell alloc] initWithFrame:frame] autorelease];
	}
	
	float n = ((float)[indexPath row]) / 31.0f;
	
	cell.day = [indexPath row] + 1;
	if ([indexPath row] % 7 == 0) {
		cell.measuredWeight = 0;
		cell.trendWeight = 0;
		cell.flagged = NO;
	} else {
		cell.measuredWeight = 182.0 + (10.0 * (0.5 - n));
		cell.trendWeight = 182.0 + (20.0 * (0.5 - n));
		cell.flagged = [indexPath row] % 3;
	}
	[cell updateLabels];

	return cell;
}

#pragma mark UITableViewDelegate (Optional)

//- (void)tableView:(UITableView *)tableView willDisplayRowsAtIndexPaths:(NSArray *)indexPaths
//- (void)tableView:(UITableView *)tableView willLoadVisibleCellsInRowAtIndexPaths:(NSArray *)rows
//- (void)tableView:(UITableView *)tableView didLoadVisibleCellsInRowsAtIndexPaths:(NSArray *)rows nextPredictedRowsAtIndexPaths:(NSArray *)rows

@end
