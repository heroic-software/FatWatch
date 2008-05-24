//
//  MonthData.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/6/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWDate.h"

@interface MonthData : NSObject {
	EWMonth month;
	UInt32 dirtyBits;
	float *measuredWeights;
	float *trendWeights;
	UInt32 flagBits;
	NSMutableArray *notesArray;
}

@property (nonatomic,readonly) EWMonth month;

+ (void)finalizeStatements;
- (id)initWithMonth:(EWMonth)m;
- (NSDate *)dateOnDay:(EWDay)day;
- (float)measuredWeightOnDay:(EWDay)day;
- (EWDay)firstDayWithWeight;
- (float)inputTrendOnDay:(EWDay)day;
- (float)lastTrendValueAfterUpdateStartingOnDay:(EWDay)day withInputTrend:(float)inputTrend;
- (float)trendWeightOnDay:(EWDay)day;
- (BOOL)isFlaggedOnDay:(EWDay)day;
- (NSString *)noteOnDay:(EWDay)day;
- (void)setMeasuredWeight:(float)weight 
					 flag:(BOOL)flag
					 note:(NSString *)note
					onDay:(EWDay)day;
- (BOOL)commitChanges;

@end
