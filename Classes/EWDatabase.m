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


NSString * const EWDatabaseDidChangeNotification = @"EWDatabaseDidChange";


@interface EWDatabase ()
- (void)updateTrendValues;
- (void)flushCache;
- (void)executeSQLNamed:(NSString *)name;
- (int)intValueForMetaName:(NSString *)name;
- (void)upgradeIfNeeded;
@end


@implementation EWDatabase


@synthesize earliestMonth;
@synthesize latestMonth;


+ (EWDatabase *)sharedDatabase {
	static EWDatabase *db = nil;
	
	if (db == nil) {
		db = [[EWDatabase alloc] init];
	}
	return db;
}


- (id)init {
	if ([super init]) {
		monthCacheLock = [[NSLock alloc] init];
		[monthCacheLock setName:@"monthCacheLock"];
		monthCache = [[NSMutableDictionary alloc] init];
	}
	return self;
}


- (void)didOpen {
	earliestChangeMonthDay = 0;
	
	[self upgradeIfNeeded];
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


- (void)openFile:(NSString *)path {
	NSAssert(db == nil, @"Database must not already be open");
	db = [[SQLiteDatabase alloc] initWithFile:path];
	[self didOpen];
}


- (void)openMemoryWithSQL:(const char *)sql {
	NSAssert(db == nil, @"Database must not already be open");
	db = [[SQLiteDatabase alloc] initInMemory];
	[db executeSQL:sql];
	[self didOpen];
}


- (void)close {
	[self commitChanges];
	[self flushCache];
	[db release];
	db = nil;
}


#pragma mark Reading


- (NSUInteger)weightCount {
	NSUInteger count;
	
	SQLiteStatement *stmt = [db statementFromSQL:"SELECT COUNT(*) FROM days WHERE scaleWeight IS NOT NULL"];
	if ([stmt step]) {
		count = [stmt intValueOfColumn:0];
		[stmt reset];
	} else {
		count = 0;
	}

	return count;
}


- (float)earliestWeight {
	float weight;
	
	SQLiteStatement *stmt = [db statementFromSQL:"SELECT scaleWeight FROM days WHERE scaleWeight IS NOT NULL ORDER BY monthday LIMIT 1"];
	if ([stmt step]) {
		weight = [stmt doubleValueOfColumn:0];
		[stmt reset];
	} else {
		weight = 0;
	}
	
	return weight;
}


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


- (void)getWeightMinimum:(float *)minWeight maximum:(float *)maxWeight from:(EWMonthDay)beginMonthDay to:(EWMonthDay)endMonthDay {
	NSParameterAssert(minWeight);
	NSParameterAssert(maxWeight);
	
	SQLiteStatement *stmt;
	
	if (beginMonthDay == 0 || endMonthDay == 0) {
		stmt = [db statementFromSQL:"SELECT MIN(scaleWeight),MAX(scaleWeight) FROM days"];
	} else {
		// TODO: If time frame is limited, trend will need to be taken into account.
		stmt = [db statementFromSQL:"SELECT MIN(scaleWeight),MAX(scaleWeight) FROM days WHERE monthday BETWEEN ? AND ?"];
		[stmt bindInt:beginMonthDay toParameter:1];
		[stmt bindInt:endMonthDay toParameter:2];
	}
	
	if ([stmt step]) {
		*minWeight = [stmt isNullColumn:0] ? 0 : [stmt intValueOfColumn:0];
		*maxWeight = [stmt isNullColumn:1] ? 0 : [stmt intValueOfColumn:1];
		[stmt reset];
	} else {
		*minWeight = 0;
		*maxWeight = 0;
	}
}


- (void)getEarliestMonthDay:(EWMonthDay *)beginMonthDay latestMonthDay:(EWMonthDay *)endMonthDay {
	NSParameterAssert(beginMonthDay);
	NSParameterAssert(endMonthDay);
	
	SQLiteStatement *stmt = [db statementFromSQL:"SELECT MIN(monthday),MAX(monthday) FROM days"];
	if ([stmt step]) {
		*beginMonthDay = [stmt isNullColumn:0] ? 0 : [stmt intValueOfColumn:0];
		*endMonthDay = [stmt isNullColumn:1] ? 0 : [stmt intValueOfColumn:1];
		[stmt reset];
	} else {
		*beginMonthDay = 0;
		*endMonthDay = 0;
	}
}


- (float)trendWeightOnMonthDay:(EWMonthDay)md {
	EWDBMonth *dbm = [self getDBMonth:EWMonthDayGetMonth(md)];
	const EWDBDay *d = [dbm getDBDayOnDay:EWMonthDayGetDay(md)];
	return d->trendWeight;
}


/* Searches for a monthday before the given monthday where weight was recorded. Will cross at most one month boundary. */
- (EWMonthDay)monthDayOfWeightBefore:(EWMonthDay)mdStart {
	EWMonth monthStop = EWMonthDayGetMonth(mdStart) - 2;
	EWMonthDay md = EWMonthDayPrevious(mdStart);
	EWDBMonth *dbm = [self getDBMonth:EWMonthDayGetMonth(md)];
	while (monthStop < EWMonthDayGetMonth(md)) {
		if (EWMonthDayGetMonth(md) != dbm.month) {
			dbm = [self getDBMonth:EWMonthDayGetMonth(md)];
		}
		const EWDBDay *d = [dbm getDBDayOnDay:EWMonthDayGetDay(md)];
		if (d->scaleWeight > 0) {
			return md;
		}
		md = EWMonthDayPrevious(md);
	}
	return 0;
}


/* Searches for a monthday after the given monthday where weight was recorded. Will cross at most one month boundary. */
- (EWMonthDay)monthDayOfWeightAfter:(EWMonthDay)mdStart {
	EWMonth monthStop = EWMonthDayGetMonth(mdStart) + 2;
	EWMonthDay md = EWMonthDayNext(mdStart);
	EWDBMonth *dbm = [self getDBMonth:EWMonthDayGetMonth(md)];
	while (monthStop < EWMonthDayGetMonth(md)) {
		if (EWMonthDayGetMonth(md) != dbm.month) {
			dbm = [self getDBMonth:EWMonthDayGetMonth(md)];
		}
		const EWDBDay *d = [dbm getDBDayOnDay:EWMonthDayGetDay(md)];
		if (d->scaleWeight > 0) {
			return md;
		}
		md = EWMonthDayNext(md);
	}
	return 0;
}


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
	[db executeSQL:"BEGIN"];
	for (EWDBMonth *dbm in [monthCache allValues]) {
		if ([dbm commitChanges]) changeCount++;
	}
	[db executeSQL:"END"];
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
	return [db statementFromSQL:"SELECT * FROM months WHERE month < ? ORDER BY month DESC LIMIT 1"];
}


- (SQLiteStatement *)insertMonthStatement {
	return [db statementFromSQL:"INSERT OR REPLACE INTO months VALUES (?,?,?)"];
}


- (SQLiteStatement *)selectDaysStatement {
	return [db statementFromSQL:"SELECT * FROM days WHERE monthday BETWEEN ? AND ?"];
}


- (SQLiteStatement *)insertDayStatement {
	return [db statementFromSQL:"INSERT OR REPLACE INTO days (monthday,scaleWeight,scaleFat,flag0,flag1,flag2,flag3,note) VALUES (?,?,?,?,?,?,?,?)"];
}


- (SQLiteStatement *)deleteDayStatement {
	return [db statementFromSQL:"DELETE FROM days WHERE monthday = ?"];
}


#pragma mark Private Methods


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
	const char zero = 0;
	
	NSLog(@"Executing SQL %@", name);
	NSBundle *bundle = [NSBundle bundleForClass:[self class]]; // needed for unit testing
	NSString *path = [bundle pathForResource:name ofType:@"sql"];
	NSAssert1(path != nil, @"Cannot find SQL named %@", name);
	NSMutableData *sql = [[NSMutableData alloc] initWithContentsOfFile:path];
	[sql appendBytes:&zero length:1]; // null termination
	[db executeSQL:[sql bytes]];
	[sql release];
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


- (void)upgradeIfNeeded {
	int version = [self intValueForMetaName:@"dataversion"];
	if (version < 2) {
		[self executeSQLNamed:@"DBUpgrade2"];
	}
	if (version < 3) {
		[self executeSQLNamed:@"DBUpgrade3"];
	}
}


@end
