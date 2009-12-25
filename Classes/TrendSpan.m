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
@dynamic flagFrequencies;
@synthesize beginMonthDay;
@synthesize endMonthDay;
@synthesize graphImageRef;
@synthesize graphOperation;
@dynamic graphParameters;


- (float *)flagFrequencies {
	return flagFrequencies;
}


- (GraphViewParameters *)graphParameters {
	return &graphParameters;
}


- (void)setGraphImageRef:(CGImageRef)imgRef {
	if (graphImageRef != imgRef) {
		CGImageRetain(imgRef);
		CGImageRelease(graphImageRef);
		graphImageRef = imgRef;
	}
}


+ (NSMutableArray *)trendSpanArray {
	NSMutableArray *spanArray = [NSMutableArray array];

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
		GraphViewParameters *gp = span.graphParameters;
		float lastTrendWeight;
		
		gp->minWeight = 500;
		gp->maxWeight = 0;

		while ((x < span.length) && (data != nil)) {
			const EWDBDay *dbd = [data getDBDayOnDay:curDay];

			if (dbd->flags[0]) flagCounts[0] += 1;
			if (dbd->flags[1]) flagCounts[1] += 1;
			if (dbd->flags[2]) flagCounts[2] += 1;
			if (dbd->flags[3]) flagCounts[3] += 1;
			
			if (dbd->scaleWeight > 0) {
				if (dbd->scaleWeight < dbd->trendWeight) {
					if (dbd->scaleWeight < gp->minWeight) gp->minWeight = dbd->scaleWeight;
					if (dbd->trendWeight > gp->maxWeight) gp->maxWeight = dbd->trendWeight;
				} else {
					if (dbd->trendWeight < gp->minWeight) gp->minWeight = dbd->trendWeight;
					if (dbd->scaleWeight > gp->maxWeight) gp->maxWeight = dbd->scaleWeight;
				}
			}
			
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
			span.beginMonthDay = EWMonthDayMake(data.month, curDay);
			span.endMonthDay = EWMonthDayToday();
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


- (NSComparisonResult)compare:(TrendSpan *)otherSpan {
	if (self.length < otherSpan.length) {
		return NSOrderedAscending;
	} else if (self.length > otherSpan.length) {
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}


- (void)dealloc {
	[title release];
	CGImageRelease(graphImageRef);
	[graphOperation release];
	[graphParameters.regions release];
	[super dealloc];
}


@end
