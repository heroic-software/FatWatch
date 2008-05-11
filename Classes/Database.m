//
//  Database.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/7/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "Database.h"
#import "MonthData.h"

static NSString *kWeightDatabaseName = @"WeightData.db";

static sqlite3_stmt *month_before_stmt = nil;
static sqlite3_stmt *month_after_stmt = nil;

NSString *EWStringFromWeightUnit(EWWeightUnit weightUnit)
{
	switch (weightUnit) {
		case kWeightUnitPounds: return @"Pounds";
		case kWeightUnitKilograms: return @"Kilograms";
		default: return @"Unknown Weight Unit";
	}
}

@implementation Database

+ (Database *)sharedDatabase
{
	static Database *db = nil;
	
	if (db == nil) {
		db = [[Database alloc] init];
	}
	return db;
}

@synthesize changeCount;

- (void)ensureDatabaseExists
{
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

- (void)initializeDatabase
{
	// The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSAssert([paths count], @"Failed to find Documents directory.");
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kWeightDatabaseName];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
	}
}

- (id)init
{
	if ([super init]) {
		changeCount = 1;
		monthCache = [[NSMutableDictionary alloc] init];
		[self ensureDatabaseExists];
		[self initializeDatabase];
	} 
	return self;
}

- (void)close
{
	[self commitChanges];
	[monthCache release]; monthCache = nil;
	
	[MonthData finalizeStatements];
	if (month_after_stmt) sqlite3_finalize(month_after_stmt);
	if (month_before_stmt) sqlite3_finalize(month_before_stmt);
	
	if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (void)dealloc
{
	[super dealloc];
}

- (sqlite3_stmt *)statementFromSQL:(const char *)sql
{
	sqlite3_stmt *statement;
	int retCode = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
	NSAssert2(retCode == SQLITE_OK, @"Error: failed to prepare statement '%s' with message '%s'.", sql, sqlite3_errmsg(database));
	return statement;
}

- (EWMonth)earliestMonth
{
	EWMonth dateValue;

	sqlite3_stmt *statement = [self statementFromSQL:"SELECT MIN(month) FROM weight"];
	int code = sqlite3_step(statement);
	NSAssert1(code == SQLITE_ROW, @"SELECT returned code %d", code);
	if (sqlite3_column_type(statement, 0) == SQLITE_NULL) {
		dateValue = EWMonthFromDate([NSDate date]);
	} else {
		dateValue = sqlite3_column_int(statement, 0);
	}
	sqlite3_finalize(statement);
	
	return dateValue;
}

- (NSUInteger)weightCount
{
	NSUInteger count;
	
	sqlite3_stmt *statement = [self statementFromSQL:"SELECT COUNT(*) FROM weight WHERE measuredValue IS NOT NULL"];
	int code = sqlite3_step(statement);
	NSAssert1(code == SQLITE_ROW, @"SELECT returned code %d", code);
	count = sqlite3_column_int(statement, 0);
	sqlite3_finalize(statement);
	
	return count;
}

- (int)intValueForMetaName:(const char *)name
{
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

- (EWWeightUnit)weightUnit
{
	return [self intValueForMetaName:"WeightUnit"];
}

- (void)setWeightUnit:(EWWeightUnit)su
{
	sqlite3_stmt *statement = [self statementFromSQL:"INSERT INTO metadata VALUES (?, ?)"];
	sqlite3_bind_text(statement, 1, "WeightUnit", 10, SQLITE_STATIC);
	sqlite3_bind_int(statement, 2, su);
	int code = sqlite3_step(statement);
	NSAssert1(code == SQLITE_DONE, @"Error: failed to execute statement with message: %s", sqlite3_errmsg(database));
	sqlite3_finalize(statement);
}

- (double)doubleValueFromStatement:(sqlite3_stmt *)statement
{
	int retcode = sqlite3_step(statement);
	NSAssert1(retcode == SQLITE_ROW, @"SELECT returned code %d", retcode);
	if (sqlite3_column_type(statement, 0) == SQLITE_NULL) {
		return 0;
	} else {
		return sqlite3_column_double(statement, 0);
	}
}

- (float)minimumWeight
{
	sqlite3_stmt *statement = [self statementFromSQL:"SELECT MIN(MIN(measuredValue),MIN(trendValue)) FROM weight"];
	float weightValue = [self doubleValueFromStatement:statement];
	sqlite3_finalize(statement);
	return weightValue;
}

- (float)maximumWeight
{
	sqlite3_stmt *statement = [self statementFromSQL:"SELECT MAX(MAX(measuredValue),MAX(trendValue)) FROM weight"];
	float weightValue = [self doubleValueFromStatement:statement];
	sqlite3_finalize(statement);
	return weightValue;
}

- (MonthData *)dataForMonth:(EWMonth)m
{
	NSNumber *monthKey = [NSNumber numberWithInt:m];
	MonthData *monthData = [monthCache objectForKey:monthKey];
	if (monthData != nil) {
		return monthData;
	}
		
	monthData = [[MonthData alloc] initWithMonth:m];
	[monthCache setObject:monthData forKey:monthKey];
	[monthData release];

	return monthData;
}

- (MonthData *)dataForStatement:(sqlite3_stmt *)statement relativeToMonth:(EWMonth)m
{
	EWMonth otherMonth;
	
	sqlite3_bind_int(statement, 1, m);
	int retcode = sqlite3_step(statement);
	if (retcode == SQLITE_ROW) {
		otherMonth = sqlite3_column_int(statement, 0);
	} else if (retcode == SQLITE_DONE) {
		sqlite3_reset(statement);
		return nil;
	} else {
		NSAssert1(0, @"Error: failed to execute statement with message '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_reset(statement);
	
	return [self dataForMonth:otherMonth];
}

- (MonthData *)dataForMonthBefore:(EWMonth)m
{
	if (month_before_stmt == nil) {
		month_before_stmt = [self statementFromSQL:"SELECT month FROM weight WHERE month < ? ORDER BY month DESC LIMIT 1"];
	}
	return [self dataForStatement:month_before_stmt relativeToMonth:m];
}

- (MonthData *)dataForMonthAfter:(EWMonth)m
{
	if (month_after_stmt == nil) {
		month_after_stmt = [self statementFromSQL:"SELECT month FROM weight WHERE month > ? ORDER BY month ASC LIMIT 1"];
	}
	return [self dataForStatement:month_after_stmt relativeToMonth:m];
}

- (void)commitChanges
{
	int code;
	
	sqlite3_stmt *begin_stmt = [self statementFromSQL:"BEGIN TRANSACTION"];
	code = sqlite3_step(begin_stmt);
	NSAssert1(code == SQLITE_DONE, @"Error: failed to begin transaction with message '%s'.", sqlite3_errmsg(database));
	sqlite3_finalize(begin_stmt);
	
	for (MonthData *md in [monthCache allValues]) {
		if ([md commitChanges]) changeCount++;
	}

	sqlite3_stmt *end_stmt = [self statementFromSQL:"COMMIT TRANSACTION"];
	code = sqlite3_step(end_stmt);
	NSAssert1(code == SQLITE_DONE, @"Error: failed to commit transaction with message '%s'.", sqlite3_errmsg(database));
	sqlite3_finalize(end_stmt);
}

- (void)flushCache
{
	[monthCache	removeAllObjects];
	changeCount++;
}

@end
