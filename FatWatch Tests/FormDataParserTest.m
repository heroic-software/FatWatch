//
//  FormDataParserTest.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/18/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

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
