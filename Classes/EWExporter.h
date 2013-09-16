//
//  EWExporter.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/18/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>


@class EWDatabase;


typedef enum {
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
} EWExporterField;


NSArray *EWFatFormatterNames();
NSFormatter *EWFatFormatterAtIndex(int index);


@interface EWExporter : NSObject {
	int fieldCount;
	EWExporterField fieldOrder[EWExporterFieldCount];
	NSString *fieldNames[EWExporterFieldCount];
	NSFormatter *fieldFormatters[EWExporterFieldCount];
	NSDate *beginDate;
	NSDate *endDate;
}
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
