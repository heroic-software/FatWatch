//
//  CSVReaderTest.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/19/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "CSVReader.h"


@interface CSVReaderTest : SenTestCase {	
}
@end


@implementation CSVReaderTest

- (CSVReader *)readerWithBytes:(const char *)text {
	NSData *data = [NSData dataWithBytes:text length:strlen(text)];
	return [[[CSVReader alloc] initWithData:data] autorelease];
}


- (void)testEmptyString {
	CSVReader *reader = [self readerWithBytes:""];

	STAssertFalse([reader nextRow], @"should be no data available");
}


- (void)testSingleWord {
	CSVReader *reader = [self readerWithBytes:"hello"];
	
	STAssertTrue([reader nextRow], @"should be a line available");
	STAssertEqualObjects(@"hello", [reader readString], @"first item should be 'hello'");
	STAssertNil([reader readString], @"should be no more data on this line");
	STAssertFalse([reader nextRow], @"should be no more lines");
}


- (void)test3x3withFinalNewline {
	CSVReader *reader = [self readerWithBytes:"a,b,c\nd,e,f\ng,h,i\n"];
	STAssertTrue([reader nextRow], @"first row");
	STAssertEqualObjects(@"a", [reader readString], @"row 1, item 1");
	STAssertEqualObjects(@"b", [reader readString], @"row 1, item 2");
	STAssertEqualObjects(@"c", [reader readString], @"row 1, item 3");
	STAssertNil([reader readString], @"no more data in row");
	STAssertTrue([reader nextRow], @"second row");
	STAssertEqualObjects(@"d", [reader readString], @"row 2, item 1");
	STAssertEqualObjects(@"e", [reader readString], @"row 2, item 2");
	STAssertEqualObjects(@"f", [reader readString], @"row 2, item 3");
	STAssertNil([reader readString], @"no more data in row");
	STAssertTrue([reader nextRow], @"third row");
	STAssertEqualObjects(@"g", [reader readString], @"row 3, item 1");
	STAssertEqualObjects(@"h", [reader readString], @"row 3, item 2");
	STAssertEqualObjects(@"i", [reader readString], @"row 3, item 3");
	STAssertNil([reader readString], @"no more data in row");
	STAssertFalse([reader nextRow], @"no more rows");
	STAssertFalse([reader nextRow], @"no more rows");
}


- (void)testQuotedStringAlone {
	CSVReader *reader = [self readerWithBytes:"\"goof balls\""];
	STAssertTrue([reader nextRow], @"first row");
	STAssertEqualObjects(@"goof balls", [reader readString], nil);
	STAssertNil([reader readString], @"no more data in row 1");
	STAssertNil([reader readString], @"no more data in row 2");
	STAssertFalse([reader nextRow], @"no more rows 1");
	STAssertFalse([reader nextRow], @"no more rows 2");
}


- (void)testQuotedStringSurrounded {
	CSVReader *reader = [self readerWithBytes:"soup,\"goof balls\",nuts"];
	STAssertTrue([reader nextRow], @"first row");
	STAssertEqualObjects(@"soup", [reader readString], nil);
	STAssertEqualObjects(@"goof balls", [reader readString], nil);
	STAssertEqualObjects(@"nuts", [reader readString], nil);
	STAssertNil([reader readString], @"no more data in row 1");
	STAssertNil([reader readString], @"no more data in row 2");
	STAssertFalse([reader nextRow], @"no more rows 1");
	STAssertFalse([reader nextRow], @"no more rows 2");
}


- (void)testQuotedStringContainingQuotes {
	CSVReader *reader = [self readerWithBytes:"soup,\"\"\"goof \"\"balls\"\"\",nuts"];
	STAssertTrue([reader nextRow], @"first row");
	STAssertEqualObjects(@"soup", [reader readString], nil);
	STAssertEqualObjects(@"\"goof \"balls\"", [reader readString], nil);
	STAssertEqualObjects(@"nuts", [reader readString], nil);
	STAssertNil([reader readString], @"no more data in row 1");
	STAssertNil([reader readString], @"no more data in row 2");
	STAssertFalse([reader nextRow], @"no more rows 1");
	STAssertFalse([reader nextRow], @"no more rows 2");
}


- (void)testQuotedStringFollowedByJunk {
	CSVReader *reader = [self readerWithBytes:"soup,\"nuts\" junk,freebie\r\n"];
	STAssertTrue([reader nextRow], @"first row");
	STAssertEqualObjects(@"soup", [reader readString], nil);
	STAssertEqualObjects(@"nuts", [reader readString], nil);
	STAssertEqualObjects(@"freebie", [reader readString], nil);
	STAssertNil([reader readString], @"no more data in row 1");
	STAssertNil([reader readString], @"no more data in row 2");
	STAssertFalse([reader nextRow], @"no more rows 1");
	STAssertFalse([reader nextRow], @"no more rows 2");
}

@end
