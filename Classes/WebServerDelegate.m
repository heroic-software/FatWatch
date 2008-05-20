//
//  WebServerDelegate.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/17/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "WebServerDelegate.h"
#import "MonthData.h"
#import "CSVWriter.h"
#import "CSVReader.h"
#import "MicroWebServer.h"
#import "Database.h"
#import "FormDataParser.h"

@implementation WebServerDelegate

- (NSDateFormatter *)dateFormatter {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	return [formatter autorelease];
}


- (void)handleExport:(MicroWebConnection *)connection {
	CSVWriter *writer = [[CSVWriter alloc] init];
	
	NSDateFormatter *formatter = [self dateFormatter];
	
	Database *db = [Database sharedDatabase];
	MonthData *md = [db dataForMonth:[db earliestMonth]];
	while (md != nil) {
		EWDay day;
		for (day = 1; day <= 31; day++) {
			float measuredWeight = [md measuredWeightOnDay:day];
			NSString *note = [md noteOnDay:day];
			BOOL flag = [md isFlaggedOnDay:day];
			if (measuredWeight > 0 || note != nil || flag) {
				[writer addString:[formatter stringFromDate:[md dateOnDay:day]]];
				[writer addFloat:measuredWeight];
				[writer addFloat:[md trendWeightOnDay:day]];
				[writer addBoolean:flag];
				[writer addString:note];
				[writer endRow];
			}
		}
		md = [db dataForMonthAfter:md.month];
	}
	
	[connection setResponseStatus:200];
	[connection setValue:@"text/csv" forResponseHeader:@"Content-Type"];
	[connection setResponseBodyData:[writer data]];
	[writer release];
	return;
}


- (void)handleImport:(MicroWebConnection *)connection {
	FormDataParser *form = [[FormDataParser alloc] initWithConnection:connection];
	
	NSData *filedata = [form dataForKey:@"filedata"];
	NSString *how = [form stringForKey:@"how"];
	
	NSMutableString *text = [[NSMutableString alloc] init];

	if ([how isEqualToString:@"replace"]) {
		// delete everything
		[text appendString:@"Existing records deleted.\r\n"];
	}
	
	NSUInteger count = 0;

	CSVReader *reader = [[CSVReader alloc] initWithData:filedata];
	NSDateFormatter *formatter = [self dateFormatter];
	const Database *db = [Database sharedDatabase];

	while ([reader nextRow]) {
		NSString *dateString = [reader readString];
		float measuredWeight = [reader readFloat];
		[reader readFloat]; // skip trendWeight
		BOOL flag = [reader readBoolean];
		NSString *note = [reader readString];
		
		NSDate *date = [formatter dateFromString:dateString];
		
		EWMonth month = EWMonthFromDate(date);
		EWDay day = EWDayFromDate(date);
		MonthData *md = [db dataForMonth:month];
		// inefficient, should wait until done to recompute trends
		[md setMeasuredWeight:measuredWeight flag:flag note:note onDay:day];
		count++;
	}
 
	[reader release];

	[text appendFormat:@"Imported %d records.\r\n", count];

	[form release];
	
	[connection setResponseStatus:200];
	[connection setValue:@"text/plain" forResponseHeader:@"Content-Type"];
	[connection setResponseBodyString:text];
	[text release];
	return;
}


- (void)sendResourceNamed:(NSString *)name to:(MicroWebConnection *)connection {
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"html"];
	if (path) {
		[connection setResponseStatus:200];
		[connection setValue:@"text/html" forResponseHeader:@"Content-Type"];
		[connection setResponseBodyData:[NSData dataWithContentsOfFile:path]];
	}
}


- (void)handleWebConnection:(MicroWebConnection *)connection {
	NSString *path = [[connection requestURL] path];
	
	printf("%s <%s>\n", [[connection requestMethod] UTF8String], [path UTF8String]);
	
	if ([path isEqualToString:@"/"]) {
		[self sendResourceNamed:@"home" to:connection];
		return;
	}
	
	if ([path hasPrefix:@"/export/"]) {
		[self handleExport:connection];
		return;
	}
	
	if ([path isEqualToString:@"/import"]) {
		[self handleImport:connection];
		return;
	}
	
	// handle robots.txt
	
	[connection setResponseStatus:404];
	[connection setValue:@"text/plain" forResponseHeader:@"Content-Type"];
	[connection setResponseBodyString:@"Not Found"];
}

@end
