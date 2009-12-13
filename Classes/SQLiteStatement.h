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


@interface SQLiteStatement : NSObject {
	SQLiteDatabase *database;
	sqlite3_stmt *statement;
}
- (void)bindInt:(int)value toParameter:(int)param;
- (void)bindDouble:(double)value toParameter:(int)param;
- (void)bindString:(NSString *)value toParameter:(int)param;
- (void)bindNullToParameter:(int)param;
- (BOOL)step;
- (BOOL)isNullColumn:(int)column;
- (NSString *)stringValueOfColumn:(int)column;
- (int)intValueOfColumn:(int)column;
- (double)doubleValueOfColumn:(int)column;
- (void)reset;
@end
