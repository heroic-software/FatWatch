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

@implementation Database

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
	
	if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (void)dealloc
{
	[super dealloc];
}

- (sqlite3_stmt *)prepareStatement:(const char *)sql
{
	sqlite3_stmt *statement;
	int retCode = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
	NSAssert2(retCode == SQLITE_OK, @"Error: failed to prepare statement '%s' with message '%s'.", sql, sqlite3_errmsg(database));
	return statement;
}

- (EWMonth)earliestMonth
{
	EWMonth dateValue;

	sqlite3_stmt *statement = [self prepareStatement:"SELECT MIN(month) FROM weight"];
	int retcode = sqlite3_step(statement);
	if (retcode == SQLITE_ROW) {
		dateValue = sqlite3_column_int(statement, 0);
	} else if (retcode == SQLITE_DONE) {
		dateValue = EWMonthFromDate([NSDate date]);
	} else {
		NSAssert1(0, @"SELECT returned code %d", retcode);
	}
	sqlite3_finalize(statement);
	
	return dateValue;
}

- (double)doubleValueFromStatement:(sqlite3_stmt *)statement
{
	int retcode = sqlite3_step(statement);
	if (retcode == SQLITE_ROW) {
		return sqlite3_column_double(statement, 0);
	} else if (retcode == SQLITE_DONE) {
		return 0;
	} else {
		NSAssert1(0, @"SELECT returned code %d", retcode);
		return 0;
	}
}

- (float)minimumWeight
{
	sqlite3_stmt *statement = [self prepareStatement:"SELECT MIN(MIN(measuredValue),MIN(trendValue)) FROM weight"];
	float weightValue = [self doubleValueFromStatement:statement];
	sqlite3_finalize(statement);
	return weightValue;
}

- (float)maximumWeight
{
	sqlite3_stmt *statement = [self prepareStatement:"SELECT MAX(MAX(measuredValue),MAX(trendValue)) FROM weight"];
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
		
	monthData = [[MonthData alloc] initWithDatabase:self month:m];
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
		sqlite3_finalize(statement);
		return nil;
	} else {
		NSAssert1(0, @"Error: failed to execute statement with message '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_finalize(statement);
	
	return [self dataForMonth:otherMonth];
}

- (MonthData *)dataForMonthBefore:(EWMonth)m
{
	sqlite3_stmt *statement = [self prepareStatement:"SELECT month FROM weight WHERE month < ? ORDER BY month DESC LIMIT 1"];
	MonthData *data = [self dataForStatement:statement relativeToMonth:m];
	sqlite3_finalize(statement);
	return data;
}

- (MonthData *)dataForMonthAfter:(EWMonth)m
{
	sqlite3_stmt *statement = [self prepareStatement:"SELECT month FROM weight WHERE month > ? ORDER BY month ASC LIMIT 1"];
	MonthData *data = [self dataForStatement:statement relativeToMonth:m];
	sqlite3_finalize(statement);
	return data;
}

- (float)slopeForPastDays:(NSUInteger)dayCount
{
	EWMonth curMonth = EWMonthFromDate([NSDate date]);
	EWDay curDay = EWDayFromDate([NSDate date]);
	MonthData *data = [self dataForMonth:curMonth];
	
	double sumX = 0, sumY = 0, sumXsquared = 0, sumXY = 0;
	double n = 0;
	
	float x;
	for (x = 0; x < dayCount; x++) {
		float y = [data measuredWeightOnDay:curDay];
		
		if (y > 0) {
			sumX += x;
			sumY += y;
			sumXsquared += x * x;
			sumXY += x * y;
			n++;
		}

		curDay--;
		if (curDay < 1) {
			curMonth--;
			curDay = EWDaysInMonth(curMonth);
			data = [self dataForMonth:curMonth];
		}
	}
		
	double Sxx = sumXsquared - sumX * sumX / n;
	double Sxy = sumXY - sumX * sumY / n;
	
	return Sxy / Sxx;
}

- (void)commitChanges
{
	[[monthCache allValues] makeObjectsPerformSelector:@selector(commitChanges)];
}

@end
