//
//  EWDatabase.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/9/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWDate.h"


@class SQLiteDatabase;
@class SQLiteStatement;
@class EWDBMonth;


extern NSString * const EWDatabaseDidChangeNotification;


@interface EWDatabase : NSObject {
	SQLiteDatabase *db;
	NSMutableDictionary *monthCache;
	NSLock *monthCacheLock;
	EWMonthDay earliestChangeMonthDay;
	EWMonth earliestMonth;
	EWMonth latestMonth;
}
@property (nonatomic,readonly) EWMonth earliestMonth;
@property (nonatomic,readonly) EWMonth latestMonth;
+ (EWDatabase *)sharedDatabase;
+ (void)setSharedDatabase:(EWDatabase *)db;
// Setup
- (id)initWithFile:(NSString *)path;
- (id)initWithSQL:(const char *)sql;
- (void)close;
- (BOOL)needsUpgrade;
- (void)upgrade;
// Reading
- (NSUInteger)weightCount;
- (float)earliestWeight;
- (float)latestWeight;
- (EWDBMonth *)getDBMonth:(EWMonth)month;
- (void)getWeightMinimum:(float *)minWeight maximum:(float *)maxWeight from:(EWMonthDay)beginMonthDay to:(EWMonthDay)endMonthDay;
- (void)getEarliestMonthDay:(EWMonthDay *)beginMonthDay latestMonthDay:(EWMonthDay *)endMonthDay;
- (float)trendWeightOnMonthDay:(EWMonthDay)md;
- (EWMonthDay)monthDayOfWeightBefore:(EWMonthDay)md;
- (EWMonthDay)monthDayOfWeightAfter:(EWMonthDay)md;
- (BOOL)hasDataForToday;
// Writing
- (void)didChangeWeightOnMonthDay:(EWMonthDay)monthday;
- (void)commitChanges;
- (void)deleteAllData;
- (SQLiteStatement *)selectMonthStatement;
- (SQLiteStatement *)insertMonthStatement;
- (SQLiteStatement *)selectDaysStatement;
- (SQLiteStatement *)insertDayStatement;
- (SQLiteStatement *)deleteDayStatement;
// Energy Equivalents
- (NSArray *)loadEnergyEquivalents;
- (void)saveEnergyEquivalents:(NSArray *)dataArray deletedItems:(NSArray *)deletedArray;
@end
