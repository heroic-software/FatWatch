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


+ (NSArray *)trendSpanArray {
	NSMutableArray *spanArray = [NSMutableArray array];

	NSString *path = [[NSBundle mainBundle] pathForResource:@"TrendSpans" ofType:@"plist"];

	NSArray *infoArray = [NSArray arrayWithContentsOfFile:path];
	NSDateComponents *dc = [[NSDateComponents alloc] init];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDate *now = EWDateFromMonthDay(EWMonthDayToday());
	for (NSDictionary *info in infoArray) {
		TrendSpan *span = [[TrendSpan alloc] init];
		span.title = [info objectForKey:@"Title"];
		[dc setMonth:-[[info objectForKey:@"Months"] intValue]];
		[dc setDay:-[[info objectForKey:@"Days"] intValue]];
		NSDate *beginDate = [calendar dateByAddingComponents:dc toDate:now options:0];
		span.beginMonthDay = EWMonthDayFromDate(beginDate);
		span.endMonthDay = EWMonthDayToday();
		span.length = EWDaysBetweenMonthDays(span.beginMonthDay, span.endMonthDay);
		[spanArray addObject:span];
		[span release];
	}
	[dc release];

	return spanArray;
}


+ (NSArray *)computeTrendSpans {
	EWMonthDay curMonthDay = EWMonthDayToday();
	int previousCount = 1;
	int x = 0;
	
	SlopeComputer *computer = [[SlopeComputer alloc] init];
	EWDBMonth *data = [[EWDatabase sharedDatabase] getDBMonth:EWMonthDayGetMonth(curMonthDay)];
	
	float flagCounts[4] = {0,0,0,0};
	
	float minWeight = 500;
	float maxWeight = 0;
	
	NSMutableArray *computedSpans = [NSMutableArray array];
	
	for (TrendSpan *span in [self trendSpanArray]) {
		GraphViewParameters *gp = span.graphParameters;
		
		while ((curMonthDay > span.beginMonthDay) && (data != nil)) {
			const EWDBDay *dbd = [data getDBDayOnDay:EWMonthDayGetDay(curMonthDay)];

			if (dbd->flags[0]) flagCounts[0] += 1;
			if (dbd->flags[1]) flagCounts[1] += 1;
			if (dbd->flags[2]) flagCounts[2] += 1;
			if (dbd->flags[3]) flagCounts[3] += 1;
			
			if (dbd->scaleWeight > 0) {
				if (dbd->scaleWeight < dbd->trendWeight) {
					if (dbd->scaleWeight < minWeight) minWeight = dbd->scaleWeight;
					if (dbd->trendWeight > maxWeight) maxWeight = dbd->trendWeight;
				} else {
					if (dbd->trendWeight < minWeight) minWeight = dbd->trendWeight;
					if (dbd->scaleWeight > maxWeight) maxWeight = dbd->scaleWeight;
				}
				[computer addPoint:CGPointMake(x, dbd->trendWeight)];
			}
			
			x += 1;
			curMonthDay = EWMonthDayPrevious(curMonthDay);
			if (data.month != EWMonthDayGetMonth(curMonthDay)) {
				data = data.previous;
			}
		}
		
		if (computer.count > previousCount) {
			previousCount = computer.count;
			gp->minWeight = minWeight;
			gp->maxWeight = maxWeight;
			span.weightPerDay = -computer.slope;
			span.flagFrequencies[0] = flagCounts[0] / (float)x;
			span.flagFrequencies[1] = flagCounts[1] / (float)x;
			span.flagFrequencies[2] = flagCounts[2] / (float)x;
			span.flagFrequencies[3] = flagCounts[3] / (float)x;
			[computedSpans addObject:span];
		}
	}
	[computer release];
	
#if TARGET_IPHONE_SIMULATOR
	for (TrendSpan *span in computedSpans) {
		NSLog(@"Computed %@", span);
	}
#endif
	
	return computedSpans;
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


- (NSString *)description {
	return [NSString stringWithFormat:
			@"<TrendSpan: \"%@\"\n"
			@"\tfrom %@\n"
			@"\t  to %@\n"
			@"\t len %d\n"
			@"\t slp %f lbs/wk\n"
			@">",
			self.title,
			EWDateFromMonthDay(self.beginMonthDay),
			EWDateFromMonthDay(self.endMonthDay),
			self.length,
			self.weightPerDay * 7.f
			];
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
