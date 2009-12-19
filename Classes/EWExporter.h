//
//  EWExporter.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/18/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	EWExporterFieldDate,
	EWExporterFieldWeight,
	EWExporterFieldTrendWeight,
	EWExporterFieldFat,
	EWExporterFieldFlag1,
	EWExporterFieldFlag2,
	EWExporterFieldFlag3,
	EWExporterFieldFlag4,
	EWExporterFieldNote,
	EWExporterFieldCount
} EWExporterField;


@interface EWExporter : NSObject {
	NSString *fieldNames[EWExporterFieldCount];
	NSFormatter *fieldFormatters[EWExporterFieldCount];
}
- (NSString *)fileExtension;
- (NSString *)contentType;
- (void)addField:(EWExporterField)field name:(NSString *)name formatter:(NSFormatter *)formatter;
- (NSData *)exportedData;
@end
