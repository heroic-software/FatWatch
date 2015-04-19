/*
 * CSVExporter.m
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

#import "CSVExporter.h"
#import "CSVWriter.h"


@implementation CSVExporter
{
	CSVWriter *writer;
}

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
