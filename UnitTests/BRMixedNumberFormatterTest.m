//
//  BRMixedNumberFormatterTest.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/9/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>
#import "BRMixedNumberFormatter.h"


@interface NSFormatter (BRMixedNumberFormatterTest)
- (NSString *)stringForFloat:(float)value;
@end

@implementation NSFormatter (BRMixedNumberFormatterTest)
- (NSString *)stringForFloat:(float)value {
	return [self stringForObjectValue:[NSNumber numberWithFloat:value]];
}
@end


@interface BRMixedNumberFormatterTest : SenTestCase
{
}
@end

@implementation BRMixedNumberFormatterTest


- (void)testTime {
	BRMixedNumberFormatter *fmtr = [[BRMixedNumberFormatter alloc] init];
	fmtr.multiple = 1.0f/60.0f; // minutes per second
	fmtr.divisor = 60; // minutes per hour
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setMinimumIntegerDigits:2];
	fmtr.quotientFormatter = nf;
	fmtr.remainderFormatter = nf;
	[nf release];
	fmtr.formatString = @"%@:%@";
	
	STAssertEqualObjects([fmtr stringForFloat:0], @"00:00", @"time test");
	STAssertEqualObjects([fmtr stringForFloat:1], @"00:00", @"time test");
	STAssertEqualObjects([fmtr stringForFloat:59.9f], @"00:01", @"time test");
	STAssertEqualObjects([fmtr stringForFloat:60.4f], @"00:01", @"time test");
	STAssertEqualObjects([fmtr stringForFloat:3600], @"01:00", @"time test");
	
	[fmtr release];
}


- (void)testPoundsAsStones {
	NSFormatter *fmtr = [BRMixedNumberFormatter poundsAsStonesFormatterWithFractionDigits:1];
	
	STAssertEqualObjects([fmtr stringForFloat:0], @"0\xe2\x80\x88st 0.0\xe2\x80\x88lb", @"int test");
	STAssertEqualObjects([fmtr stringForFloat:1], @"0\xe2\x80\x88st 1.0\xe2\x80\x88lb", @"int test");
	STAssertEqualObjects([fmtr stringForFloat:13], @"0\xe2\x80\x88st 13.0\xe2\x80\x88lb", @"int test");
	STAssertEqualObjects([fmtr stringForFloat:14], @"1\xe2\x80\x88st 0.0\xe2\x80\x88lb", @"int test");
	STAssertEqualObjects([fmtr stringForFloat:15], @"1\xe2\x80\x88st 1.0\xe2\x80\x88lb", @"int test");

	STAssertEqualObjects([fmtr stringForFloat:0.01f], @"0\xe2\x80\x88st 0.0\xe2\x80\x88lb", @"int test");
	STAssertEqualObjects([fmtr stringForFloat:0.99f], @"0\xe2\x80\x88st 1.0\xe2\x80\x88lb", @"int test");
	STAssertEqualObjects([fmtr stringForFloat:12.99f], @"0\xe2\x80\x88st 13.0\xe2\x80\x88lb", @"int test");
	STAssertEqualObjects([fmtr stringForFloat:13.99f], @"1\xe2\x80\x88st 0.0\xe2\x80\x88lb", @"int test");
	STAssertEqualObjects([fmtr stringForFloat:14.009f], @"1\xe2\x80\x88st 0.0\xe2\x80\x88lb", @"int test");
	STAssertEqualObjects([fmtr stringForFloat:14.09f], @"1\xe2\x80\x88st 0.1\xe2\x80\x88lb", @"int test");
	STAssertEqualObjects([fmtr stringForFloat:14.99f], @"1\xe2\x80\x88st 1.0\xe2\x80\x88lb", @"int test");
}


- (void)testHeight {
	NSFormatter *fmtr = [BRMixedNumberFormatter metersAsFeetFormatter];
	STAssertEqualObjects([fmtr stringForFloat:1.4986f], @"4'\xe2\x80\x88" @"11\"", @"height test");
	STAssertEqualObjects([fmtr stringForFloat:1.524f], @"5'\xe2\x80\x88" @"0\"", @"height test");
	STAssertEqualObjects([fmtr stringForFloat:1.52399993f], @"5'\xe2\x80\x88" @"0\"", @"height test");
	STAssertEqualObjects([fmtr stringForFloat:1.8288f], @"6'\xe2\x80\x88" @"0\"", @"height test");
}


@end
