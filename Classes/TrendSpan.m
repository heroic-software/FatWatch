//
//  TrendSpan.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 9/9/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRColorPalette.h"
#import "EWDBMonth.h"
#import "EWDatabase.h"
#import "EWDate.h"
#import "EWGoal.h"
#import "EWWeightChangeFormatter.h"
#import "EWWeightFormatter.h"
#import "SlopeComputer.h"
#import "TrendSpan.h"


enum {
	kTrendSpanRowWeightChangeTotal,
	kTrendSpanRowWeightChangeRate,
	kTrendSpanRowEnergyChangeRate,
	kTrendSpanRowGoalDate,
	kTrendSpanRowGoalPlan,
	kTrendSpanRowCount
};


@implementation TrendSpan


@synthesize title;
@synthesize length;
@synthesize weightPerDay;
@synthesize weightChange;
@synthesize visible;


- (float *)flagFrequencies {
	return flagFrequencies;
}


+ (NSMutableArray *)trendSpanArray {
	NSMutableArray *spanArray = [NSMutableArray array];
	
	EWGoal *goal = [EWGoal sharedGoal];
	if (goal.defined) {
		TrendSpan *span = [[TrendSpan alloc] init];
		
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
	EWDBMonth *data = [[EWDatabase sharedDatabase] getDBMonth:EWMonthDayGetMonth(curMonthDay)];
	
	float firstTrendWeight = 0;
	float flagCounts[4] = {0,0,0,0};
	
	NSArray *sortedArray = [array sortedArrayUsingSelector:@selector(compare:)];
	for (TrendSpan *span in sortedArray) {
		float lastTrendWeight;
		
		while ((x < span.length) && (data != nil)) {
			const EWDBDay *dbd = [data getDBDayOnDay:curDay];

			if (dbd->flags[0]) flagCounts[0] += 1;
			if (dbd->flags[1]) flagCounts[1] += 1;
			if (dbd->flags[2]) flagCounts[2] += 1;
			if (dbd->flags[3]) flagCounts[3] += 1;
			
			float y = dbd->trendWeight;
			if (y > 0) {
				[computer addPointAtX:x y:y];
				if (firstTrendWeight == 0) firstTrendWeight = y;
				lastTrendWeight = y;
			}
			
			x += 1;
			curDay--;
			if (curDay < 1) {
				data = data.previous;
				curDay = EWDaysInMonth(data.month);
			}
		}
		
		if (computer.count > previousCount) {
			span.visible = YES;
			previousCount = computer.count;
		}
		if (span.visible) {
			span.weightPerDay = -computer.slope;
			span.weightChange = firstTrendWeight - lastTrendWeight;
			span.flagFrequencies[0] = flagCounts[0] / x;
			span.flagFrequencies[1] = flagCounts[1] / x;
			span.flagFrequencies[2] = flagCounts[2] / x;
			span.flagFrequencies[3] = flagCounts[3] / x;
		}
	}
	[computer release];
	
	NSMutableArray *filteredArray = [NSMutableArray array];
	for (TrendSpan *span in array) {
		if (span.visible) [filteredArray addObject:span];
	}
	
	return filteredArray;
}


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


@end
