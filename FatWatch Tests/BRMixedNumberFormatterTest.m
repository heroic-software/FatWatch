/*
 * BRMixedNumberFormatterTest.m
 * Created by Benjamin Ragheb on 12/9/09.
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

#import "BRMixedNumberFormatter.h"


@interface NSFormatter (BRMixedNumberFormatterTest)
- (NSString *)stringForFloat:(float)value;
@end

@implementation NSFormatter (BRMixedNumberFormatterTest)
- (NSString *)stringForFloat:(float)value {
	return [self stringForObjectValue:@(value)];
}
@end


@interface BRMixedNumberFormatterTest : XCTestCase
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
	fmtr.formatString = @"%@:%@";
	
	XCTAssertEqualObjects([fmtr stringForFloat:0], @"00:00", @"time test");
	XCTAssertEqualObjects([fmtr stringForFloat:1], @"00:00", @"time test");
	XCTAssertEqualObjects([fmtr stringForFloat:59.9f], @"00:01", @"time test");
	XCTAssertEqualObjects([fmtr stringForFloat:60.4f], @"00:01", @"time test");
	XCTAssertEqualObjects([fmtr stringForFloat:3600], @"01:00", @"time test");
	
}


- (void)testPoundsAsStones {
	NSFormatter *fmtr = [BRMixedNumberFormatter poundsAsStonesFormatterWithFractionDigits:1];
	
	XCTAssertEqualObjects([fmtr stringForFloat:0], @"0\xe2\x80\x88st 0.0\xe2\x80\x88lb", @"int test");
	XCTAssertEqualObjects([fmtr stringForFloat:1], @"0\xe2\x80\x88st 1.0\xe2\x80\x88lb", @"int test");
	XCTAssertEqualObjects([fmtr stringForFloat:13], @"0\xe2\x80\x88st 13.0\xe2\x80\x88lb", @"int test");
	XCTAssertEqualObjects([fmtr stringForFloat:14], @"1\xe2\x80\x88st 0.0\xe2\x80\x88lb", @"int test");
	XCTAssertEqualObjects([fmtr stringForFloat:15], @"1\xe2\x80\x88st 1.0\xe2\x80\x88lb", @"int test");

	XCTAssertEqualObjects([fmtr stringForFloat:0.01f], @"0\xe2\x80\x88st 0.0\xe2\x80\x88lb", @"int test");
	XCTAssertEqualObjects([fmtr stringForFloat:0.99f], @"0\xe2\x80\x88st 1.0\xe2\x80\x88lb", @"int test");
	XCTAssertEqualObjects([fmtr stringForFloat:12.99f], @"0\xe2\x80\x88st 13.0\xe2\x80\x88lb", @"int test");
	XCTAssertEqualObjects([fmtr stringForFloat:13.99f], @"1\xe2\x80\x88st 0.0\xe2\x80\x88lb", @"int test");
	XCTAssertEqualObjects([fmtr stringForFloat:14.009f], @"1\xe2\x80\x88st 0.0\xe2\x80\x88lb", @"int test");
	XCTAssertEqualObjects([fmtr stringForFloat:14.09f], @"1\xe2\x80\x88st 0.1\xe2\x80\x88lb", @"int test");
	XCTAssertEqualObjects([fmtr stringForFloat:14.99f], @"1\xe2\x80\x88st 1.0\xe2\x80\x88lb", @"int test");
}


- (void)testHeight {
	NSFormatter *fmtr = [BRMixedNumberFormatter metersAsFeetFormatter];
	XCTAssertEqualObjects([fmtr stringForFloat:1.4986f], @"4'\xe2\x80\x88" @"11\"", @"height test");
	XCTAssertEqualObjects([fmtr stringForFloat:1.524f], @"5'\xe2\x80\x88" @"0\"", @"height test");
	XCTAssertEqualObjects([fmtr stringForFloat:1.52399993f], @"5'\xe2\x80\x88" @"0\"", @"height test");
	XCTAssertEqualObjects([fmtr stringForFloat:1.8288f], @"6'\xe2\x80\x88" @"0\"", @"height test");
}


@end
