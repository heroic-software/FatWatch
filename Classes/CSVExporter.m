//
//  CSVExporter.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/18/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "CSVExporter.h"
#import "CSVWriter.h"


@implementation CSVExporter


- (NSString *)fileExtension {
	return @"csv";
}


- (NSString *)contentType {
	return @"text/csv; charset=utf-8";
}


- (void)exportField:(EWExporterField)field formattedValue:(NSString *)string {
	[writer addString:string];
}


- (void)endRecord {
	[writer endRow];
}


- (NSData *)dataExportedFromDatabase:(EWDatabase *)db {
	writer = [[CSVWriter alloc] init];
		
	// Header Row
	
	for (NSString *name in [self orderedFieldNames]) {
		[writer addString:name];
	}
	[writer endRow];
	
	[self performExportOfDatabase:db];
		
	NSData *data = [writer data];
	
	writer = nil;

	return data;
}


@end
