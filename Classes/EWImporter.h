/*
 * EWImporter.h
 * Created by Benjamin Ragheb on 12/21/09.
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


@class CSVReader;
@class EWImporter;
@class EWDatabase;


NSString * const kEWLastImportKey;
NSString * const kEWLastExportKey;


typedef enum {
	EWImporterFieldDate,
	EWImporterFieldWeight,
	EWImporterFieldFatRatio,
	EWImporterFieldFlag0,
	EWImporterFieldFlag1,
	EWImporterFieldFlag2,
	EWImporterFieldFlag3,
	EWImporterFieldNote,
	EWImporterFieldCount
} EWImporterField;


@protocol EWImporterDelegate
- (void)importer:(EWImporter *)importer importProgress:(float)progress;
- (void)importer:(EWImporter *)importer didImportNumberOfMeasurements:(unsigned int)importedCount outOfNumberOfRows:(unsigned int)rowCount;
@end


@interface EWImporter : NSObject
@property (nonatomic,weak) id <EWImporterDelegate> delegate;
@property (nonatomic) BOOL deleteFirst;
@property (nonatomic,readonly,getter=isImporting) BOOL importing;
@property (nonatomic,readonly) NSArray *columnNames;
@property (nonatomic,readonly) NSDictionary *columnDefaults;
- (id)initWithData:(NSData *)aData encoding:(NSStringEncoding)anEncoding;
- (void)autodetectFields;
- (NSDictionary *)infoForJavaScript;
- (void)setColumn:(NSUInteger)column forField:(EWImporterField)field;
- (void)setFormatter:(NSFormatter *)formatter forField:(EWImporterField)field;
- (BOOL)performImportToDatabase:(EWDatabase *)db;
@end
