/*
 * SQLiteDatabase.h
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
#import "SQLiteStatement.h"


@protocol SQLiteDatabaseDelegate <NSObject>
@optional
- (void)didUpdateSQLiteDatabase:(SQLiteDatabase *)db name:(NSString *)dbName table:(NSString *)tblName row:(sqlite3_int64)row operation:(int)op;
- (BOOL)shouldContinueQuerySQLiteDatabase:(SQLiteDatabase *)db;
- (BOOL)shouldCommitQuerySQLiteDatabase:(SQLiteDatabase *)db;
- (void)didRollbackQuerySQLiteDatabase:(SQLiteDatabase *)db;
@end


@interface SQLiteDatabase : NSObject
@property (nonatomic,weak) id <SQLiteDatabaseDelegate> delegate;
- (id)initWithFile:(NSString *)path;
- (id)initInMemory;
- (SQLiteStatement *)statementFromSQL:(const char *)sql;
- (void)executeSQL:(const char *)sql;
- (void)beginTransaction;
- (void)commitTransaction;
- (sqlite3_int64)lastInsertRowID;
@end
