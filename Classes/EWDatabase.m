//
//  EWDatabase.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/9/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "EWDatabase.h"
#import "EWDBMonth.h"
#import "SQLiteDatabase.h"
#import "SQLiteStatement.h"
#import "EWEnergyEquivalent.h"


NSString * const EWDatabaseDidChangeNotification = @"EWDatabaseDidChange";


static EWDatabase *gSharedDB = nil;


@interface EWDatabase ()
- (float)floatFromSQL:(const char *)sql;
- (float)trendValueOnMonthDay:(EWMonthDay)startMonthDay;
- (void)didOpen;
- (void)updateTrendValues;
- (void)flushCache;
- (void)executeSQLNamed:(NSString *)name;
- (int)intValueForMetaName:(NSString *)name;
@end


@implementation EWDatabase


@synthesize earliestMonth;
@synthesize latestMonth;


+ (EWDatabase *)sharedDatabase {
	return gSharedDB;
}


+ (void)setSharedDatabase:(EWDatabase *)db {
	if (db != gSharedDB) {
		[db retain];
		[gSharedDB release];
		gSharedDB = db;
	}
}


- (id)init {
	if ([super init]) {
		monthCacheLock = [[NSLock alloc] init];
		[monthCacheLock setName:@"monthCacheLock"];
		monthCache = [[NSMutableDictionary alloc] init];
	}
	return self;
}


- (id)initWithFile:(NSString *)path {
	if (self = [self init]) {
		db = [[SQLiteDatabase alloc] initWithFile:path];
		[self didOpen];
	}
	return self;
}


- (id)initWithSQLNamed:(NSString *)sqlName {
	if (self = [self init]) {
		db = [[SQLiteDatabase alloc] initInMemory];
		[self executeSQLNamed:sqlName];
		[self didOpen];
	}
	return self;
}


- (BOOL)needsUpgrade {
	return [self intValueForMetaName:@"dataversion"] < 3;
}


- (void)upgrade {
	int version = [self intValueForMetaName:@"dataversion"];
	if (version < 2) {
		[self executeSQLNamed:@"DBUpgrade2"];
	}
	if (version < 3) {
		[self executeSQLNamed:@"DBUpgrade3"];
	}
	[self didOpen];
}


- (void)didOpen {
	if ([self needsUpgrade]) return;
	
	earliestChangeMonthDay = 0;
	
	EWMonth currentMonth = EWMonthDayGetMonth(EWMonthDayToday());
	SQLiteStatement *stmt = [db statementFromSQL:"SELECT MIN(monthday),MAX(monthday) FROM days"];
	if ([stmt step]) {
		earliestMonth = ([stmt isNullColumn:0]
						 ? currentMonth
						 : EWMonthDayGetMonth([stmt intValueOfColumn:0]));
		latestMonth = ([stmt isNullColumn:1] 
					   ? currentMonth
					   : EWMonthDayGetMonth([stmt intValueOfColumn:1]));
		[stmt reset];
	} else {
		earliestMonth = currentMonth;
		latestMonth = currentMonth;
	}
}


- (void)close {
	[self commitChanges];
	[self flushCache];
	[db release];
	db = nil;
}


- (void)dealloc {
	if (gSharedDB == self) {
		gSharedDB = nil;
	}
	[db release];
	[monthCache release];
	[monthCacheLock release];
	[super dealloc];
}


#pragma mark Reading


// Used by app delegate to determine if the database is empty.
- (BOOL)isEmpty {
	SQLiteStatement *stmt = [db statementFromSQL:"SELECT 1 FROM days WHERE scaleWeight IS NOT NULL LIMIT 1"];
	return ![stmt step];
}


// Used by LogEntryViewController when choosing default weight. Only called if no weight prior to current day.
// Used by EWGoal when finding start weight during an upgrade from DBv2.
- (float)earliestWeight {
	return [self floatFromSQL:"SELECT scaleWeight FROM days WHERE scaleWeight IS NOT NULL ORDER BY monthday LIMIT 1"];
}


// Used by LogEntryViewController when choosing default fat ratio. Only called if no weight prior to current day.
- (float)earliestFatRatio {
	return [self floatFromSQL:"SELECT (scaleFatWeight / scaleWeight) FROM days WHERE scaleFatWeight IS NOT NULL ORDER BY monthday LIMIT 1"];
}


// Used by EWGoal to determine current weight.
// Used by TrendViewController to determine current weight for activities.
// Used by GoalViewController to set default goal weight.
- (float)latestWeight {
	return [self trendValueOnMonthDay:EWMonthDayToday()];
}


// Used by EWDBMonth in latestFatBeforeDay:
- (float)latestFatRatioBeforeMonth:(EWMonth)month {
	SQLiteStatement *stmt = [db statementFromSQL:"SELECT (scaleFatWeight / scaleWeight) FROM days WHERE scaleFatWeight IS NOT NULL AND monthday < ? ORDER BY monthday DESC LIMIT 1"];

	[stmt bindInt:EWMonthDayMake(month, 1) toParameter:1];
	if ([stmt step]) {
		float r = [stmt doubleValueOfColumn:0];
		[stmt reset];
		return r;
	} else {
		return 0;
	}
}


// Used by EWDBMonth in didRecordFatBeforeDay:
- (BOOL)didRecordFatBeforeMonth:(EWMonth)month {
	SQLiteStatement *stmt = [db statementFromSQL:"SELECT scaleFatWeight FROM days WHERE scaleWeight IS NOT NULL AND monthday < ? ORDER BY monthday DESC LIMIT 1"];
	float fat;
	
	[stmt bindInt:EWMonthDayMake(month, 1) toParameter:1];
	if ([stmt step]) {
		fat = [stmt doubleValueOfColumn:0];
		[stmt reset];
	} else {
		fat = 0;
	}
	
	return fat > 0;
}


// Used all over the place.
- (EWDBMonth *)getDBMonth:(EWMonth)month {
	id key = [NSNumber numberWithInt:month];
	EWDBMonth *dbm = nil;
	
	[monthCacheLock lock];
	{
		dbm = [monthCache objectForKey:key];
		if (dbm == nil) {
			dbm = [[EWDBMonth alloc] initWithMonth:month database:self];
			[monthCache setObject:dbm forKey:key];
			[dbm release];
#if TARGET_IPHONE_SIMULATOR
			NSLog(@"Month Cache: %d records", [monthCache count]);
#endif
		}
		if (month < earliestMonth) earliestMonth = month;
		if (month > latestMonth) latestMonth = month;
	}
	[monthCacheLock unlock];
	
	return dbm;
}


// Used by GraphViewController when sizing graphs.
- (void)getWeightMinimum:(float *)minWeight maximum:(float *)maxWeight onlyFat:(BOOL)onlyFat from:(EWMonthDay)beginMonthDay to:(EWMonthDay)endMonthDay {
	NSParameterAssert(minWeight);
	NSParameterAssert(maxWeight);
	
	SQLiteStatement *stmt;
	float beginTrend = 0;
	
	if (beginMonthDay == 0 || endMonthDay == 0) {
		if (onlyFat) {
			stmt = [db statementFromSQL:"SELECT MIN(scaleFatWeight),MAX(scaleFatWeight) FROM days"];
		} else {
			stmt = [db statementFromSQL:"SELECT MIN(scaleWeight),MAX(scaleWeight) FROM days"];
		}
	} else {
		if (onlyFat) {
			stmt = [db statementFromSQL:"SELECT MIN(scaleFatWeight),MAX(scaleFatWeight) FROM days WHERE monthday BETWEEN ? AND ?"];
		} else {
			stmt = [db statementFromSQL:"SELECT MIN(scaleWeight),MAX(scaleWeight) FROM days WHERE monthday BETWEEN ? AND ?"];
		}
		[stmt bindInt:beginMonthDay toParameter:1];
		[stmt bindInt:endMonthDay toParameter:2];
		// If time frame is limited, trend should be taken into account.
		if (!onlyFat) {
			beginTrend = [self trendValueOnMonthDay:beginMonthDay];
		}
	}
	
	if ([stmt step]) {
		*minWeight = [stmt doubleValueOfColumn:0];
		*maxWeight = [stmt doubleValueOfColumn:1];
		[stmt reset];
	} else {
		*minWeight = 0;
		*maxWeight = 0;
	}
	
	if (beginTrend > 0) {
		*minWeight = MIN(*minWeight, beginTrend);
		*maxWeight = MAX(*maxWeight, beginTrend);
	}
}


// Used by GraphDrawingOperation when setting parameters.
// Used by GraphViewController when sizing "all time" graph.
- (void)getEarliestMonthDay:(EWMonthDay *)beginMonthDay latestMonthDay:(EWMonthDay *)endMonthDay {
	NSParameterAssert(beginMonthDay);
	NSParameterAssert(endMonthDay);
	
	SQLiteStatement *stmt = [db statementFromSQL:"SELECT MIN(monthday),MAX(monthday) FROM days"];
	if ([stmt step]) {
		*beginMonthDay = [stmt intValueOfColumn:0];
		*endMonthDay = [stmt intValueOfColumn:1];
		[stmt reset];
	} else {
		*beginMonthDay = 0;
		*endMonthDay = 0;
	}
}


/* Searches for a monthday BEFORE the given monthday where weight was recorded. */
// Used by GraphDrawingOperation to determine head point locations.
- (const EWDBDay *)getMonthDay:(EWMonthDay *)mdHead withWeightBefore:(EWMonthDay)mdStart onlyFat:(BOOL)onlyFat {
	SQLiteStatement *stmt;
	if (onlyFat) {
		stmt = [db statementFromSQL:"SELECT monthday FROM days WHERE scaleFatWeight IS NOT NULL AND monthday < ? ORDER BY monthday DESC LIMIT 1"];
	} else {
		stmt = [db statementFromSQL:"SELECT monthday FROM days WHERE scaleWeight IS NOT NULL AND monthday < ? ORDER BY monthday DESC LIMIT 1"];
	}
	[stmt bindInt:mdStart toParameter:1];
	if ([stmt step]) {
		*mdHead = [stmt intValueOfColumn:0];
		[stmt reset];
		EWDBMonth *dbm = [self getDBMonth:EWMonthDayGetMonth(*mdHead)];
		return [dbm getDBDayOnDay:EWMonthDayGetDay(*mdHead)];
	}
	return nil;
}


/* Searches for a monthday AFTER the given monthday where weight was recorded. */
// Used by GraphDrawingOperation to determine tail point locations.
- (const EWDBDay *)getMonthDay:(EWMonthDay *)mdTail withWeightAfter:(EWMonthDay)mdStop onlyFat:(BOOL)onlyFat {
	SQLiteStatement *stmt;
	if (onlyFat) {
		stmt = [db statementFromSQL:"SELECT monthday FROM days WHERE scaleFatWeight IS NOT NULL AND monthday > ? ORDER BY monthday LIMIT 1"];
	} else {
		stmt = [db statementFromSQL:"SELECT monthday FROM days WHERE scaleWeight IS NOT NULL AND monthday > ? ORDER BY monthday LIMIT 1"];
	}
	[stmt bindInt:mdStop toParameter:1];
	if ([stmt step]) {
		*mdTail = [stmt intValueOfColumn:0];
		[stmt reset];
		EWDBMonth *dbm = [self getDBMonth:EWMonthDayGetMonth(*mdTail)];
		return [dbm getDBDayOnDay:EWMonthDayGetDay(*mdTail)];
	}
	return nil;
}


// Used by LogViewController when setting reminder badge value
- (BOOL)hasDataForToday {
	EWMonthDay today = EWMonthDayToday();
	EWDBMonth *dbm = [self getDBMonth:EWMonthDayGetMonth(today)];
	return [dbm hasDataOnDay:EWMonthDayGetDay(today)];
}


#pragma mark Writing


- (void)didChangeWeightOnMonthDay:(EWMonthDay)monthday {
	if ((earliestChangeMonthDay == 0) || (monthday < earliestChangeMonthDay)) {
		earliestChangeMonthDay = monthday;
	}
}


- (void)commitChanges {
	int changeCount = 0;
	
	[self updateTrendValues];
	[monthCacheLock lock];
	[db beginTransaction];
	for (EWDBMonth *dbm in [monthCache allValues]) {
		if ([dbm commitChanges]) changeCount++;
	}
	[db commitTransaction];
	[monthCacheLock unlock];
	
	if (changeCount > 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:EWDatabaseDidChangeNotification object:self];
	}
}


- (void)deleteAllData {
	[self flushCache];
	[db executeSQL:"DELETE FROM days;DELETE FROM months"];
	earliestMonth = EWMonthDayGetMonth(EWMonthDayToday());
	latestMonth = earliestMonth;
	earliestChangeMonthDay = 0;
}


- (SQLiteStatement *)selectMonthStatement {
	return [db statementFromSQL:"SELECT month,outputTrendWeight,outputTrendFatWeight FROM months WHERE month < ? ORDER BY month DESC LIMIT 1"];
}


- (SQLiteStatement *)insertMonthStatement {
	return [db statementFromSQL:"INSERT OR REPLACE INTO months VALUES (?,?,?)"];
}


- (SQLiteStatement *)selectDaysStatement {
	return [db statementFromSQL:"SELECT monthday,scaleWeight,scaleFatWeight,flag0,flag1,flag2,flag3,note FROM days WHERE monthday BETWEEN ? AND ?"];
}


- (SQLiteStatement *)insertDayStatement {
	return [db statementFromSQL:"INSERT OR REPLACE INTO days (monthday,scaleWeight,scaleFatWeight,flag0,flag1,flag2,flag3,note) VALUES (?,?,?,?,?,?,?,?)"];
}


- (SQLiteStatement *)deleteDayStatement {
	return [db statementFromSQL:"DELETE FROM days WHERE monthday = ?"];
}


#pragma mark Energy Equivalents


- (NSArray *)loadEnergyEquivalents {
	SQLiteStatement *stmt = [db statementFromSQL:"SELECT id,section,row,name,unit,value FROM equivalents ORDER BY section,row"];
	NSMutableArray *array0 = [NSMutableArray array];
	NSMutableArray *array1 = [NSMutableArray array];
	
	[EWActivityEquivalent setCurrentWeight:[self latestWeight]];
	
	while ([stmt step]) {
		id <EWEnergyEquivalent> equiv;
		
		if ([stmt intValueOfColumn:1] == 0) {
			equiv = [[EWActivityEquivalent alloc] init];
			[array0 addObject:equiv];
		} else {
			equiv = [[EWFoodEquivalent alloc] init];
			[array1 addObject:equiv];
		}
		
		equiv.dbID = [stmt intValueOfColumn:0];
		equiv.name = [stmt stringValueOfColumn:3];
		equiv.unitName = [stmt stringValueOfColumn:4];
		equiv.value = [stmt doubleValueOfColumn:5];
		
		[equiv release];
	}
	
	if ([array0 count] == 0 && [array1 count] == 0) {
		NSLog(@"Equivalents table empty, loading defaults.");
		[self executeSQLNamed:@"DBEquivDefaults"];
		return [self loadEnergyEquivalents];
	}
	
	return [NSArray arrayWithObjects:array0, array1, nil];
}


- (void)saveEnergyEquivalents:(NSArray *)dataArray {
	SQLiteStatement *selectStmt = [db statementFromSQL:"SELECT id FROM equivalents"];
	SQLiteStatement *updateStmt = [db statementFromSQL:"UPDATE equivalents SET row=? WHERE id=?"];
	SQLiteStatement *insertStmt = [db statementFromSQL:"INSERT INTO equivalents (section,row,name,unit,value) VALUES (?,?,?,?,?)"];
	SQLiteStatement *deleteStmt = [db statementFromSQL:"DELETE FROM equivalents WHERE id=?"];
	
	[db beginTransaction];
	
	NSMutableSet *deletionCandidateIDSet = [[NSMutableSet alloc] init];
	while ([selectStmt step]) {
		int dbID = [selectStmt intValueOfColumn:0];
		[deletionCandidateIDSet addObject:[NSNumber numberWithInt:dbID]];
	}

	for (int section = 0; section < [dataArray count]; section++) {
		NSArray *sectionArray = [dataArray objectAtIndex:section];
		for (int row = 0; row < [sectionArray count]; row++) {
			id <EWEnergyEquivalent> equiv = [sectionArray objectAtIndex:row];
			if (equiv.dbID > 0) {
				[updateStmt bindInt:row toParameter:1];
				[updateStmt bindInt:equiv.dbID toParameter:2];
				[updateStmt step];
				[updateStmt reset];
			} else {
				[insertStmt bindInt:section toParameter:1];
				[insertStmt bindInt:row toParameter:2];
				[insertStmt bindString:equiv.name toParameter:3];
				[insertStmt bindString:equiv.unitName toParameter:4];
				[insertStmt bindDouble:equiv.value toParameter:5];
				[insertStmt step];
				[insertStmt reset];
				equiv.dbID = [db lastInsertRowID];
			}
			[deletionCandidateIDSet removeObject:[NSNumber numberWithInt:equiv.dbID]];
		}
	}
	
	for (NSNumber *dbIDNumber in deletionCandidateIDSet) {
		[deleteStmt bindInt:[dbIDNumber intValue] toParameter:1];
		[deleteStmt step];
		[deleteStmt reset];
	}
	[deletionCandidateIDSet release];
	
	[db commitTransaction];
}


#pragma mark Private Methods


- (float)floatFromSQL:(const char *)sql {
	float value;
	
	SQLiteStatement *stmt = [db statementFromSQL:sql];
	if ([stmt step]) {
		value = [stmt doubleValueOfColumn:0];
		[stmt reset];
	} else {
		value = 0;
	}
	
	return value;
}


- (float)trendValueOnMonthDay:(EWMonthDay)startMonthDay {
	EWMonthDay next = EWMonthDayNext(startMonthDay);
	EWDBMonth *dbm = [self getDBMonth:EWMonthDayGetMonth(next)];
	return [dbm inputTrendOnDay:EWMonthDayGetDay(next)];
}


- (void)updateTrendValues {
	if (earliestChangeMonthDay == 0) return;
	
	EWMonth month = EWMonthDayGetMonth(earliestChangeMonthDay);

	while (month <= latestMonth) {
		[[self getDBMonth:month] updateTrends];
		month += 1;
	}
	
	earliestChangeMonthDay = 0;
}


- (void)flushCache {
	[monthCacheLock lock];
	[monthCache	removeAllObjects];
	[monthCacheLock unlock];
}


- (void)executeSQLNamed:(NSString *)name {
	NSLog(@"Executing SQL %@", name);
	NSBundle *bundle = [NSBundle bundleForClass:[self class]]; // needed for unit testing
	NSString *path = [bundle pathForResource:name ofType:@"sql0"];
	NSAssert1(path != nil, @"Cannot find SQL named %@", name);
	NSData *sql0 = [[NSData alloc] initWithContentsOfFile:path];
#if TARGET_IPHONE_SIMULATOR
	char zero;
	[sql0 getBytes:&zero range:NSMakeRange([sql0 length] - 1, 1)];
	NSAssert1(zero == 0, @"SQL resource %@ not null terminated!", name);
#endif
	[db executeSQL:[sql0 bytes]];
	[sql0 release];
}


- (int)intValueForMetaName:(NSString *)name {
	int value;
	
	SQLiteStatement *stmt = [db statementFromSQL:"SELECT value FROM metadata WHERE name = ?"];
	[stmt bindString:name toParameter:1];
	if ([stmt step]) {
		value = [stmt intValueOfColumn:0];
		[stmt reset];
	} else {
		value = 0;
	}
	return value;
}


@end
