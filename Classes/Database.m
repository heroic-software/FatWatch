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

static NSString *kWeightDatabaseName = @"WeightData.db";

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
		monthCache = [[NSMutableDictionary alloc] init];
	} 
	return self;
}


- (void)ensureDatabaseExists {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
#pragma mark Begin Workaround: create application "Documents" directory if needed
    // Workaround for Beta issue where Documents directory is not created during install.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSAssert([paths count], @"Failed to find Documents directory.");
    NSString *documentsDirectory = [paths objectAtIndex:0];
    BOOL exists = [fileManager fileExistsAtPath:documentsDirectory];
    if (!exists) {
        BOOL success = [fileManager createDirectoryAtPath:documentsDirectory attributes:nil];
        if (!success) {
            NSAssert(0, @"Failed to create Documents directory.");
        }
    }
#pragma mark End Workaround
    
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:kWeightDatabaseName];
	
    BOOL dbExists = [fileManager fileExistsAtPath:writableDBPath];
	if (!dbExists) {
		NSLog(@"Database file not found, creating a new database.");
	}
    
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	BOOL forceReset = [defs boolForKey:@"OnLaunchResetDatabase"];
	if (forceReset && dbExists) {
		NSLog(@"Database reset requested, creating a new database.");
		success = [fileManager removeItemAtPath:writableDBPath error:&error];
		if (!success) {
			NSAssert1(0, @"Failed to delete existing database file with message '%@'.", [error localizedDescription]);
		}
	}
	[defs removeObjectForKey:@"OnLaunchResetDatabase"];
	
	if (dbExists && !forceReset) return;
	
	NSLog(@"Can't find database, copying default into place.");
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kWeightDatabaseName];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}


- (void)openAtPath:(NSString *)path {
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
	}

	earliestChangeMonthDay = 0;
	EWMonth currentMonth = EWMonthDayGetMonth(EWMonthDayFromDate([NSDate date]));
	
	sqlite3_stmt *statement = [self statementFromSQL:"SELECT MIN(monthday),MAX(monthday) FROM weight"];
	int code = sqlite3_step(statement);
	NSAssert1(code = SQLITE_ROW, @"SELECT returned code %d", code);
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


- (void)open {
	[self ensureDatabaseExists];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSAssert([paths count] > 0, @"Failed to find Documents directory.");
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kWeightDatabaseName];
	[self openAtPath:path];
}


- (void)close {
	[self commitChanges];
	[monthCache removeAllObjects];
	
	[MonthData finalizeStatements];
	EWFinalizeStatement(&month_after_stmt);
	EWFinalizeStatement(&month_before_stmt);
	
	if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
}


- (void)dealloc {
	[monthCache release];
	[super dealloc];
}


- (sqlite3_stmt *)statementFromSQL:(const char *)sql {
	sqlite3_stmt *statement;
	int retCode = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
	NSAssert2(retCode == SQLITE_OK, @"Error: failed to prepare statement '%s' with message '%s'.", sql, sqlite3_errmsg(database));
	return statement;
}


- (NSUInteger)weightCount {
	NSUInteger count;
	
	sqlite3_stmt *statement = [self statementFromSQL:"SELECT COUNT(*) FROM weight WHERE measuredValue IS NOT NULL"];
	int code = sqlite3_step(statement);
	NSAssert1(code == SQLITE_ROW, @"SELECT returned code %d", code);
	count = sqlite3_column_int(statement, 0);
	sqlite3_finalize(statement);
	
	return count;
}


- (int)intValueForMetaName:(const char *)name {
	int value = 0;
	
	sqlite3_stmt *statement = [self statementFromSQL:"SELECT value FROM metadata WHERE name = ?"];
	sqlite3_bind_text(statement, 1, name, strlen(name), SQLITE_STATIC);
	int retCode = sqlite3_step(statement);
	if (retCode == SQLITE_ROW) {
		value = sqlite3_column_int(statement, 0);
	} else if (retCode == SQLITE_DONE) {
		value = 0;
	} else {
		NSAssert1(0, @"SELECT returned code %d", retCode);
	}
	sqlite3_finalize(statement);

	return value;
}


- (void)didChangeWeightOnMonthDay:(EWMonthDay)monthday {
	if ((earliestChangeMonthDay == 0) || (monthday < earliestChangeMonthDay)) {
		earliestChangeMonthDay = monthday;
	}
}


- (double)doubleValueFromStatement:(sqlite3_stmt *)statement {
	int retcode = sqlite3_step(statement);
	NSAssert1(retcode == SQLITE_ROW, @"SELECT returned code %d", retcode);
	if (sqlite3_column_type(statement, 0) == SQLITE_NULL) {
		return 0;
	} else {
		return sqlite3_column_double(statement, 0);
	}
}


- (float)minimumWeight {
	sqlite3_stmt *statement = [self statementFromSQL:"SELECT MIN(measuredValue) FROM weight"];
	float weightValue = [self doubleValueFromStatement:statement];
	sqlite3_finalize(statement);
	return weightValue;
}


- (float)maximumWeight {
	sqlite3_stmt *statement = [self statementFromSQL:"SELECT MAX(measuredValue) FROM weight"];
	float weightValue = [self doubleValueFromStatement:statement];
	sqlite3_finalize(statement);
	return weightValue;
}


- (MonthData *)dataForMonth:(EWMonth)m {
	NSNumber *monthKey = [NSNumber numberWithInt:m];
	MonthData *monthData = [monthCache objectForKey:monthKey];
	if (monthData != nil) {
		return monthData;
	}
		
	monthData = [[MonthData alloc] initWithMonth:m];
	[monthCache setObject:monthData forKey:monthKey];
	[monthData release];

	if (m < earliestMonth) earliestMonth = m;
	if (m > latestMonth) latestMonth = m;

	return monthData;
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


- (void)executeSQL:(const char *)sql {
	sqlite3_stmt *stmt = [self statementFromSQL:sql];
	int code = sqlite3_step(stmt);
	NSAssert2(code == SQLITE_DONE, @"Error: failed to execute '%s' with message '%s'.", sql, sqlite3_errmsg(database));
	sqlite3_finalize(stmt);
}


- (void)commitChanges {
	int changeCount = 0;
	
	[self updateTrendValues];
	[self executeSQL:"BEGIN TRANSACTION"];
	for (MonthData *md in [monthCache allValues]) {
		if ([md commitChanges]) changeCount++;
	}
	[self executeSQL:"COMMIT TRANSACTION"];
	
	if (changeCount > 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:EWDatabaseDidChangeNotification object:self];
	}
}


- (void)flushCache {
	[monthCache	removeAllObjects];
}


- (void)deleteWeights {
	[self flushCache];
	[self executeSQL:"DELETE FROM weight"];
	earliestMonth = EWMonthDayGetMonth(EWMonthDayFromDate([NSDate date]));
	latestMonth = earliestMonth;
	earliestChangeMonthDay = 0;
}

@end
