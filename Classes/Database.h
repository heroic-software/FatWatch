//
//  Database.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/7/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "/usr/include/sqlite3.h"
#import "EWDate.h"

#define kMonthDayColumnIndex 0
#define kMeasuredValueColumnIndex 1
#define kTrendValueColumnIndex 2
#define kFlagColumnIndex 3
#define kNoteColumnIndex 4

typedef enum {
	kWeightUnitPounds = 1,
	kWeightUnitKilograms = 2
} EWWeightUnit;

typedef enum {
	kEnergyUnitCalories = 1,
	kEnergyUnitKilojoules = 2
} EWEnergyUnit;

#define kCaloriesPerPound 3500
#define kKilojoulesPerKilogram 7716

#define kPoundsPerKilogram 0.45359237f

#define kCaloriesPerKilogram (kCaloriesPerPound * kPoundsPerKilogram)
#define kKilojoulesPerPound (kKilojoulesPerKilogram / kPoundsPerKilogram)

NSString *EWStringFromWeightUnit(EWWeightUnit weightUnit);
void EWFinalizeStatement(sqlite3_stmt **stmt_ptr);

@class MonthData;

@interface Database : NSObject {
	sqlite3 *database;
	NSUInteger changeCount;
	NSMutableDictionary *monthCache;
	EWMonthDay earliestChangeMonthDay;
	EWMonth earliestMonth, latestMonth;
}

+ (Database *)sharedDatabase;

@property (nonatomic,readonly) NSUInteger changeCount;
@property (nonatomic,readonly) EWMonth earliestMonth; // from cache
@property (nonatomic,readonly) EWMonth latestMonth; // from cache

- (void)openAtPath:(NSString *)path;
- (void)open;
- (void)close;
- (sqlite3_stmt *)statementFromSQL:(const char *)sql;
- (NSUInteger)weightCount; // from DB
- (EWWeightUnit)weightUnit;
- (void)setWeightUnit:(EWWeightUnit)su;
- (void)didChangeWeightOnMonthDay:(EWMonthDay)monthday;
- (MonthData *)dataForMonth:(EWMonth)m;
- (float)minimumWeight; // from DB
- (float)maximumWeight; // from DB
- (void)commitChanges;
- (void)flushCache;

@end
