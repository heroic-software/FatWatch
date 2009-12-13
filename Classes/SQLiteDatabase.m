//
//  SQLiteDatabase.m
//
//  Created by Benjamin Ragheb on 1/30/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "SQLiteDatabase.h"
#import "SQLiteStatement.h"


@interface SQLiteStatement (Private)
- (id)initWithDatabase:(SQLiteDatabase *)db stmt:(sqlite3_stmt *)stmt;
@end


void SQLiteUpdateHandler(void *user, int op, char const *dbname, char const *tblname,sqlite3_int64 rowid) {
	char *opstr = NULL;
	switch (op) {
		case SQLITE_INSERT:	opstr = "INSERT"; break;
		case SQLITE_DELETE:	opstr = "DELETE"; break;
		case SQLITE_UPDATE: opstr = "UPDATE"; break;
	}
	NSLog(@"SQLite %s %s.%s[%d]", opstr, dbname, tblname, rowid);
}


int SQLiteProgressHandler(void *user) {
	NSLog(@"Makin' Progress!");
	return 0; // return nonzero to cancel operation
}


@implementation SQLiteDatabase


- (id)initWithFile:(NSString *)path {
	if ([self init]) {
		int r = sqlite3_open([path fileSystemRepresentation], &database);
		NSAssert1(r == SQLITE_OK, @"Failed to open database: %s", sqlite3_errmsg(database));
		// sqlite3_update_hook(database, SQLiteUpdateHandler, self);
		// sqlite3_commit_hook()
		// sqlite3_rollback_hook()
		sqlite3_progress_handler(database, 0, SQLiteProgressHandler, self);
	}
	return self;
}


- (id)initInMemory {
	return [self initWithFile:@":memory:"];
}


- (SQLiteStatement *)statementFromSQL:(const char *)sql {
	sqlite3_stmt *stmt;
	
	int r = sqlite3_prepare_v2(database, sql, -1, &stmt, NULL);
	NSAssert2(r == SQLITE_OK, @"Failed to prepare '%s': %s", sql, sqlite3_errmsg(database));

	SQLiteStatement *statement = [[SQLiteStatement alloc] initWithDatabase:self stmt:stmt];
	return [statement autorelease];
}


- (void)executeSQL:(const char *)sql {
	char *errmsg = NULL;
	int r = sqlite3_exec(database, sql, NULL, NULL, &errmsg);
	NSAssert2(r == SQLITE_OK, @"Failed to execute '%s': %s", sql, errmsg);
	if (errmsg != NULL) sqlite3_free(errmsg);
}


- (void)logSQLOfActiveStatements {
	sqlite3_stmt *stmt = NULL;
	int i = 0;
	while (stmt = sqlite3_next_stmt(database, stmt)) {
		NSLog(@"%d: %s", ++i, sqlite3_sql(stmt));
	}
}


- (void)dealloc {
	int r = sqlite3_close(database);
	NSAssert1(r == SQLITE_OK, @"Failed to close database: %s", sqlite3_errmsg(database));
	[super dealloc];
}


@end
