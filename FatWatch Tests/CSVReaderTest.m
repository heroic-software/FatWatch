/*
 * CSVReaderTest.m
 * Created by Benjamin Ragheb on 5/19/08.
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

#import "CSVReader.h"


@interface CSVReaderTest : XCTestCase
@end

@implementation CSVReaderTest

- (CSVReader *)readerWithBytes:(const char *)text {
	NSData *data = [NSData dataWithBytes:text length:strlen(text)];
	return [[CSVReader alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


- (void)testEmptyString {
	CSVReader *reader = [self readerWithBytes:""];

	XCTAssertFalse([reader nextRow], @"should be no data available");
}


- (void)testSingleWord {
	CSVReader *reader = [self readerWithBytes:"hello"];
	
	XCTAssertTrue([reader nextRow], @"should be a line available");
	XCTAssertEqualObjects(@"hello", [reader readString], @"first item should be 'hello'");
	XCTAssertNil([reader readString], @"should be no more data on this line");
	XCTAssertFalse([reader nextRow], @"should be no more lines");
}


- (void)test3x3withFinalNewline {
	CSVReader *reader = [self readerWithBytes:"a,b,c\nd,e,f\ng,h,i\n"];
	XCTAssertTrue([reader nextRow], @"first row");
	XCTAssertEqualObjects(@"a", [reader readString], @"row 1, item 1");
	XCTAssertEqualObjects(@"b", [reader readString], @"row 1, item 2");
	XCTAssertEqualObjects(@"c", [reader readString], @"row 1, item 3");
	XCTAssertNil([reader readString], @"no more data in row");
	XCTAssertTrue([reader nextRow], @"second row");
	XCTAssertEqualObjects(@"d", [reader readString], @"row 2, item 1");
	XCTAssertEqualObjects(@"e", [reader readString], @"row 2, item 2");
	XCTAssertEqualObjects(@"f", [reader readString], @"row 2, item 3");
	XCTAssertNil([reader readString], @"no more data in row");
	XCTAssertTrue([reader nextRow], @"third row");
	XCTAssertEqualObjects(@"g", [reader readString], @"row 3, item 1");
	XCTAssertEqualObjects(@"h", [reader readString], @"row 3, item 2");
	XCTAssertEqualObjects(@"i", [reader readString], @"row 3, item 3");
	XCTAssertNil([reader readString], @"no more data in row");
	XCTAssertFalse([reader nextRow], @"no more rows");
	XCTAssertFalse([reader nextRow], @"no more rows");
}


- (void)testQuotedStringAlone {
	CSVReader *reader = [self readerWithBytes:"\"goof balls\""];
	XCTAssertTrue([reader nextRow], @"first row");
	XCTAssertEqualObjects(@"goof balls", [reader readString]);
	XCTAssertNil([reader readString], @"no more data in row 1");
	XCTAssertNil([reader readString], @"no more data in row 2");
	XCTAssertFalse([reader nextRow], @"no more rows 1");
	XCTAssertFalse([reader nextRow], @"no more rows 2");
}


- (void)testQuotedStringSurrounded {
	CSVReader *reader = [self readerWithBytes:"soup,\"goof balls\",nuts"];
	XCTAssertTrue([reader nextRow], @"first row");
	XCTAssertEqualObjects(@"soup", [reader readString]);
	XCTAssertEqualObjects(@"goof balls", [reader readString]);
	XCTAssertEqualObjects(@"nuts", [reader readString]);
	XCTAssertNil([reader readString], @"no more data in row 1");
	XCTAssertNil([reader readString], @"no more data in row 2");
	XCTAssertFalse([reader nextRow], @"no more rows 1");
	XCTAssertFalse([reader nextRow], @"no more rows 2");
}


- (void)testQuotedStringContainingQuotes {
	CSVReader *reader = [self readerWithBytes:"soup,\"\"\"goof \"\"balls\"\"\",nuts"];
	XCTAssertTrue([reader nextRow], @"first row");
	XCTAssertEqualObjects(@"soup", [reader readString]);
	XCTAssertEqualObjects(@"\"goof \"balls\"", [reader readString]);
	XCTAssertEqualObjects(@"nuts", [reader readString]);
	XCTAssertNil([reader readString], @"no more data in row 1");
	XCTAssertNil([reader readString], @"no more data in row 2");
	XCTAssertFalse([reader nextRow], @"no more rows 1");
	XCTAssertFalse([reader nextRow], @"no more rows 2");
}


- (void)testQuotedStringFollowedByJunk {
	CSVReader *reader = [self readerWithBytes:"soup,\"nuts\" junk,freebie\r\n"];
	XCTAssertTrue([reader nextRow], @"first row");
	XCTAssertEqualObjects(@"soup", [reader readString]);
	XCTAssertEqualObjects(@"nuts", [reader readString]);
	XCTAssertEqualObjects(@"freebie", [reader readString]);
	XCTAssertNil([reader readString], @"no more data in row 1");
	XCTAssertNil([reader readString], @"no more data in row 2");
	XCTAssertFalse([reader nextRow], @"no more rows 1");
	XCTAssertFalse([reader nextRow], @"no more rows 2");
}

@end
