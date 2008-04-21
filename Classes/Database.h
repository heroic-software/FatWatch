//
//  Database.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/7/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "/usr/include/sqlite3.h"
#import "EWDate.h"

#define kMonthColumnIndex 0
#define kDayColumnIndex 1
#define kMeasuredValueColumnIndex 2
#define kTrendValueColumnIndex 3
#define kFlagColumnIndex 4
#define kNoteColumnIndex 5

typedef enum {
	kWeightUnitPounds = 1,
	kWeightUnitKilograms = 2
} EWWeightUnit;

typedef enum {
	kEnergyUnitCalories = 1,
	kEnergyUnitKilojoules = 2
} EWEnergyUnit;

@class MonthData;

@interface Database : NSObject {
	sqlite3 *database;
	NSMutableDictionary *monthCache;
}
- (sqlite3_stmt *)statementFromSQL:(const char *)sql;
- (void)close;
- (EWMonth)earliestMonth;
- (NSUInteger)weightCount;
- (EWWeightUnit)weightUnit;
- (void)setWeightUnit:(EWWeightUnit)su;
- (MonthData *)dataForMonth:(EWMonth)m;
- (MonthData *)dataForMonthBefore:(EWMonth)m;
- (MonthData *)dataForMonthAfter:(EWMonth)m;
- (float)minimumWeight;
- (float)maximumWeight;
- (void)commitChanges;
@end
