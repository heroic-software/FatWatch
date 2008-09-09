//
//  TrendViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "TrendViewController.h"
#import "Database.h"
#import "SlopeComputer.h"
#import "MonthData.h"
#import "WeightFormatters.h"
#import "EWGoal.h"

/*
 Trends:
 
 Since Goal Start
weight change: 1.00 lbs/week
energy change: -500 cal/day
target date:
on/behind/ahead:
 
 goal in 48 days / goal by September 9, 2008
 moving away from goal
 on schedule / behind schedule / ahead of schedule
 on schedule / 3 days behind schedule / 3 days ahead of schedule
*/ 

@interface TrendSpan : NSObject {
	NSString *title;
	NSInteger length;
	float weightPerDay;
	BOOL visible;
	BOOL goal;
}
@property (nonatomic,retain) NSString *title;
@property (nonatomic) NSInteger length;
@property (nonatomic) float weightPerDay;
@property (nonatomic) BOOL visible;
@property (nonatomic) BOOL goal;
@property (nonatomic,readonly) NSDate *endDate;
@end



@implementation TrendViewController


- (NSArray *)trendSpanArray {
	NSMutableArray *spanArray = [NSMutableArray array];

	EWGoal *goal = [EWGoal sharedGoal];
	if (goal.defined) {
		TrendSpan *span = [[TrendSpan alloc] init];
		
		NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:goal.startDate toDate:[NSDate date] options:0];
		span.title = @"Since Goal Start";
		span.length = [comps day];
		span.goal = YES;
		[spanArray addObject:span];
		[span release];
	}
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"TrendSpans" ofType:@"plist"];
	NSDictionary *spanDict = [NSDictionary dictionaryWithContentsOfFile:path];
	NSArray *spanLengths = [spanDict objectForKey:@"SpanLengths"];
	NSArray *spanTitles = [spanDict objectForKey:@"SpanTitles"];
	NSUInteger spanCount = MIN([spanLengths count], [spanTitles count]);

	NSUInteger spanIndex;
	for (spanIndex = 0; spanIndex < spanCount; spanIndex++) {
		TrendSpan *span = [[TrendSpan alloc] init];
		span.title = [spanTitles objectAtIndex:spanIndex];
		span.length = [[spanLengths objectAtIndex:spanIndex] intValue];
		[spanArray addObject:span];
		[span release];
	}
	
	return spanArray;
}


- (void)recompute {
	[array setArray:[self trendSpanArray]];
	
	Database *database = [Database sharedDatabase];
	
	SlopeComputer *computer = [[SlopeComputer alloc] init];
	EWMonthDay curMonthDay = EWMonthDayFromDate([NSDate date]);
	EWMonth curMonth = EWMonthDayGetMonth(curMonthDay);
	EWDay curDay = EWMonthDayGetDay(curMonthDay);
	MonthData *data = [database dataForMonth:curMonth];
	EWMonth earliestMonth = [database earliestMonth];

	int newValueCount = 0;
	float x = 0;
	
	NSArray *orderedSpanArray = [array sortedArrayUsingSelector:@selector(compare:)];
	for (TrendSpan *span in orderedSpanArray) {
		if (curMonth < earliestMonth) break;

		while ((x < span.length) && (curMonth >= earliestMonth)) {
			if (data == nil) {
				data = [database dataForMonth:curMonth];
			}
			float y = [data trendWeightOnDay:curDay];
			if (y > 0) {
				[computer addPointAtX:x y:y];
				newValueCount++;
			}
			x++;
			curDay--;
			if (curDay < 1) {
				curMonth--;
				curDay = EWDaysInMonth(curMonth);
				data = nil;
			}
		}
		if (newValueCount > 1 || span.goal) {
			span.weightPerDay = -[computer computeSlope];
			span.visible = YES;
			newValueCount = 0;
		}
	}
	[computer release];
	
	int index;
	for (index = [array count] - 1; index >= 0; index--) {
		TrendSpan *span = [array objectAtIndex:index];
		if (! span.visible) [array removeObjectAtIndex:index];
	}
}


- (id)init {
	if (self = [super init]) {
		self.title = NSLocalizedString(@"TRENDS_VIEW_TITLE", nil);
		self.tabBarItem.image = [UIImage imageNamed:@"TabIconTrend.png"];
		array = [[NSMutableArray alloc] init];
	}
	return self;
}


- (NSString *)message {
	return NSLocalizedString(@"NO_DATA_FOR_TRENDS", nil);
}


- (UIView *)loadDataView {
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	tableView.delegate = self;
	tableView.dataSource = self;
	return [tableView autorelease];
}


- (BOOL)hasEnoughData {
	if ([super hasEnoughData]) {
		[self recompute];
		return [array count] > 0;
	}
	return NO;
}


- (void)dataChanged {
	UITableView *tableView = (UITableView *)self.dataView;
	[tableView reloadData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}


- (void)dealloc {
	[array release];
	[super dealloc];
}


#pragma mark UITableViewDataSource (Required)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [array count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	TrendSpan *span = [array objectAtIndex:section];
	if (span.goal) {
		return (span.endDate != nil) ? 4 : 3;
	} else {
		return 2;
	}
}


#pragma mark UITableViewDataSource (Optional)

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	TrendSpan *span = [array objectAtIndex:section];
	return span.title;
}


#pragma mark UITableViewDelegate (Required)


- (void)updateGoalDateCell:(UITableViewCell *)cell trendSpan:(TrendSpan *)span {
	NSDate *endDate = span.endDate;
	
	if (endDate) {
		if (showEndDateAsDate) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterLongStyle];
			[formatter setTimeStyle:NSDateFormatterNoStyle];
			cell.text = [NSString stringWithFormat:@"goal on %@", [formatter stringFromDate:endDate]];
			[formatter release];
		} else {
			NSTimeInterval t = [endDate timeIntervalSinceNow];
			cell.text = [NSString stringWithFormat:@"goal in %0.0f days", round(t / SecondsPerDay)];
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
	int dayCount = round(t / SecondsPerDay);
	if (t > SecondsPerDay) {
		if (dayCount == 1) {
			cell.text = @"1 day behind schedule";
		} else {
			cell.text = [NSString stringWithFormat:@"%d days behind schedule", dayCount];
		}
		cell.textColor = [WeightFormatters warningColor];
	} else if (t < 0) {
		if (dayCount == -1) {
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



@implementation TrendSpan

@synthesize title, length, weightPerDay, visible, goal;

- (NSComparisonResult)compare:(TrendSpan *)otherSpan {
	if (self.length < otherSpan.length) {
		return NSOrderedAscending;
	} else if (self.length > otherSpan.length) {
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}


- (NSDate *)endDate {
	NSDate *nowDate = [NSDate date];
	NSDate *endDate = [[EWGoal sharedGoal] endDateFromStartDate:nowDate atWeightChangePerDay:self.weightPerDay];
	if ([endDate timeIntervalSinceDate:nowDate] < 0) {
		return nil;
	} else {
		return endDate;
	}
}

@end
