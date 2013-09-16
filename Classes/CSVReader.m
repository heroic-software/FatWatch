//
//  CSVReader.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/17/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "CSVReader.h"


// idea: use array of 256 bits (32 bytes) to represent character set

@interface CSVReader ()
- (void)skipOverBytes:(const char *)charset;
- (char)skipToBytes:(const char *)charset;
- (void)skipToNonWhitespace;
- (void)skipToEndOfLine;
- (NSString *)stringWithDataFromIndex:(NSUInteger)startIndex toIndex:(NSUInteger)endIndex;
- (NSString *)readQuotedString;
- (NSString *)readBareString;
@end


@implementation CSVReader


@synthesize floatFormatter;


- (id)initWithData:(NSData *)csvData encoding:(NSStringEncoding)encoding {
	if ((self = [super init])) {
		data = csvData;
		dataEncoding = encoding;
	}
	return self;
}




- (void)reset {
	dataIndex = 0;
}


- (void)skipOverBytes:(const char *)charset {
	const NSUInteger dataLength	 = [data length];
	const char *dataBytes = [data bytes];
	const int setLength = strlen(charset);
	int setIndex = 0;
	char b;
	
	while (dataIndex < dataLength) {
		// At the start of the set, fetch the current byte.
		if (setIndex == 0) {
			b = dataBytes[dataIndex];
		}
		// If the current byte is in the set, we move to the next byte,
		// otherwise we try the next member of the set.
		if (b == charset[setIndex]) {
			dataIndex += 1;
			setIndex = 0;
		} else {
			setIndex +=1;
		}
		// If we make it to the end of the set, the current byte must not be
		// in it, so we stop.
		if (setIndex == setLength) {
			return;
		}
	}
}


- (char)skipToBytes:(const char *)charset {
	const NSUInteger dataLength	 = [data length];
	const char *dataBytes = [data bytes];
	const int setLength = strlen(charset);
	int setIndex = 0;
	char b;
	
	while (dataIndex < dataLength) {
		// At the start of the set, we fetch the current byte.
		if (setIndex == 0) {
			b = dataBytes[dataIndex];
		}
		// If the current byte is in the set, we stop,
		// otherwise we try the next member of the set.
		if (b == charset[setIndex]) {
			return b; 
		} else {
			setIndex += 1;
		}
		// If we make it to the end of the set, the current byte must not be
		// in it, so we advance to the next byte.
		if (setIndex == setLength) {
			setIndex = 0;
			dataIndex += 1;
		}
	}
	
	return 0;
}


- (void)skipToNonWhitespace {
	[self skipOverBytes:" \t\r\n"];
}


- (void)skipToEndOfLine {
	[self skipToBytes:"\r\n"];
}


- (BOOL)nextRow {
	if (dataIndex == 0) {
		[self skipToNonWhitespace];
	} else {
		[self skipToEndOfLine];
		[self skipToNonWhitespace];
	}
	return (dataIndex < [data length]);
}


- (NSString *)stringWithDataFromIndex:(NSUInteger)startIndex toIndex:(NSUInteger)endIndex {
	NSData *subdata = [data subdataWithRange:NSMakeRange(startIndex, endIndex - startIndex + 1)];
	NSString *text = [[NSString alloc] initWithData:subdata encoding:dataEncoding];
	if (text == nil) { // might be if we cannot encode the data.
		NSLog(@"WARNING: Unable to encode data %@", subdata);
		return @"";
	}
	return text;
}


- (NSString *)readQuotedString {
	const char *dataBytes = [data bytes];
	const NSUInteger dataLength = [data length];

	NSMutableString *value = nil;

	while (dataIndex < dataLength && dataBytes[dataIndex] == '"') {
		NSUInteger startIndex = dataIndex;
		if (value == nil) {
			value = [[NSMutableString alloc] init];
			startIndex += 1; // skip opening quote
		}
		dataIndex += 1; // skip over the beginning quote
		char endByte = [self skipToBytes:"\""]; // advance until a close quote
		// Either dataIndex points to a quote or past the end of the data, so either way we step back one byte.
		[value appendString:[self stringWithDataFromIndex:startIndex toIndex:(dataIndex - 1)]];
		
		if (endByte == '"') dataIndex += 1; // skip the close quote
	}
	
	char endByte = [self skipToBytes:",\r\n"];
	if (endByte == ',') dataIndex += 1;
	
	return value;
}


- (NSString *)readBareString {
	NSUInteger startIndex = dataIndex;
	char endByte = [self skipToBytes:",\r\n"];
	NSUInteger endIndex = dataIndex - 1;
	
	if (endByte == ',') dataIndex += 1;
	
	return [self stringWithDataFromIndex:startIndex toIndex:endIndex];
}


- (NSString *)readString {
	const NSUInteger dataLength	 = [data length];

	// Return nil if there is no more data.
	if (dataIndex >= dataLength) return nil;
	
	const char *dataBytes = [data bytes];
	char b = dataBytes[dataIndex];
	
	// Return nil if there is no more data on this line.
	if (b == '\r' || b == '\n') {
		return nil;
	}
	
	NSString *value;
	
	if (b == '"') {
		value = [self readQuotedString];
	} else {
		value = [self readBareString];
	}
	
	return value;
}


- (float)readFloat {
	NSString *value = [self readString];
	if (value == nil) return 0; // bad, no way to indicate end of line
	if (floatFormatter) {
		return [[floatFormatter numberFromString:value] floatValue];
	} else {
		return [value floatValue];
	}
}


- (BOOL)readBoolean {
	NSString *value = [self readString];
	if (value == nil) return NO; // bad, no way to indicate end of line
	return [value boolValue];
}


- (float)progress {
	return (float)dataIndex / (float)[data length];
}


- (NSArray *)readRow {
	if (![self nextRow]) return nil;
	NSMutableArray *rowArray = [[NSMutableArray alloc] init];
	NSString *string;
	while ((string = [self readString])) {
		[rowArray addObject:string];
	}
	return rowArray;
}


@end
