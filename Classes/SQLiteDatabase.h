//
//  SQLiteDatabase.h
//
//  Created by Benjamin Ragheb on 1/30/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "/usr/include/sqlite3.h"
#import "SQLiteStatement.h"


@interface SQLiteDatabase : NSObject {
	sqlite3 *database;
}
- (id)initWithFile:(NSString *)path;
- (id)initInMemory;
- (SQLiteStatement *)statementFromSQL:(const char *)sql;
- (void)executeSQL:(const char *)sql;
@end
