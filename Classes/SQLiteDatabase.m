//
//  SQLiteDatabase.m
//
//  Created by Benjamin Ragheb on 1/30/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SQLiteDatabase.h"
#import "SQLiteStatement.h"


@interface SQLiteStatement ()
- (id)initWithDatabase:(SQLiteDatabase *)db stmt:(sqlite3_stmt *)stmt;
- (void)didReceiveMemoryWarning:(NSNotification *)notification;
@end


#pragma mark Callback Functions


void SQLiteUpdateHandler(void *user, int op, char const *dbname, char const *tblname,sqlite3_int64 rowid) {
	SQLiteDatabase *db = user;
	NSString *dbNameString = [[NSString alloc] initWithFormat:@"%s", dbname];
	NSString *tblNameString = [[NSString alloc] initWithFormat:@"%s", tblname];
	[db.delegate didUpdateSQLiteDatabase:db name:dbNameString table:tblNameString row:rowid operation:op];
	[dbNameString release];
	[tblNameString release];
}


int SQLiteCommitHandler(void *user) {
	SQLiteDatabase *db = user;
	return [db.delegate shouldCommitQuerySQLiteDatabase:db] ? 0 : 1;
}


void SQLiteRollbackHandler(void *user) {
	SQLiteDatabase *db = user;
	[db.delegate didRollbackQuerySQLiteDatabase:db];
}


int SQLiteProgressHandler(void *user) {
	SQLiteDatabase *db = user;
	return [db.delegate shouldContinueQuerySQLiteDatabase:db] ? 0 : 1;
}


@implementation SQLiteDatabase


@synthesize delegate;


- (id)initWithFile:(NSString *)path {
	if ([self init]) {
		int r = sqlite3_open([path fileSystemRepresentation], &database);
		NSAssert1(r == SQLITE_OK, @"Failed to open database: %s", sqlite3_errmsg(database));
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	return self;
}


- (id)initInMemory {
	return [self initWithFile:@":memory:"];
}


- (void)setDelegate:(id <SQLiteDatabaseDelegate>)del {
	if (delegate == del) return;
	delegate = del;
	
	if ([delegate respondsToSelector:@selector(didUpdateSQLiteDatabase:name:table:row:operation:)]) {
		sqlite3_update_hook(database, SQLiteUpdateHandler, self);
	} else {
		sqlite3_update_hook(database, NULL, NULL);
	}
	
	if ([delegate respondsToSelector:@selector(shouldContinueQuerySQLiteDatabase:)]) {
		sqlite3_progress_handler(database, 20, SQLiteProgressHandler, self);
	} else {
		sqlite3_progress_handler(database, 0, NULL, NULL);
	}
	
	if ([delegate respondsToSelector:@selector(shouldCommitQuerySQLiteDatabase:)]) {
		sqlite3_commit_hook(database, SQLiteCommitHandler, self);
	} else {
		sqlite3_commit_hook(database, NULL, NULL);
	}
	
	if ([delegate respondsToSelector:@selector(didRollbackQuerySQLiteDatabase:)]) {
		sqlite3_rollback_hook(database, SQLiteRollbackHandler, self);
	} else {
		sqlite3_rollback_hook(database, NULL, NULL);
	}
}


- (SQLiteStatement *)statementFromSQL:(const char *)sql {
	sqlite3_stmt *stmt;
	
	int r = sqlite3_prepare_v2(database, sql, -1, &stmt, NULL);
	NSAssert2(r == SQLITE_OK, 
			  @"Error '%s' while compiling SQL \"%s\"", 
			  sqlite3_errmsg(database), 
			  sql);

	return [[[SQLiteStatement alloc] initWithDatabase:self stmt:stmt] autorelease];
}


- (void)executeSQL:(const char *)sql {
	char *errmsg = NULL;
	int r = sqlite3_exec(database, sql, NULL, NULL, &errmsg);
	NSAssert2(r == SQLITE_OK, @"Failed to execute '%s': %s", sql, errmsg);
	if (errmsg != NULL) sqlite3_free(errmsg);
}


- (void)beginTransaction {
	[self executeSQL:"BEGIN"];
}


- (void)commitTransaction {
	[self executeSQL:"END"];
}


- (sqlite3_int64)lastInsertRowID {
	return sqlite3_last_insert_rowid(database);
}


- (void)didReceiveMemoryWarning:(NSNotification *)notification {
	int freed = sqlite3_release_memory(0x7fffffff);
	NSLog(@"SQLiteDatabase %p freed %d bytes", self, freed);
}


- (NSString *)description {
	NSMutableString *out = [NSMutableString string];
	
	[out appendFormat:@"<SQLiteDatabase:%p", self];
	
	int i = 0;
	sqlite3_stmt *stmt = NULL;
	while ((stmt = sqlite3_next_stmt(database, stmt))) {
		[out appendFormat:@"\n  %2d: \"%s\"", ++i, sqlite3_sql(stmt)];
	}
	
	[out appendString:@">"];
	
	return out;
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	int r = sqlite3_close(database);
	NSAssert1(r == SQLITE_OK, @"Failed to close database: %s", sqlite3_errmsg(database));
	[super dealloc];
}


@end
