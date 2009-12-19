//
//  CSVExporter.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/18/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "CSVExporter.h"
#import "CSVWriter.h"
#import "EWDatabase.h"
#import "EWDBMonth.h"
#import "WeightFormatters.h"


@implementation CSVExporter


- (NSString *)fileExtension {
	return @"csv";
}


- (NSString *)contentType {
	return @"text/csv; charset=utf-8";
}


- (void)exportField:(EWExporterField)field value:(id)object {
	if (fieldNames[field] == nil) return;
	NSFormatter *fmtr = fieldFormatters[field];
	if (fmtr) {
		[writer addString:[fmtr stringForObjectValue:object]];
	} else {
		[writer addString:[object description]];
	}
}


- (NSData *)exportedData {
	writer = [[CSVWriter alloc] init];
	
	int f;
	
	// Header Row
	
	for (f = 0; f < EWExporterFieldCount; f++) {
		if (fieldNames[f]) {
			[writer addString:fieldNames[f]];
		}
	}
	[writer endRow];
	
	EWDatabase *db = [EWDatabase sharedDatabase];
	EWDBMonth *dbm = [db getDBMonth:db.earliestMonth];
	while (dbm) {
		// Avoid NSNumber pile up
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		EWDay day;
		for (day = 1; day <= 31; day++) {
			if ([dbm hasDataOnDay:day]) {
				struct EWDBDay *dd = [dbm getDBDay:day];
				
				[self exportField:EWExporterFieldDate 
							value:[dbm dateOnDay:day]];
				[self exportField:EWExporterFieldWeight 
							value:[NSNumber numberWithFloat:dd->scaleWeight]];
				[self exportField:EWExporterFieldTrendWeight
							value:[NSNumber numberWithFloat:dd->trendWeight]];
				[self exportField:EWExporterFieldFat
							value:[NSNumber numberWithFloat:dd->scaleFat]];
				[self exportField:EWExporterFieldFlag1
							value:[NSNumber numberWithInt:dd->flags]];
				[self exportField:EWExporterFieldFlag2
							value:[NSNumber numberWithInt:dd->flags]];
				[self exportField:EWExporterFieldFlag3
							value:[NSNumber numberWithInt:dd->flags]];
				[self exportField:EWExporterFieldFlag4
							value:[NSNumber numberWithInt:dd->flags]];
				[self exportField:EWExporterFieldNote
							value:dd->note];
				
				[writer endRow];
			}
		}
		dbm = dbm.next;
		[pool release];
	}
	
	NSData *data = [[writer data] retain];
	
	[writer release];
	writer = nil;

	return [data autorelease];
}


@end
