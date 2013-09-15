//
//  FormDataParserTest.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/18/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "FormDataParser.h"


@interface FormDataParserTest : SenTestCase
@end


@implementation FormDataParserTest


- (void)test1 {
	char *www = "a=1";
	NSData *data = [NSData dataWithBytesNoCopy:www length:strlen(www)];
	FormDataParser *form = [[FormDataParser alloc] initWithData:data];
	STAssertEqualObjects([form stringForKey:@"a"], @"1", @"a");
	STAssertFalse([form hasKey:@"b"], @"no b");
	[form release];
}


- (void)test2 {
	char *www = "a=1&b=2";
	NSData *data = [NSData dataWithBytesNoCopy:www length:strlen(www)];
	FormDataParser *form = [[FormDataParser alloc] initWithData:data];
	STAssertEqualObjects([form stringForKey:@"a"], @"1", @"a");
	STAssertEqualObjects([form stringForKey:@"b"], @"2", @"b");
	[form release];
}


- (void)test3 {
	char *www = "a=1+2+3&b=1%202%203";
	NSData *data = [NSData dataWithBytesNoCopy:www length:strlen(www)];
	FormDataParser *form = [[FormDataParser alloc] initWithData:data];
	STAssertEqualObjects([form stringForKey:@"a"], @"1 2 3", @"a");
	STAssertEqualObjects([form stringForKey:@"b"], @"1 2 3", @"b");
	[form release];
}


- (void)testEmpty {
	char *www = "a=1&b&c=2";
	NSData *data = [NSData dataWithBytesNoCopy:www length:strlen(www)];
	FormDataParser *form = [[FormDataParser alloc] initWithData:data];
	STAssertEqualObjects([form stringForKey:@"a"], @"1", @"a");
	STAssertEqualObjects([form stringForKey:@"b"], @"", @"b");
	STAssertEqualObjects([form stringForKey:@"c"], @"2", @"c");
	[form release];
}


- (void)testExtraAmpersands {
	char *www = "&a=1&&b=2&";
	NSData *data = [NSData dataWithBytesNoCopy:www length:strlen(www)];
	FormDataParser *form = [[FormDataParser alloc] initWithData:data];
	STAssertEqualObjects([form stringForKey:@"a"], @"1", @"a");
	STAssertEqualObjects([form stringForKey:@"b"], @"2", @"b");
	[form release];
}

@end
