//
//  EWDateTest.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/24/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>
#import "EWDate.h"


@interface EWDateTest : SenTestCase {
}
@end


@implementation EWDateTest


+ (void)initialize {
	EWDateInit();
}

//EW_EXTERN NSUInteger EWDaysInMonth(EWMonth m);
//EW_EXTERN NSDate *EWDateFromMonthAndDay(EWMonth m, EWDay d);
//EW_EXTERN EWMonthDay EWMonthDayFromDate(NSDate *theDate);

- (void)testEWDaysInMonth {
	STAssertEquals(EWDaysInMonth(0), (NSUInteger)31, @"January 2000");
	STAssertEquals(EWDaysInMonth(1), (NSUInteger)28, @"February 2000");
	STAssertEquals(EWDaysInMonth(2), (NSUInteger)31, @"March 2000");
	STAssertEquals(EWDaysInMonth(3), (NSUInteger)30, @"April 2000");
	STAssertEquals(EWDaysInMonth(4), (NSUInteger)31, @"May 2000");
	STAssertEquals(EWDaysInMonth(5), (NSUInteger)30, @"June 2000");
	STAssertEquals(EWDaysInMonth(6), (NSUInteger)31, @"July 2000");
	STAssertEquals(EWDaysInMonth(7), (NSUInteger)31, @"August 2000");
	STAssertEquals(EWDaysInMonth(8), (NSUInteger)30, @"September 2000");
	STAssertEquals(EWDaysInMonth(9), (NSUInteger)31, @"October 2000");
	STAssertEquals(EWDaysInMonth(10), (NSUInteger)30, @"November 2000");
	STAssertEquals(EWDaysInMonth(11), (NSUInteger)31, @"December 2000");
	STAssertEquals(EWDaysInMonth(12), (NSUInteger)31, @"January 2001");
}


- (void)assertMonth:(EWMonth)m day:(EWDay)d convertsToTimeInterval:(NSTimeInterval)ti {
	NSDate *date1 = EWDateFromMonthAndDay(m, d);
	NSDate *dateRef = [NSDate dateWithTimeIntervalSinceReferenceDate:5 * 3600];
	NSDate *date2 = [dateRef addTimeInterval:ti];
	STAssertEqualObjects(date1, date2, @"equal dates");
}


- (void)testEWDateFromMonthAndDay {
	[self assertMonth:0 day:1 convertsToTimeInterval:0*86400];
	[self assertMonth:0 day:2 convertsToTimeInterval:1*86400];
	[self assertMonth:0 day:3 convertsToTimeInterval:2*86400];
	[self assertMonth:0 day:31 convertsToTimeInterval:30*86400];
	[self assertMonth:1 day:1 convertsToTimeInterval:31*86400];
}


- (void)assertTimeInterval:(NSTimeInterval)ti convertsToMonth:(EWMonth)m day:(EWDay)d {
	NSDate *dateRef = [NSDate dateWithTimeIntervalSinceReferenceDate:5 * 3600];
	NSDate *date = [dateRef addTimeInterval:ti];
	EWMonthDay md1 = EWMonthDayFromDate(date);
	NSLog(@"date = %@ (%f); md = %d", date, [date timeIntervalSinceReferenceDate], md1);
	STAssertEquals(EWMonthDayGetMonth(md1), m, @"month");
	STAssertEquals(EWMonthDayGetDay(md1), d, @"day");
}


- (void)testEWMonthDayFromDate {
	[self assertTimeInterval:0*86400 convertsToMonth:0 day:1];
	[self assertTimeInterval:1*86400 convertsToMonth:0 day:2];
	[self assertTimeInterval:2*86400 convertsToMonth:0 day:3];
	[self assertTimeInterval:30*86400 convertsToMonth:0 day:31];
	[self assertTimeInterval:31*86400 convertsToMonth:1 day:1];
	[self assertTimeInterval:241063666 convertsToMonth:91 day:22];
}


@end
