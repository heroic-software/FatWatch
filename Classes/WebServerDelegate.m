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
#import "WeightFormatter.h"

#define HTTP_STATUS_OK 200
#define HTTP_STATUS_NOT_FOUND 404

@interface WebServerDelegate ()
- (NSDateFormatter *)dateFormatter;
- (void)handleExport:(MicroWebConnection *)connection;
- (void)handleImport:(MicroWebConnection *)connection;
- (void)performImport;
- (void)sendResourceNamed:(NSString *)name withSubstitutions:(NSDictionary *)substitutions toConnection:(MicroWebConnection *)connection;
@end



@implementation WebServerDelegate


- (void)handleWebConnection:(MicroWebConnection *)connection {
	NSString *path = [[connection requestURL] path];
	
	printf("%s <%s>\n", [[connection requestMethod] UTF8String], [path UTF8String]);
	
	if ([path isEqualToString:@"/"]) {
		UIDevice *device = [UIDevice currentDevice];
		NSDictionary *subst = [NSDictionary dictionaryWithObjectsAndKeys:
							   [device name], @"__NAME__",
							   nil];
		[self sendResourceNamed:@"home" withSubstitutions:subst toConnection:connection];
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
	
	// handle robots.txt, favicon.ico
	
	[connection setResponseStatus:HTTP_STATUS_NOT_FOUND];
	[connection setValue:@"text/plain" forResponseHeader:@"Content-Type"];
	[connection setResponseBodyString:@"Not Found"];
}


- (void)sendResourceNamed:(NSString *)name withSubstitutions:(NSDictionary *)substitutions toConnection:(MicroWebConnection *)connection {
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"html"];

	if (path == nil) {
		[connection setResponseStatus:HTTP_STATUS_NOT_FOUND];
		[connection setValue:@"text/plain" forResponseHeader:@"Content-Type"];
		[connection setResponseBodyString:[NSString stringWithFormat:@"Resource '%@' Not Found", name]];
		return;
	}
	
	NSMutableString *text = [[NSMutableString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

	for (NSString *key in [substitutions allKeys]) {
		[text replaceOccurrencesOfString:key
							  withString:[substitutions objectForKey:key]
								 options:0
								   range:NSMakeRange(0, [text length])];
	}
	
	[connection setResponseStatus:HTTP_STATUS_OK];
	[connection setValue:@"text/html" forResponseHeader:@"Content-Type"];
	[connection setResponseBodyData:[text dataUsingEncoding:NSUTF8StringEncoding]];
	
	[text release];
}


- (NSDateFormatter *)dateFormatter {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[formatter setDateFormat:@"y-MM-dd"];
	return [formatter autorelease];
}


- (void)handleExport:(MicroWebConnection *)connection {
	CSVWriter *writer = [[CSVWriter alloc] init];
	writer.floatFormatter = [WeightFormatter exportNumberFormatter];

	[writer addString:@"Date"];
	[writer addString:@"Weight"];
	[writer addString:@"Flag"];
	[writer addString:@"Comment"];
	[writer endRow];
	
	NSDateFormatter *formatter = [self dateFormatter];
	
	Database *db = [Database sharedDatabase];
	EWMonth month;
	for (month = db.earliestMonth; month <= db.latestMonth; month += 1) {
		MonthData *md = [db dataForMonth:month];
		EWDay day;
		for (day = 1; day <= 31; day++) {
			float measuredWeight = [md measuredWeightOnDay:day];
			NSString *note = [md noteOnDay:day];
			BOOL flag = [md isFlaggedOnDay:day];
			if (measuredWeight > 0 || note != nil || flag) {
				[writer addString:[formatter stringFromDate:[md dateOnDay:day]]];
				[writer addFloat:measuredWeight];
				[writer addBoolean:flag];
				[writer addString:note];
				[writer endRow];
			}
		}
	}
	
	[connection setResponseStatus:HTTP_STATUS_OK];
	// text/csv is technically correct, but the user wants to download, not view, the file
	[connection setValue:@"application/octet-stream" forResponseHeader:@"Content-Type"];
	[connection setResponseBodyData:[writer data]];
	[writer release];
	return;
}


- (void)handleImport:(MicroWebConnection *)connection {
	if (importData != nil) {
		[self sendResourceNamed:@"importPending" withSubstitutions:nil toConnection:connection];
		return;
	}
	
	FormDataParser *form = [[FormDataParser alloc] initWithConnection:connection];

	importData = [[form dataForKey:@"filedata"] retain];
	importReplace = [[form stringForKey:@"how"] isEqualToString:@"replace"];
	
	if (importData == nil) {
		[self sendResourceNamed:@"importNoData" withSubstitutions:nil toConnection:connection];
		return;
	}
		
	NSString *alertTitle = NSLocalizedString(@"PRE_IMPORT_TITLE", nil);
	NSString *alertText = NSLocalizedString(@"PRE_IMPORT_TEXT", nil);
	NSString *cancelTitle = NSLocalizedString(@"CANCEL_BUTTON", nil);
	NSString *replaceTitle = NSLocalizedString(@"REPLACE_BUTTON", nil);
	NSString *mergeTitle = NSLocalizedString(@"MERGE_BUTTON", nil);
	
	NSString *saveButtonTitle = importReplace ? replaceTitle : mergeTitle;

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertText delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:saveButtonTitle, nil];
	[alert show];
	[alert release];
	
	[self sendResourceNamed:@"importAccepted" withSubstitutions:nil toConnection:connection];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[self performImport];
	}
	[importData release];
	importData = nil;
}


- (void)performImport {
	const Database *db = [Database sharedDatabase];

	if (importReplace) {
		[db deleteWeights];
	}
	
	NSUInteger lineCount = 0, importCount = 0;
	CSVReader *reader = [[CSVReader alloc] initWithData:importData];
	reader.floatFormatter = [WeightFormatter exportNumberFormatter];
	
	NSDateFormatter *formatter = [self dateFormatter];
	
	while ([reader nextRow]) {
		lineCount += 1;
		NSString *dateString = [reader readString];
		if (dateString == nil) continue;
		NSDate *date = [formatter dateFromString:dateString];
		if (date == nil) continue;
		
		float measuredWeight = [reader readFloat];
		BOOL flag = [reader readBoolean];
		NSString *note = [reader readString];
		
		if (measuredWeight > 0 || note != nil || flag) {
			EWMonthDay monthday = EWMonthDayFromDate(date);
			MonthData *md = [db dataForMonth:EWMonthDayGetMonth(monthday)];
			[md setMeasuredWeight:measuredWeight flag:flag note:note onDay:EWMonthDayGetDay(monthday)];
			importCount += 1;
		}
	}
	
	[reader release];
	[db commitChanges];

	NSString *msg;
	
	if (importCount > 0) {
		NSString *msgFormat = NSLocalizedString(@"POST_IMPORT_TEXT_COUNT", nil);
		msg = [NSString stringWithFormat:msgFormat, importCount, (lineCount - importCount)];
	} else {
		NSString *msgFormat = NSLocalizedString(@"POST_IMPORT_TEXT_NONE", nil);
		msg = [NSString stringWithFormat:msgFormat, lineCount];
	}
	
	NSString *alertTitle = NSLocalizedString(@"POST_IMPORT_TITLE", nil);
	NSString *okTitle = NSLocalizedString(@"OK_BUTTON", nil);
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:okTitle, nil];
	[alert show];
	[alert release];
}


@end
