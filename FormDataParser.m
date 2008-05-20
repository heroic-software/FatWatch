//
//  FormDataParser.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/20/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "FormDataParser.h"
#import "MicroWebServer.h"
#import "DataSearch.h"


@interface FormDataParser ()
- (NSDictionary *)parseHeadersFromData:(NSData *)headersData;
- (void)parsePartData:(NSData *)partData;
- (NSData *)boundaryData;
- (void)parseMultipartFormData;
@end


@implementation FormDataParser

- (id)initWithConnection:(MicroWebConnection *)theConnection {
	if ([super init]) {
		connection = [theConnection retain];
		dictionary = [[NSMutableDictionary alloc] init];

		if ([[connection requestMethod] isEqualToString:@"POST"]) {
			NSString *contentType = [connection requestHeaderValueForName:@"Content-Type"];
			if ([contentType hasPrefix:@"multipart/form-data"]) {
				[self parseMultipartFormData];
			}
		}
	}
	return self;
}


- (void)dealloc {
	[dictionary release];
	[connection release];
	[super dealloc];
}


- (NSData *)dataForKey:(NSString *)key {
	return [dictionary objectForKey:key];
}


- (NSString *)stringForKey:(NSString *)key {
	NSData *data = [dictionary objectForKey:key];
	if (data) {
		return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	}
	return nil;
}


- (NSDictionary *)parseHeadersFromData:(NSData *)headersData {
	NSMutableDictionary *headers = [[NSMutableDictionary alloc] initWithCapacity:5];
	NSString *headersString = [[NSString alloc] initWithData:headersData encoding:NSUTF8StringEncoding];
	NSScanner *scanner = [[NSScanner alloc] initWithString:headersString];
	[scanner setCharactersToBeSkipped:nil];
	
	NSString *name, *value;
	
	while ([scanner scanUpToString:@": " intoString:&name] &&
		   [scanner scanString:@": " intoString:nil] &&
		   [scanner scanUpToString:@"\r\n" intoString:&value] &&
		   [scanner scanString:@"\r\n" intoString:nil]) {
		NSLog(@"Parsed header: <%@> value: <%@>", name, value);
		[headers setObject:value forKey:name];
	}
	
	[scanner release];
	[headersString release];
	return [headers autorelease];
}


- (void)parsePartData:(NSData *)partData {
	DataSearch *crlfcrlf = [[DataSearch alloc] initWithData:partData patternData:[NSData dataWithBytes:"\r\n\r\n" length:4]];
	NSUInteger crlfcrlfIndex = [crlfcrlf nextIndex];
	[crlfcrlf release];
	
	NSData *headersData = [partData subdataWithRange:NSMakeRange(0, crlfcrlfIndex + 2)];
	NSDictionary *headers = [self parseHeadersFromData:headersData];
	
	NSString *contentDisposition = [headers objectForKey:@"Content-Disposition"];
	if (contentDisposition == nil) {
		NSLog(@"Part has no Content-Disposition header!");
		return;
	}
	
	NSUInteger bodyBeginIndex = crlfcrlfIndex + 4;
	NSUInteger bodyLength = [partData length] - bodyBeginIndex;
	NSData *bodyData = [partData subdataWithRange:NSMakeRange(bodyBeginIndex, bodyLength)];
	NSLog(@"Part has %d bytes of data", bodyLength);
	
	NSString *name;
	
	NSScanner *scanner = [[NSScanner alloc] initWithString:contentDisposition];
	if ([scanner scanString:@"form-data; name=\"" intoString:nil] &&
		[scanner scanUpToString:@"\"" intoString:&name] && 
		[scanner scanString:@"\"" intoString:nil]) {
		[dictionary setObject:bodyData forKey:name];
		NSLog(@"Part has name %@", name);
	}
	[scanner release];
}


- (NSData *)boundaryData {
	NSString *contentType = [connection requestHeaderValueForName:@"Content-Type"];
	NSString *prefix = @"multipart/form-data; boundary=";
	if (! [contentType hasPrefix:prefix]) return nil;
	NSString *boundaryString = [contentType substringFromIndex:[prefix length]];
	return [boundaryString dataUsingEncoding:NSUTF8StringEncoding];
}


- (void)parseMultipartFormData {
	NSData *boundaryData = [self boundaryData];
	if (boundaryData == nil) return;
	
	NSData *bodyData = [connection requestBodyData];
	
	DataSearch *boundary = [[DataSearch alloc] initWithData:bodyData patternData:boundaryData];
	
	NSUInteger boundaryIndex = [boundary nextIndex];
	NSUInteger partBeginIndex = boundaryIndex + [boundaryData length] + 2;
	while (true) {
		NSUInteger partEndIndex = [boundary nextIndex];
		if (partEndIndex == NSNotFound) break;
		NSUInteger partLength = partEndIndex - partBeginIndex;
		NSLog(@"Found part from %d to %d", partBeginIndex, partEndIndex);
		[self parsePartData:[bodyData subdataWithRange:NSMakeRange(partBeginIndex, partLength)]];
		partBeginIndex = partEndIndex + [boundaryData length] + 2;
	}
	
	[boundary release];
}

@end
