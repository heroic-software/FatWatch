/*
 * FormDataParserTest.m
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

#import "FormDataParser.h"


@interface FormDataParserTest : XCTestCase
@end


@implementation FormDataParserTest


- (void)test1 {
	char *www = "a=1";
	NSData *data = [NSData dataWithBytes:www length:strlen(www)];
	FormDataParser *form = [[FormDataParser alloc] initWithData:data];
	XCTAssertEqualObjects([form stringForKey:@"a"], @"1", @"a");
	XCTAssertFalse([form hasKey:@"b"], @"no b");
}


- (void)test2 {
	char *www = "a=1&b=2";
	NSData *data = [NSData dataWithBytes:www length:strlen(www)];
	FormDataParser *form = [[FormDataParser alloc] initWithData:data];
	XCTAssertEqualObjects([form stringForKey:@"a"], @"1", @"a");
	XCTAssertEqualObjects([form stringForKey:@"b"], @"2", @"b");
}


- (void)test3 {
	char *www = "a=1+2+3&b=1%202%203";
	NSData *data = [NSData dataWithBytes:www length:strlen(www)];
	FormDataParser *form = [[FormDataParser alloc] initWithData:data];
	XCTAssertEqualObjects([form stringForKey:@"a"], @"1 2 3", @"a");
	XCTAssertEqualObjects([form stringForKey:@"b"], @"1 2 3", @"b");
}


- (void)testEmpty {
	char *www = "a=1&b&c=2";
	NSData *data = [NSData dataWithBytes:www length:strlen(www)];
	FormDataParser *form = [[FormDataParser alloc] initWithData:data];
	XCTAssertEqualObjects([form stringForKey:@"a"], @"1", @"a");
	XCTAssertEqualObjects([form stringForKey:@"b"], @"", @"b");
	XCTAssertEqualObjects([form stringForKey:@"c"], @"2", @"c");
}


- (void)testExtraAmpersands {
	char *www = "&a=1&&b=2&";
	NSData *data = [NSData dataWithBytes:www length:strlen(www)];
	FormDataParser *form = [[FormDataParser alloc] initWithData:data];
	XCTAssertEqualObjects([form stringForKey:@"a"], @"1", @"a");
	XCTAssertEqualObjects([form stringForKey:@"b"], @"2", @"b");
}

@end
