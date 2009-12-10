//
//  TrendSpan.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 9/9/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "TrendSpan.h"
#import "EWDate.h"
#import "EWGoal.h"
#import "Database.h"
#import "MonthData.h"
#import "SlopeComputer.h"
#import "WeightFormatters.h"


const NSInteger kTrendSpanRowCount = 3;
enum {
	kTrendSpanRowWeightChangeTotal,
	kTrendSpanRowWeightChangeRate,
	kTrendSpanRowEnergyChangeRate,
	// the following are extra rows for the Goal span
	kTrendSpanRowGoalDate,
	kTrendSpanRowGoalPlan
};


@implementation TrendSpan


@synthesize title, length, weightPerDay, visible;
@synthesize weightChange;


+ (NSMutableArray *)trendSpanArray {
	NSMutableArray *spanArray = [NSMutableArray array];
	
	EWGoal *goal = [EWGoal sharedGoal];
	if (goal.defined) {
		TrendSpan *span = [[GoalTrendSpan alloc] init];
		
		NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:goal.startDate toDate:[NSDate date] options:0];
		span.title = @"Since Goal Start";
		span.length = [comps day];
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


+ (NSArray *)computeTrendSpans {
	NSMutableArray *array = [self trendSpanArray];
	
	EWMonthDay curMonthDay = EWMonthDayToday();
	EWDay curDay = EWMonthDayGetDay(curMonthDay);
	int previousCount = 1;
	float x = 0;
	
	SlopeComputer *computer = [[SlopeComputer alloc] init];
	MonthData *data = [[Database sharedDatabase] dataForMonth:EWMonthDayGetMonth(curMonthDay)];
	
	float firstTrendWeight = 0;
	
	NSArray *sortedArray = [array sortedArrayUsingSelector:@selector(compare:)];
	for (TrendSpan *span in sortedArray) {
		float lastTrendWeight;
		
		while ((x < span.length) && (data != nil)) {
			float y = [data trendWeightOnDay:curDay];
			if (y > 0) {
				[computer addPointAtX:x y:y];
				if (firstTrendWeight == 0) firstTrendWeight = y;
				lastTrendWeight = y;
			}
			x += 1;
			curDay--;
			if (curDay < 1) {
				data = data.previousMonthData;
				curDay = EWDaysInMonth(data.month);
			}
		}
		
		if ([span isKindOfClass:[GoalTrendSpan class]]) {
			span.visible = (computer.count > 1);
		} else if (computer.count > previousCount) {
			span.visible = YES;
			previousCount = computer.count;
		}
		if (span.visible) {
			span.weightPerDay = -computer.slope;
			span.weightChange = firstTrendWeight - lastTrendWeight;
		}
	}
	[computer release];
	
	NSMutableArray *filteredArray = [NSMutableArray array];
	for (TrendSpan *span in array) {
		if (span.visible) [filteredArray addObject:span];
	}
	
	return filteredArray;
}


- (void)dealloc {
	[title release];
	[super dealloc];
}


- (NSComparisonResult)compare:(TrendSpan *)otherSpan {
	if (self.length < otherSpan.length) {
		return NSOrderedAscending;
	} else if (self.length > otherSpan.length) {
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}


- (NSInteger)numberOfTableRows {
	return kTrendSpanRowCount;
}


- (void)configureCell:(UITableViewCell *)cell forTableRow:(NSInteger)row {
	switch (row) {
		case kTrendSpanRowWeightChangeRate:
			cell.textLabel.text = [WeightFormatters weightStringForWeightPerDay:self.weightPerDay];
			cell.textLabel.textColor = [UIColor blackColor];
			break;
		case kTrendSpanRowWeightChangeTotal: {
			if (self.weightChange > 0) {
				NSString *amount = [WeightFormatters stringForWeight:self.weightChange];
				cell.textLabel.text = [amount stringByAppendingString:NSLocalizedString(@" gained", @"Gain suffix")];
			} else {
				NSString *amount = [WeightFormatters stringForWeight:-self.weightChange];
				cell.textLabel.text = [amount stringByAppendingString:NSLocalizedString(@" lost", @"Loss suffix")];
			}
			cell.textLabel.textColor = [UIColor blackColor];
			break;
		}
		case kTrendSpanRowEnergyChangeRate:
			cell.textLabel.text = [WeightFormatters energyStringForWeightPerDay:self.weightPerDay];
			cell.textLabel.textColor = [UIColor blackColor];
			break;
	}
}


- (BOOL)shouldUpdateAfterDidSelectRow:(NSInteger)row {
	return NO;
}


@end



@implementation GoalTrendSpan


- (NSDate *)endDate {
	if (self.weightPerDay == 0) {
		return nil;
	}
	
	EWGoal *g = [EWGoal sharedGoal];
	NSDate *endDate = [g endDateWithWeightChangePerDay:self.weightPerDay];
	if ([endDate timeIntervalSinceNow] < 0) {
		return nil;
	} else {
		return endDate;
	}
}


- (void)updateGoalDateCell:(UITableViewCell *)cell {
	NSDate *endDate = self.endDate;
	
	if (endDate) {
		int dayCount = floor([endDate timeIntervalSinceNow] / SecondsPerDay);
		if (dayCount > 365) {
			cell.textLabel.text = @"goal in over a year";
		} else if (showEndDateAsDate) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterLongStyle];
			[formatter setTimeStyle:NSDateFormatterNoStyle];
			NSString *dateStr = [formatter stringFromDate:endDate];
			cell.textLabel.text = [NSString stringWithFormat:@"goal on %@", dateStr];
			[formatter release];
		} else if (dayCount == 0) {
			cell.textLabel.text = @"goal today";
		} else {
			cell.textLabel.text = [NSString stringWithFormat:@"goal in %d days", dayCount];
		}
		cell.textLabel.textColor = [UIColor blackColor];
	} else {
		if ([[EWGoal sharedGoal] isAttained]) {
			cell.textLabel.text = @"goal attained";
			cell.textLabel.textColor = [WeightFormatters goodColor];
		} else {
			cell.textLabel.text = @"moving away from goal";
			cell.textLabel.textColor = [WeightFormatters badColor];
		}
	}
}


- (void)updateGoalPlanCell:(UITableViewCell *)cell {
	EWGoal *g = [EWGoal sharedGoal];
	NSDate *endDate = self.endDate;
	
	NSTimeInterval t = [endDate timeIntervalSinceDate:g.endDate];
	int dayCount = floor(t / SecondsPerDay);
	if (dayCount > 0) {
		if (dayCount > 365) {
			cell.textLabel.text = @"more than a year behind schedule";
		} else if (dayCount == 1) {
			cell.textLabel.text = @"1 day behind schedule";
		} else {
			cell.textLabel.text = [NSString stringWithFormat:@"%d days behind schedule", dayCount];
		}
		cell.textLabel.textColor = [WeightFormatters warningColor];
	} else if (dayCount < 0) {
		if (dayCount < -365) {
			cell.textLabel.text = @"more than a year ahead of schedule";
		} else if (dayCount == -1) {
			cell.textLabel.text = @"1 day ahead of schedule";
		} else {
			cell.textLabel.text = [NSString stringWithFormat:@"%d days ahead of schedule", -dayCount];
		}
		cell.textLabel.textColor = [WeightFormatters goodColor];
	} else {
		cell.textLabel.text = @"on schedule";
		cell.textLabel.textColor = [WeightFormatters goodColor];
	}
}


- (NSInteger)numberOfTableRows {
	return kTrendSpanRowCount + ((self.endDate != nil) ? 2 : 1);
}


- (void)configureCell:(UITableViewCell *)cell forTableRow:(NSInteger)row {
	switch (row) {
		case kTrendSpanRowGoalDate:
			[self updateGoalDateCell:cell];
			break;
		case kTrendSpanRowGoalPlan:
			[self updateGoalPlanCell:cell];
			break;
		default:
			[super configureCell:cell forTableRow:row];
	}
}


- (BOOL)shouldUpdateAfterDidSelectRow:(NSInteger)row {
	if (row == kTrendSpanRowGoalDate) {
		showEndDateAsDate = !showEndDateAsDate;
		return YES;
	}
	return NO;
}


@end
