/*
 * SQLiteStatement.m
 * Created by Benjamin Ragheb on 1/30/09.
 * Copyright 2015 Heroic Software Inc
 *
 * This file is part of FatWatch.
 *
 * FatWatch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FatWatch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "SQLiteStatement.h"
#import "SQLiteDatabase.h"


@implementation SQLiteStatement
{
	SQLiteDatabase *database;
	sqlite3_stmt *statement;
}

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
		r = sqlite3_bind_text(statement, param, [data bytes], (int)[data length], SQLITE_STATIC);
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
