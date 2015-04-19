/*
 * CSVWriter.m
 * Created by Benjamin Ragheb on 5/17/08.
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

#import "CSVWriter.h"


@implementation CSVWriter
{
	NSMutableData *data;
	NSInteger columnIndex;
	NSCharacterSet *quotedCharSet;
	NSNumberFormatter *floatFormatter;
}

@synthesize floatFormatter;


- (id)init {
	if ((self = [super init])) {
		data = [[NSMutableData alloc] init];
		quotedCharSet = [NSCharacterSet characterSetWithCharactersInString:@",\r\n\""];
	}
	return self;
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
	}
	
	columnIndex++;
}


- (void)addFloat:(float)value {
	if (floatFormatter) {
		[self addString:[floatFormatter stringFromNumber:@(value)]];
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
