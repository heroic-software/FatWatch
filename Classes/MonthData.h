//
//  MonthData.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/6/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWDate.h"

@class Database;

@interface MonthData : NSObject {
	Database *db;
	EWMonth month;
	UInt32 dirtyBits;
	struct DayData {
		float scaleWeight;
		float trendWeight;
		NSString *note;
		int flags;
	} dayData[31];
}

@property (nonatomic,readonly) EWMonth month;
@property (nonatomic,readonly) MonthData *previousMonthData;
@property (nonatomic,readonly) MonthData *nextMonthData;

+ (void)finalizeStatements;
- (id)initWithMonth:(EWMonth)m database:(Database *)database;
- (NSDate *)dateOnDay:(EWDay)day;
- (float)scaleWeightOnDay:(EWDay)day;
- (EWDay)firstDayWithWeight;
- (EWDay)lastDayWithWeight;
- (float)inputTrendOnDay:(EWDay)day;
- (float)lastTrendValueAfterUpdateStartingOnDay:(EWDay)day withInputTrend:(float)inputTrend;
- (float)trendWeightOnDay:(EWDay)day;
- (BOOL)isFlaggedOnDay:(EWDay)day;
- (NSString *)noteOnDay:(EWDay)day;
- (void)setScaleWeight:(float)weight flag:(BOOL)flag note:(NSString *)note onDay:(EWDay)day;
- (BOOL)hasDataOnDay:(EWDay)day;
- (BOOL)commitChanges;

@end
