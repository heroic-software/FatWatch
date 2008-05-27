//
//  CSVWriter.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/17/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "CSVWriter.h"


@implementation CSVWriter


@synthesize floatFormatter;


- (id)init {
	if ([super init]) {
		data = [[NSMutableData alloc] init];
		quotedCharSet = [[NSCharacterSet characterSetWithCharactersInString:@",\r\n\""] retain];
	}
	return self;
}


- (void)dealloc {
	[floatFormatter release];
	[quotedCharSet release];
	[data release];
	[super dealloc];
}


- (void)addString:(NSString *)value {
	if (columnIndex > 0) {
		[data appendBytes:"," length:1];
	}
	
	// If the value contains a quoted character, we quote the string.
	NSRange commaRange = [value rangeOfCharacterFromSet:quotedCharSet];
	if (commaRange.location == NSNotFound) {
		[data appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
	} else {
		NSMutableString *quotedValue = [value mutableCopy];
		// Replace all instances of " with "" for escaping.
		NSRange wholeRange = NSMakeRange(0, [quotedValue length]);
		[quotedValue replaceOccurrencesOfString:@"\"" withString:@"\"\"" options:0 range:wholeRange];
		// Surround the string with double quotes.
		[quotedValue insertString:@"\"" atIndex:0];
		[quotedValue appendString:@"\""];
		[data appendData:[quotedValue dataUsingEncoding:NSUTF8StringEncoding]];
		[quotedValue release];
	}
	
	columnIndex++;
}


- (void)addFloat:(float)value {
	if (floatFormatter) {
		[self addString:[floatFormatter stringFromNumber:[NSNumber numberWithFloat:value]]];
	} else {
		[self addString:[NSString stringWithFormat:@"%f", value]];
	}
}


- (void)addBoolean:(BOOL)value {
	[self addString:(value ? @"1" : @"0")];
}


- (void)endRow {
	[data appendBytes:"\r\n" length:2];
	columnIndex = 0;
}


- (NSData *)data {
	return data;
}

@end
