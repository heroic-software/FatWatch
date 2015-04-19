/*
 * SQLiteStatement.h
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

#import <Foundation/Foundation.h>
#import "/usr/include/sqlite3.h"


@class SQLiteDatabase;


@interface SQLiteStatement : NSObject
// Parameters are 1-based indexes
- (void)bindInt:(int)value toParameter:(int)param;
- (void)bindInt64:(sqlite_int64)value toParameter:(int)param;
- (void)bindDouble:(double)value toParameter:(int)param;
- (void)bindString:(NSString *)value toParameter:(int)param;
- (void)bindNullToParameter:(int)param;
- (BOOL)step;
// Columns are 0-based indexes
- (BOOL)isNullColumn:(int)column;
- (NSString *)stringValueOfColumn:(int)column;
- (int)intValueOfColumn:(int)column;
- (double)doubleValueOfColumn:(int)column;
- (float)floatValueOfColumn:(int)column;
- (void)reset;
@end
