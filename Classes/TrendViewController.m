//
//  TrendViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "TrendViewController.h"
#import "WeightFormatters.h"
#import "EWGoal.h"
#import "TrendSpan.h"
#import "Database.h"


@implementation TrendViewController


- (id)init {
	if ([super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"TRENDS_VIEW_TITLE", nil);
		self.tabBarItem.image = [UIImage imageNamed:@"TabIconTrend.png"];
		array = [[NSMutableArray alloc] init];
	}
	return self;
}


- (void)databaseDidChange:(NSNotification *)notice {
	[array setArray:[TrendSpan computeTrendSpans]];
	[self.tableView reloadData];
}


- (void)dealloc {
	[array release];
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


- (void)viewWillAppear:(BOOL)animated {
	[self startObservingDatabase];
}


- (void)viewWillDisappear:(BOOL)animated {
	[self stopObservingDatabase];
}


#pragma mark UITableViewDataSource (Required)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return MAX(1, [array count]);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([array count] == 0) return 0;
	TrendSpan *span = [array objectAtIndex:section];
	if (span.goal) {
		return (span.endDate != nil) ? 4 : 3;
	} else {
		return 2;
	}
}


#pragma mark UITableViewDataSource (Optional)

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([array count] == 0) return nil;
	TrendSpan *span = [array objectAtIndex:section];
	return span.title;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if ([array count] == 0) {
		return NSLocalizedString(@"NO_DATA_FOR_TRENDS", nil);
	} else {
		return nil;
	}
}


#pragma mark UITableViewDelegate (Required)


- (void)updateGoalDateCell:(UITableViewCell *)cell trendSpan:(TrendSpan *)span {
	NSDate *endDate = span.endDate;
	
	if (endDate) {
		int dayCount = floor([endDate timeIntervalSinceNow] / SecondsPerDay);
		if (dayCount > 365) {
			cell.text = @"goal in over a year";
		} else if (showEndDateAsDate) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterLongStyle];
			[formatter setTimeStyle:NSDateFormatterNoStyle];
			NSString *dateStr = [formatter stringFromDate:endDate];
			cell.text = [NSString stringWithFormat:@"goal on %@", dateStr];
			[formatter release];
		} else if (dayCount == 0) {
			cell.text = @"goal today";
		} else {
			cell.text = [NSString stringWithFormat:@"goal in %d days", dayCount];
		}
		cell.textColor = [UIColor blackColor];
	} else {
		if ([[EWGoal sharedGoal] isAttained]) {
			cell.text = @"goal attained";
			cell.textColor = [WeightFormatters goodColor];
		} else {
			cell.text = @"moving away from goal";
			cell.textColor = [WeightFormatters badColor];
		}
	}
}


- (void)updateGoalPlanCell:(UITableViewCell *)cell trendSpan:(TrendSpan *)span {
	EWGoal *goal = [EWGoal sharedGoal];
	NSDate *endDate = span.endDate;
	
	NSTimeInterval t = [endDate timeIntervalSinceDate:goal.endDate];
	int dayCount = floor(t / SecondsPerDay);
	if (dayCount > 0) {
		if (dayCount > 365) {
			cell.text = @"more than a year behind schedule";
		} else if (dayCount == 1) {
			cell.text = @"1 day behind schedule";
		} else {
			cell.text = [NSString stringWithFormat:@"%d days behind schedule", dayCount];
		}
		cell.textColor = [WeightFormatters warningColor];
	} else if (dayCount < 0) {
		if (dayCount < -365) {
			cell.text = @"more than a year ahead of schedule";
		} else if (dayCount == -1) {
			cell.text = @"1 day ahead of schedule";
		} else {
			cell.text = [NSString stringWithFormat:@"%d days ahead of schedule", -dayCount];
		}
		cell.textColor = [WeightFormatters goodColor];
	} else {
		cell.text = @"on schedule";
		cell.textColor = [WeightFormatters goodColor];
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	id availableCell = [tableView dequeueReusableCellWithIdentifier:@"TrendCell"];
	if (availableCell != nil) {
		cell = (UITableViewCell *)availableCell;
	} else {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"TrendCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone; // don't show selection
	}

	TrendSpan *span = [array objectAtIndex:indexPath.section];
	
	if (indexPath.row == 0) {
		cell.text = [WeightFormatters weightStringForWeightPerDay:span.weightPerDay];
		cell.textColor = [UIColor blackColor];
	} else if (indexPath.row == 1) {
		cell.text = [WeightFormatters energyStringForWeightPerDay:span.weightPerDay];
		cell.textColor = [UIColor blackColor];
	} else if (indexPath.row == 2) {
		[self updateGoalDateCell:cell trendSpan:span];
	} else {
		[self updateGoalPlanCell:cell trendSpan:span];
	}

	return cell;
}


#pragma mark UITableViewDelegate (Optional)


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 2) {
		showEndDateAsDate = !showEndDateAsDate;
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		TrendSpan *span = [array objectAtIndex:indexPath.section];
		[self updateGoalDateCell:cell trendSpan:span];
	}
}


@end
