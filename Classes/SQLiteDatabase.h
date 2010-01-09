//
//  SQLiteDatabase.h
//
//  Created by Benjamin Ragheb on 1/30/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "/usr/include/sqlite3.h"
#import "SQLiteStatement.h"


@protocol SQLiteDatabaseDelegate <NSObject>
@optional
- (void)didUpdateSQLiteDatabase:(SQLiteDatabase *)db name:(NSString *)dbName table:(NSString *)tblName row:(sqlite3_int64)row operation:(int)op;
- (BOOL)shouldContinueQuerySQLiteDatabase:(SQLiteDatabase *)db;
- (BOOL)shouldCommitQuerySQLiteDatabase:(SQLiteDatabase *)db;
- (void)didRollbackQuerySQLiteDatabase:(SQLiteDatabase *)db;
@end


@interface SQLiteDatabase : NSObject {
	sqlite3 *database;
	id <SQLiteDatabaseDelegate> delegate;
}
@property (nonatomic,assign) id <SQLiteDatabaseDelegate> delegate;
- (id)initWithFile:(NSString *)path;
- (id)initInMemory;
- (SQLiteStatement *)statementFromSQL:(const char *)sql;
- (void)executeSQL:(const char *)sql;
- (void)beginTransaction;
- (void)commitTransaction;
- (int)lastInsertRowID;
@end
