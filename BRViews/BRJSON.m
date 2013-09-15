//
//  BRJSON.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/18/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "BRJSON.h"


@implementation NSString (BRJSON)
- (void)appendJSONRepresentationToData:(NSMutableData *)json {
	NSMutableString *s = [self mutableCopy];
	[s replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"/"  withString:@"\\/"  options:0 range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\b" withString:@"\\\b" options:0 range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\f" withString:@"\\\f" options:0 range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\n" withString:@"\\\n" options:0 range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\r" withString:@"\\\r" options:0 range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\t" withString:@"\\\t" options:0 range:NSMakeRange(0, [s length])];
	const char quote = '"';
	[json appendBytes:&quote length:1];
	[json appendData:[s dataUsingEncoding:NSUTF8StringEncoding]];
	[json appendBytes:&quote length:1];
	[s release];
}
@end


@implementation NSDictionary (BRJSON)
- (void)appendJSONRepresentationToData:(NSMutableData *)json {
	BOOL comma = NO;
	[json appendBytes:"{" length:1];
	for (id key in self) {
		if (comma) [json appendBytes:"," length:1]; else comma = YES;
		[key appendJSONRepresentationToData:json];
		[json appendBytes:":" length:1];
		[self[key] appendJSONRepresentationToData:json];
	}
	[json appendBytes:"}" length:1];
}
@end


@implementation NSArray (BRJSON)
- (void)appendJSONRepresentationToData:(NSMutableData *)json {
	BOOL comma = NO;
	[json appendBytes:"[" length:1];
	for (id item in self) {
		if (comma) [json appendBytes:"," length:1]; else comma = YES;
		[item appendJSONRepresentationToData:json];
	}
	[json appendBytes:"]" length:1];
}
@end


@implementation NSNumber (BRJSON)
- (void)appendJSONRepresentationToData:(NSMutableData *)json {
	if (CFNumberGetType((CFNumberRef)self) == kCFNumberCharType) {
		char v = [self charValue];
		if (v == 0) { [json appendBytes:"false" length:5]; return; }
		if (v == 1) { [json appendBytes:"true" length:4]; return; }
	}
	[json appendData:[[self stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
}
@end


@implementation NSNull (BRJSON)
- (void)appendJSONRepresentationToData:(NSMutableData *)json {
	[json appendBytes:"null" length:4];
}
@end
