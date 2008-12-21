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
#define kScaleValueColumnIndex 1
#define kTrendValueColumnIndex 2
#define kFlagColumnIndex 3
#define kNoteColumnIndex 4

extern void EWFinalizeStatement(sqlite3_stmt **stmt_ptr);

extern NSString *EWDatabaseDidChangeNotification;

@class MonthData;

@interface Database : NSObject {
	sqlite3 *database;
	NSMutableDictionary *monthCache;
	EWMonthDay earliestChangeMonthDay;
	EWMonth earliestMonth, latestMonth;
}

+ (Database *)sharedDatabase;

@property (nonatomic,readonly) EWMonth earliestMonth; // from cache
@property (nonatomic,readonly) EWMonth latestMonth; // from cache

- (void)openAtPath:(NSString *)path;
- (void)open;
- (void)close;
- (sqlite3_stmt *)statementFromSQL:(const char *)sql;
- (void)executeSQL:(const char *)sql;
- (NSUInteger)weightCount; // from DB
- (void)didChangeWeightOnMonthDay:(EWMonthDay)monthday;
- (MonthData *)dataForMonth:(EWMonth)m;
- (float)minimumWeight; // from DB
- (float)maximumWeight; // from DB
- (void)commitChanges;
- (void)flushCache;
- (void)deleteWeights;

@end
