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
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
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

- (void)dealloc
{
	[monthCache release];
	if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
	[super dealloc];
}

- (EWMonth)earliestMonth
{
	EWMonth dateValue;

	const char *sql = "SELECT month FROM weight ORDER BY month ASC LIMIT 1";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			dateValue = sqlite3_column_int(statement, 0);
		}
	}
	sqlite3_finalize(statement);
	
	return dateValue;
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

	const char *sql = "SELECT * FROM weight WHERE month = ?";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, m);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *noteStr = (char *)sqlite3_column_text(statement, 5);
			[monthData loadMeasuredWeight:sqlite3_column_double(statement, 2)
							  trendWeight:sqlite3_column_double(statement, 3)
								  flagged:(sqlite3_column_int(statement, 4) != 0)
									 note:(noteStr ? [NSString stringWithUTF8String:noteStr] : nil)
								   forDay:sqlite3_column_int(statement, 1)];
		}
	}
	sqlite3_finalize(statement);
	
	return monthData;
}

@end
