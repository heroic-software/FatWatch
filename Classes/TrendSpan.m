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


void TrendUpdateMinMax(float a, float b, float *min, float *max) {
	if (a < b) {
		if (a < *min) *min = a;
		if (b > *max) *max = b;
	} else {
		if (b < *min) *min = b;
		if (a > *max) *max = a;
	}
}


@implementation TrendSpan


@synthesize title;
@synthesize length;
@synthesize weightPerDay;
@synthesize endDate;
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


+ (NSArray *)computeTrendSpansFromDatabase:(EWDatabase *)db {
	EWMonthDay curMonthDay = EWMonthDayToday();
	int previousCount = 3; // means you need at least four weights to compute trends
	int x = 0;
	
	SlopeComputer *totalComputer = [[SlopeComputer alloc] init];
	SlopeComputer *fatComputer = [[SlopeComputer alloc] init];
	EWDBMonth *data = [db getDBMonth:EWMonthDayGetMonth(curMonthDay)];
	EWGoal *goal = [[EWGoal alloc] initWithDatabase:db];
	
	float flagCounts[4] = {0,0,0,0};
	
	float minWeight = 5000;
	float maxWeight = 0;
	float minFatWeight = 5000;
	float maxFatWeight = 0;
	
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
				TrendUpdateMinMax(dbd->scaleWeight, dbd->trendWeight,
								  &minWeight, &maxWeight);
				[totalComputer addPoint:CGPointMake(x, dbd->trendWeight)];
				if (dbd->scaleFatWeight > 0) {
					TrendUpdateMinMax(dbd->scaleFatWeight, dbd->trendFatWeight,
									  &minFatWeight, &maxFatWeight);
					[fatComputer addPoint:CGPointMake(x, dbd->trendFatWeight)];
				}
			}
			
			x += 1;
			curMonthDay = EWMonthDayPrevious(curMonthDay);
			if (data.month != EWMonthDayGetMonth(curMonthDay)) {
				data = data.previous;
			}
		}
		
		// Because every scaleFatWeight implies a scaleWeight, it is always
		// the case that totalComputer.count >= fatComputer.count.
		
		if (totalComputer.count > previousCount) {
			if (fatComputer.count > previousCount) {
				previousCount = fatComputer.count;
				gp->showFatWeight = YES;
				gp->minWeight = minFatWeight;
				gp->maxWeight = maxFatWeight;
				span.weightPerDay = -fatComputer.slope;
			} else {
				previousCount = totalComputer.count;
				gp->showFatWeight = NO;
				gp->minWeight = minWeight;
				gp->maxWeight = maxWeight;
				span.weightPerDay = -totalComputer.slope;
			}
			
			// TODO: Update if goal changes
			if (span.weightPerDay != 0) {
				NSDate *date = [goal endDateWithWeightChangePerDay:span.weightPerDay];
				if ([date timeIntervalSinceNow] < 0) {
					span.endDate = nil;
				} else {
					span.endDate = date;
				}
			}
			
			span.flagFrequencies[0] = flagCounts[0] / (float)x;
			span.flagFrequencies[1] = flagCounts[1] / (float)x;
			span.flagFrequencies[2] = flagCounts[2] / (float)x;
			span.flagFrequencies[3] = flagCounts[3] / (float)x;
			[computedSpans addObject:span];
		}
	}
	[totalComputer release];
	[fatComputer release];
	
#if TARGET_IPHONE_SIMULATOR
	for (TrendSpan *span in computedSpans) {
		NSLog(@"Computed %@", span);
	}
#endif
	
	[goal release];
	return computedSpans;
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
	[endDate release];
	CGImageRelease(graphImageRef);
	[graphOperation release];
	[graphParameters.regions release];
	[super dealloc];
}


@end
