/*
 * EWDatabase.h
 * Created by Benjamin Ragheb on 12/9/09.
 * Copyright 2015 Heroic Software Inc
 *
 * This file is part of FatWatch.
 *
 * FatWatch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FatWatch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Foundation/Foundation.h>
#import "EWDate.h"
#import "EWDBMonth.h"


@class SQLiteDatabase;
@class SQLiteStatement;
@class EWDBIterator;


extern NSString * const EWDatabaseDidChangeNotification;


typedef enum {
	EWDatabaseFilterNone,
	EWDatabaseFilterWeight,
	EWDatabaseFilterWeightAndFat
} EWDatabaseFilter;


@interface EWDatabase : NSObject 
@property (nonatomic,readonly) EWMonth earliestMonth;
@property (nonatomic,readonly) EWMonth latestMonth;
@property (nonatomic,readonly,getter=isEmpty) BOOL empty;
// Setup
- (id)initWithFile:(NSString *)path;
- (id)initWithSQLNamed:(NSString *)sqlName bundle:(NSBundle *)bundle;
- (void)close;
- (void)reopen;
- (BOOL)needsUpgrade;
- (void)upgrade;
// Reading
- (float)earliestWeight;
- (float)earliestFatWeight;
- (float)latestWeight;
- (BOOL)didRecordFatBeforeMonth:(EWMonth)month;
- (EWDBMonth *)getDBMonth:(EWMonth)month;
- (void)getWeightMinimum:(float *)minWeight maximum:(float *)maxWeight onlyFat:(BOOL)onlyFat from:(EWMonthDay)beginMonthDay to:(EWMonthDay)endMonthDay;
- (void)getEarliestMonthDay:(EWMonthDay *)beginMonthDay latestMonthDay:(EWMonthDay *)endMonthDay filter:(EWDatabaseFilter)filter;
- (const EWDBDay *)getMonthDay:(EWMonthDay *)mdHead withWeightBefore:(EWMonthDay)mdStart onlyFat:(BOOL)onlyFat;
- (const EWDBDay *)getMonthDay:(EWMonthDay *)mdTail withWeightAfter:(EWMonthDay)mdStop onlyFat:(BOOL)onlyFat;
- (BOOL)hasDataForToday;
- (EWDBIterator *)iterator;
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
- (void)saveEnergyEquivalents:(NSArray *)dataArray;
@end
