//
//  SQLiteStatement.h
//  AHamburgerNearby
//
//  Created by Benjamin Ragheb on 1/30/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

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
