//
//  EWExporter.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/18/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "EWExporter.h"


@implementation EWExporter

- (NSString *)fileExtension {
	return nil;
}


- (NSString *)contentType {
	return nil;
}


- (void)addField:(EWExporterField)field name:(NSString *)name formatter:(NSFormatter *)formatter {
	fieldNames[field] = [name copy];
	fieldFormatters[field] = [formatter retain];
}


- (NSData *)exportedData {
	return nil;
}


- (void)dealloc {
	int i;
	for (i = 0; i < EWExporterFieldCount; i++) {
		[fieldNames[i] release];
		[fieldFormatters[i] release];
	}
	[super dealloc];
}

@end
