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


@implementation TrendSpan


@synthesize title, length, weightPerDay, visible, goal;


+ (NSMutableArray *)trendSpanArray {
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


+ (NSArray *)computeTrendSpans {
	NSMutableArray *array = [self trendSpanArray];
	
	EWMonthDay curMonthDay = EWMonthDayFromDate([NSDate date]);
	EWDay curDay = EWMonthDayGetDay(curMonthDay);
	int previousCount = 1;
	float x = 0;
	
	SlopeComputer *computer = [[SlopeComputer alloc] init];
	MonthData *data = [[Database sharedDatabase] dataForMonth:EWMonthDayGetMonth(curMonthDay)];
	NSArray *sortedArray = [array sortedArrayUsingSelector:@selector(compare:)];
	for (TrendSpan *span in sortedArray) {
		while ((x < span.length) && (data != nil)) {
			float y = [data trendWeightOnDay:curDay];
			if (y > 0) {
				[computer addPointAtX:x y:y];
			}
			x += 1;
			curDay--;
			if (curDay < 1) {
				data = data.previousMonthData;
				curDay = EWDaysInMonth(data.month);
			}
		}
		
		span.weightPerDay = -computer.slope;
		if (span.goal) {
			span.visible = (computer.count > 1);
		} else if (computer.count > previousCount) {
			span.visible = YES;
			previousCount = computer.count;
		}
	}
	[computer release];
	
	NSMutableArray *filteredArray = [NSMutableArray array];
	for (TrendSpan *span in array) {
		if (span.visible) [filteredArray addObject:span];
	}
	
	return filteredArray;
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


@end
