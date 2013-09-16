//
//  TrendSpan.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 9/9/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRColorPalette.h"
#import "EWDBMonth.h"
#import "EWDBIterator.h"
#import "EWDatabase.h"
#import "EWDate.h"
#import "EWGoal.h"
#import "EWWeightChangeFormatter.h"
#import "EWWeightFormatter.h"
#import "SlopeComputer.h"
#import "TrendSpan.h"


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
@synthesize beginMonthDay;
@synthesize endMonthDay;
@dynamic length;
@dynamic flagFrequencies;
@synthesize totalWeightPerDay;
@synthesize totalEndDate;
@synthesize totalGraphOperation;
@synthesize totalGraphImageRef;
@synthesize fatWeightPerDay;
@synthesize fatEndDate;
@synthesize fatGraphOperation;
@synthesize fatGraphImageRef;
@synthesize totalGraphParameters = _totalGraphParameters;
@synthesize fatGraphParameters = _fatGraphParameters;


- (id)init
{
    if ((self = [super init])) {
        _totalGraphParameters = [[GraphViewParameters alloc] init];
        _fatGraphParameters = [[GraphViewParameters alloc] init];
    }
    return self;
}


- (NSInteger)length {
	return EWDaysBetweenMonthDays(beginMonthDay, endMonthDay);
}


- (float *)flagFrequencies {
	return flagFrequencies;
}


- (void)setImageRef:(CGImageRef *)member toValue:(CGImageRef)value {
	if (*member != value) {
		CGImageRetain(value);
		CGImageRelease(*member);
		*member = value;
	}
}


- (void)setTotalGraphImageRef:(CGImageRef)imgRef {
	[self setImageRef:&totalGraphImageRef toValue:imgRef];
}


- (void)setFatGraphImageRef:(CGImageRef)imgRef {
	[self setImageRef:&fatGraphImageRef toValue:imgRef];
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
		span.title = info[@"Title"];
		[dc setMonth:-[info[@"Months"] intValue]];
		[dc setDay:-[info[@"Days"] intValue]];
		NSDate *beginDate = [calendar dateByAddingComponents:dc toDate:now options:0];
		span.beginMonthDay = EWMonthDayFromDate(beginDate);
		span.endMonthDay = EWMonthDayToday();
		[spanArray addObject:span];
		[span release];
	}
	[dc release];

	return spanArray;
}


+ (NSArray *)computeTrendSpansFromDatabase:(EWDatabase *)db {
	NSUInteger previousCount = 3; // means you need at least four weights to compute trends
	int x = 0;
	
	SlopeComputer *totalComputer = [[SlopeComputer alloc] init];
	SlopeComputer *fatComputer = [[SlopeComputer alloc] init];
	EWGoal *goal = [[EWGoal alloc] initWithDatabase:db];
	
	float flagCounts[4] = {0,0,0,0};
	
	float minWeight = 5000;
	float maxWeight = 0;
	float minFatWeight = 5000;
	float maxFatWeight = 0;
	
	NSMutableArray *computedSpans = [NSMutableArray array];
	
	EWDBIterator *it = [db iterator];
	it.latestMonthDay = EWMonthDayToday();
	const EWDBDay *dbd = [it previousDBDay];

	for (TrendSpan *span in [self trendSpanArray]) {
		while ((it.currentMonthDay > span.beginMonthDay) && (dbd != NULL)) {
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
			dbd = [it previousDBDay];
		}
		
		// Because every scaleFatWeight implies a scaleWeight, it is always
		// the case that totalComputer.count >= fatComputer.count.
		
		if (totalComputer.count > previousCount) {
			GraphViewParameters *gp;
			
			gp = span.totalGraphParameters;
			gp.showFatWeight = NO;
			gp.minWeight = minWeight;
			gp.maxWeight = maxWeight;
			span.totalWeightPerDay = -totalComputer.slope;

			gp = span.fatGraphParameters;
			gp.showFatWeight = YES;
			gp.minWeight = minFatWeight;
			gp.maxWeight = maxFatWeight;
			span.fatWeightPerDay = -fatComputer.slope;
			
			// Because of this, spans will have to be regenerated if goal changes.
			if (span.totalWeightPerDay != 0) {
				NSDate *date = [goal endDateWithWeightChangePerDay:span.totalWeightPerDay];
				if ([date timeIntervalSinceNow] < 0) {
					span.totalEndDate = nil;
				} else {
					span.totalEndDate = date;
				}
			}
			
			if (span.fatWeightPerDay != 0) {
				NSDate *date = [goal endDateWithWeightChangePerDay:span.fatWeightPerDay];
				if ([date timeIntervalSinceNow] < 0) {
					span.fatEndDate = nil;
				} else {
					span.fatEndDate = date;
				}
			}

			float *flagFreq = span.flagFrequencies;
			flagFreq[0] = flagCounts[0] / (float)x;
			flagFreq[1] = flagCounts[1] / (float)x;
			flagFreq[2] = flagCounts[2] / (float)x;
			flagFreq[3] = flagCounts[3] / (float)x;
			
			[computedSpans addObject:span];
			previousCount = totalComputer.count;
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
			@"\t slp %f lbs/wk total\n"
			@"\t slp %f lbs/wk fat\n"
			@">",
			self.title,
			EWDateFromMonthDay(self.beginMonthDay),
			EWDateFromMonthDay(self.endMonthDay),
			self.length,
			self.totalWeightPerDay * 7.f,
			self.fatWeightPerDay * 7.f
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
	[totalEndDate release];
	[fatEndDate release];
	CGImageRelease(totalGraphImageRef);
	CGImageRelease(fatGraphImageRef);
	[totalGraphOperation release];
	[fatGraphOperation release];
	[_totalGraphParameters release];
	[_fatGraphParameters release];
	[super dealloc];
}


@end
