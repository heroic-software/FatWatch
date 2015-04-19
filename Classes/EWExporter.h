/*
 * EWExporter.h
 * Created by Benjamin Ragheb on 12/18/09.
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


@class EWDatabase;


typedef NS_ENUM(NSInteger, EWExporterField) {
	EWExporterFieldDate,
	EWExporterFieldWeight,
	EWExporterFieldTrendWeight,
	EWExporterFieldFat,
	EWExporterFieldFlag0,
	EWExporterFieldFlag1,
	EWExporterFieldFlag2,
	EWExporterFieldFlag3,
	EWExporterFieldNote,
	EWExporterFieldCount
};


NSArray *EWFatFormatterNames();
NSFormatter *EWFatFormatterAtIndex(int index);


@interface EWExporter : NSObject
@property (nonatomic,strong) NSDate *beginDate;
@property (nonatomic,strong) NSDate *endDate;
// Public API
- (void)addField:(EWExporterField)field name:(NSString *)name formatter:(NSFormatter *)formatter;
- (void)addBackupFields;
- (NSArray *)orderedFieldNames;
- (void)performExportOfDatabase:(EWDatabase *)db;
// Optional Override
- (void)beginRecord;
- (void)endRecord;
- (void)exportField:(EWExporterField)field value:(id)value;
// Mandatory Override
- (NSString *)fileExtension;
- (NSString *)contentType;
- (void)exportField:(EWExporterField)field formattedValue:(NSString *)string;
- (NSData *)dataExportedFromDatabase:(EWDatabase *)db;
@end
