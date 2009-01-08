//
//  Database.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/7/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "Database.h"
#import "MonthData.h"


NSString *EWDatabaseDidChangeNotification = @"EWDatabaseDidChangeNotification";


static sqlite3_stmt *month_before_stmt = nil;
static sqlite3_stmt *month_after_stmt = nil;


void EWFinalizeStatement(sqlite3_stmt **stmt_ptr) {
	if (*stmt_ptr != NULL) {
		sqlite3_finalize(*stmt_ptr);
		*stmt_ptr = NULL;
	}
}


@implementation Database


@synthesize earliestMonth;
@synthesize latestMonth;


+ (Database *)sharedDatabase {
	static Database *db = nil;
	
	if (db == nil) {
		db = [[Database alloc] init];
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


- (void)openAtPath:(NSString *)path {
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database: %s", sqlite3_errmsg(database));
	}

	// Clean up cruft
	//[self executeSQL:"DELETE FROM weight WHERE measuredValue IS NULL AND trendValue IS NULL AND flag=0 AND (note='' OR note IS NULL)"];
	
	earliestChangeMonthDay = 0;
	EWMonth currentMonth = EWMonthDayGetMonth(EWMonthDayToday());
	
	sqlite3_stmt *statement = [self statementFromSQL:"SELECT MIN(monthday),MAX(monthday) FROM weight"];
	int r = sqlite3_step(statement);
	NSAssert1(r == SQLITE_ROW, @"SELECT monthday range failed: %s", sqlite3_errmsg(database));
	if (sqlite3_column_type(statement, 0) == SQLITE_NULL) {
		earliestMonth = currentMonth;
	} else {
		earliestMonth = EWMonthDayGetMonth(sqlite3_column_int(statement, 0));
	}
	if (sqlite3_column_type(statement, 1) == SQLITE_NULL) {
		latestMonth = currentMonth;
	} else {
		latestMonth = EWMonthDayGetMonth(sqlite3_column_int(statement, 1));
	}
	sqlite3_finalize(statement);
}


- (void)close {
	[self commitChanges];
	[monthCacheLock lock];
	[monthCache removeAllObjects];
	[monthCacheLock unlock];
	
	[MonthData finalizeStatements];
	EWFinalizeStatement(&month_after_stmt);
	EWFinalizeStatement(&month_before_stmt);
	
	int r = sqlite3_close(database);
	NSAssert1(r == SQLITE_OK, @"Failed to close database: %s", sqlite3_errmsg(database));
}


- (void)dealloc {
	[monthCache release];
	[monthCacheLock release];
	[super dealloc];
}


- (sqlite3_stmt *)statementFromSQL:(const char *)sql {
	sqlite3_stmt *statement;
	int r = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
	NSAssert2(r == SQLITE_OK, @"Failed to prepare '%s': %s", sql, sqlite3_errmsg(database));
	return statement;
}


- (void)executeSQL:(const char *)sql {
	sqlite3_stmt *stmt = [self statementFromSQL:sql];
	int r = sqlite3_step(stmt);
	NSAssert2(r == SQLITE_DONE, @"Failed to execute '%s': %s", sql, sqlite3_errmsg(database));
	sqlite3_finalize(stmt);
}


- (NSUInteger)weightCount {
	NSUInteger count;
	
	sqlite3_stmt *statement = [self statementFromSQL:"SELECT COUNT(*) FROM weight WHERE measuredValue IS NOT NULL"];
	int r = sqlite3_step(statement);
	NSAssert1(r == SQLITE_ROW, @"SELECT weight count failed: %s", sqlite3_errmsg(database));
	count = sqlite3_column_int(statement, 0);
	sqlite3_finalize(statement);
	
	return count;
}


- (int)intValueForMetaName:(const char *)name {
	int value = 0;
	
	sqlite3_stmt *statement = [self statementFromSQL:"SELECT value FROM metadata WHERE name = ?"];
	sqlite3_bind_text(statement, 1, name, strlen(name), SQLITE_STATIC);
	int r = sqlite3_step(statement);
	if (r == SQLITE_ROW) {
		value = sqlite3_column_int(statement, 0);
	} else if (r == SQLITE_DONE) {
		value = 0;
	} else {
		NSAssert1(0, @"SELECT metadata failed: %s", sqlite3_errmsg(database));
	}
	sqlite3_finalize(statement);

	return value;
}


- (void)didChangeWeightOnMonthDay:(EWMonthDay)monthday {
	if ((earliestChangeMonthDay == 0) || (monthday < earliestChangeMonthDay)) {
		earliestChangeMonthDay = monthday;
	}
}


- (void)getWeightMinimum:(float *)minWeight maximum:(float *)maxWeight from:(EWMonthDay)beginMonthDay to:(EWMonthDay)endMonthDay {
	NSParameterAssert(minWeight);
	NSParameterAssert(maxWeight);
	
	sqlite3_stmt *statement;

	if (beginMonthDay == 0 || endMonthDay == 0) {
		// trendValue will always be within the measuredValue range over all time
		statement = [self statementFromSQL:"SELECT MIN(measuredValue),MAX(measuredValue) FROM weight"];
	} else {
		// that might not be the case over a limited time frame, though
		statement = [self statementFromSQL:"SELECT MIN(MIN(measuredValue),MIN(trendValue)), MAX(MAX(measuredValue),MAX(trendValue)) FROM weight WHERE monthday BETWEEN ? AND ?"];
		sqlite3_bind_int(statement, 1, beginMonthDay);
		sqlite3_bind_int(statement, 2, endMonthDay);
	}

	int r = sqlite3_step(statement);
	NSAssert1(r == SQLITE_ROW, @"SELECT weight range failed: %s", sqlite3_errmsg(database));
	
	if (sqlite3_column_type(statement, 0) == SQLITE_NULL) {
		*minWeight = 0;
	} else {
		*minWeight = sqlite3_column_double(statement, 0);
	}
	
	if (sqlite3_column_type(statement, 1) == SQLITE_NULL) {
		*maxWeight = 0;
	} else {
		*maxWeight = sqlite3_column_double(statement, 1);
	}
	
	sqlite3_finalize(statement);
}


- (void)getEarliestMonthDay:(EWMonthDay *)beginMonthDay latestMonthDay:(EWMonthDay *)endMonthDay {
	NSParameterAssert(beginMonthDay);
	NSParameterAssert(endMonthDay);
	
	sqlite3_stmt *statement = [self statementFromSQL:"SELECT MIN(monthday),MAX(monthday) FROM weight"];
	int r = sqlite3_step(statement);
	NSAssert1(r == SQLITE_ROW, @"SELECT monthday range failed: %s", sqlite3_errmsg(database));

	if (sqlite3_column_type(statement, 0) == SQLITE_NULL) {
		*beginMonthDay = 0;
	} else {
		*beginMonthDay = sqlite3_column_int(statement, 0);
	}
	
	if (sqlite3_column_type(statement, 1) == SQLITE_NULL) {
		*endMonthDay = 0;
	} else {
		*endMonthDay = sqlite3_column_int(statement, 1);
	}
	
	sqlite3_finalize(statement);
}


- (MonthData *)dataForMonth:(EWMonth)m {
	NSNumber *monthKey = [NSNumber numberWithInt:m];
	[monthCacheLock lock];
	MonthData *monthData = [monthCache objectForKey:monthKey];
	
	if (monthData == nil) {
		monthData = [[MonthData alloc] initWithMonth:m database:self];
		[monthCache setObject:monthData forKey:monthKey];
		[monthData release];

		if (m < earliestMonth) earliestMonth = m;
		if (m > latestMonth) latestMonth = m;
	}

	[monthCacheLock unlock];
	return monthData;
}


- (float)trendWeightOnMonthDay:(EWMonthDay)md {
	MonthData *data = [self dataForMonth:EWMonthDayGetMonth(md)];
	return [data trendWeightOnDay:EWMonthDayGetDay(md)];
}


// Searches for a monthday before the given monthday where weight was recorded.
// Will cross at most one month boundary.
- (EWMonthDay)monthDayOfWeightBefore:(EWMonthDay)mdStart {
	EWMonth monthStop = EWMonthDayGetMonth(mdStart) - 2;
	EWMonthDay md = EWMonthDayPrevious(mdStart);
	MonthData *data = [self dataForMonth:EWMonthDayGetMonth(md)];
	while (monthStop < EWMonthDayGetMonth(md)) {
		if (EWMonthDayGetMonth(md) != data.month) {
			data = [self dataForMonth:EWMonthDayGetMonth(md)];
		}
		if ([data scaleWeightOnDay:EWMonthDayGetDay(md)] > 0) {
			return md;
		}
		md = EWMonthDayPrevious(md);
	}
	return 0;
}


- (EWMonthDay)monthDayOfWeightAfter:(EWMonthDay)mdStart {
	EWMonth monthStop = EWMonthDayGetMonth(mdStart) + 2;
	EWMonthDay md = EWMonthDayNext(mdStart);
	MonthData *data = [self dataForMonth:EWMonthDayGetMonth(md)];
	while (EWMonthDayGetMonth(md) < monthStop) {
		if (EWMonthDayGetMonth(md) != data.month) {
			data = [self dataForMonth:EWMonthDayGetMonth(md)];
		}
		if ([data scaleWeightOnDay:EWMonthDayGetDay(md)] > 0) {
			return md;
		}
		md = EWMonthDayNext(md);
	}
	return 0;
}


- (void)updateTrendValues {
	NSLog(@"Updating trend values after monthday %d", earliestChangeMonthDay);
	if (earliestChangeMonthDay != 0) {
		EWMonth month = EWMonthDayGetMonth(earliestChangeMonthDay);
		EWDay day = EWMonthDayGetDay(earliestChangeMonthDay);
		float trend = 0;
		
		while (month <= latestMonth) {
			MonthData *data = [self dataForMonth:month];
			trend = [data inputTrendOnDay:day];
			if (trend > 0) break;
			day = [data firstDayWithWeight];
			if (day == 0) {
				month += 1;
				day = 1;
			}
		}
		while (month <= latestMonth) {
			MonthData *data = [self dataForMonth:month];
			trend = [data lastTrendValueAfterUpdateStartingOnDay:day withInputTrend:trend];
			month += 1;
			day = 1;
		}
		earliestChangeMonthDay = 0;
	}
}


- (void)commitChanges {
	int changeCount = 0;
	
	[self updateTrendValues];
	[self executeSQL:"BEGIN TRANSACTION"];
	[monthCacheLock lock];
	for (MonthData *md in [monthCache allValues]) {
		if ([md commitChanges]) changeCount++;
	}
	[monthCacheLock unlock];
	[self executeSQL:"COMMIT TRANSACTION"];
	
	if (changeCount > 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:EWDatabaseDidChangeNotification object:self];
	}
}


- (void)flushCache {
	[monthCacheLock lock];
	[monthCache	removeAllObjects];
	[monthCacheLock unlock];
}


- (void)deleteWeights {
	[self flushCache];
	[self executeSQL:"DELETE FROM weight"];
	earliestMonth = EWMonthDayGetMonth(EWMonthDayToday());
	latestMonth = earliestMonth;
	earliestChangeMonthDay = 0;
}


- (void)upgradeIfNeeded {
	int version = [self intValueForMetaName:"dataversion"];
	if (version < 2) {
		NSLog(@"Upgrading database from dataversion %d to 2", version);
		[self flushCache];
		[self executeSQL:"CREATE INDEX IF NOT EXISTS trendValue_index ON weight (trendValue)"];
		[self executeSQL:"DELETE FROM weight WHERE (measuredValue IS NULL) AND (flag = 0) AND (ifnull(length(note),0) = 0)"];
		[self executeSQL:"INSERT INTO metadata VALUES ('dataversion', 2)"];
	}
}


@end
