//
//  SQLiteStatement.m
//  AHamburgerNearby
//
//  Created by Benjamin Ragheb on 1/30/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "SQLiteStatement.h"
#import "SQLiteDatabase.h"


@implementation SQLiteStatement


- (id)initWithDatabase:(SQLiteDatabase *)db stmt:(sqlite3_stmt *)stmt {
	if ((self = [super init])) {
		database = db;
		statement = stmt;
	}
	return self;
}


- (void)bindInt:(int)value toParameter:(int)param {
	int r = sqlite3_bind_int(statement, param, value);
	NSAssert1(r == SQLITE_OK, @"SQLite bind_int error: %d", r);
}


- (void)bindInt64:(sqlite_int64)value toParameter:(int)param {
	int r = sqlite3_bind_int64(statement, param, value);
	NSAssert1(r == SQLITE_OK, @"SQLite bind_int64 error: %d", r);
}


- (void)bindDouble:(double)value toParameter:(int)param {
	int r = sqlite3_bind_double(statement, param, value);
	NSAssert1(r == SQLITE_OK, @"SQLite bind_double error: %d", r);
}


- (void)bindString:(NSString *)value toParameter:(int)param {
	int r;
	if ([value length] > 0) {
		NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
		r = sqlite3_bind_text(statement, param, [data bytes], [data length], SQLITE_STATIC);
	} else {
		r = sqlite3_bind_null(statement, param);
	}
	NSAssert4(r == SQLITE_OK,
			  @"SQLite bind(%@,%d) = %d (%s)", 
			  value,
			  param,
			  r,
			  sqlite3_errmsg(sqlite3_db_handle(statement)));
}


- (void)bindNullToParameter:(int)param {
	int r = sqlite3_bind_null(statement, param);
	NSAssert1(r == SQLITE_OK, @"SQLite bind_text error: %d", r);
}


- (BOOL)step {
	int r = sqlite3_step(statement);
	if (r == SQLITE_ROW) {
		return YES;
	} else if (r == SQLITE_DONE) {
		[self reset];
		return NO;
	}
	NSAssert1(NO, @"SQLite step error: %d", r);
	return NO;
}


- (BOOL)isNullColumn:(int)column {
	int t = sqlite3_column_type(statement, column);
	return (t == SQLITE_NULL);
}


- (NSString *)stringValueOfColumn:(int)column {
	const unsigned char *text = sqlite3_column_text(statement, column);
	if (text == NULL) return nil;
	return @((const char *)text);
}


- (int)intValueOfColumn:(int)column {
	return sqlite3_column_int(statement, column);
}


- (double)doubleValueOfColumn:(int)column {
	return sqlite3_column_double(statement, column);
}


- (float)floatValueOfColumn:(int)column {
	return (float)sqlite3_column_double(statement, column);
}


- (void)reset {
	int r;
	r = sqlite3_clear_bindings(statement);
	NSAssert1(r == SQLITE_OK, @"SQLite clear_bindings error: %d", r);
	r = sqlite3_reset(statement);
	NSAssert1(r == SQLITE_OK, @"SQLite reset error: %d", r);
}


- (NSString *)description {
	const char *sql = sqlite3_sql(statement);
	return [NSString stringWithFormat:@"<SQLiteStatement:%s>", sql];
}


- (void)dealloc {
	sqlite3_finalize(statement);
	statement = NULL;
}


@end
