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


// EW_EXTERN NSUInteger EWDaysInMonth(EWMonth m);


- (void)testEWDaysInMonth {
	STAssertEquals(EWDaysInMonth(-15), 31, @"October 1999");
	STAssertEquals(EWDaysInMonth(-3), 31, @"October 2000");
	STAssertEquals(EWDaysInMonth(-2), 30, @"November 2000");
	STAssertEquals(EWDaysInMonth(-1), 31, @"December 2000");
	STAssertEquals(EWDaysInMonth(0), 31, @"January 2001");
	STAssertEquals(EWDaysInMonth(1), 28, @"February 2001");
	STAssertEquals(EWDaysInMonth(2), 31, @"March 2001");
	STAssertEquals(EWDaysInMonth(3), 30, @"April 2001");
	STAssertEquals(EWDaysInMonth(4), 31, @"May 2001");
	STAssertEquals(EWDaysInMonth(5), 30, @"June 2001");
	STAssertEquals(EWDaysInMonth(6), 31, @"July 2001");
	STAssertEquals(EWDaysInMonth(7), 31, @"August 2001");
	STAssertEquals(EWDaysInMonth(8), 30, @"September 2001");
	STAssertEquals(EWDaysInMonth(9), 31, @"October 2001");
	STAssertEquals(EWDaysInMonth(10), 30, @"November 2001");
	STAssertEquals(EWDaysInMonth(11), 31, @"December 2001");
	STAssertEquals(EWDaysInMonth(12), 31, @"January 2002");
	STAssertEquals(EWDaysInMonth(24), 31, @"January 2003");
	// test februaries, for leap years
	STAssertEquals(EWDaysInMonth(-59), 29, @"February 1996 leap");
	STAssertEquals(EWDaysInMonth(-47), 28, @"February 1997");
	STAssertEquals(EWDaysInMonth(-35), 28, @"February 1998");
	STAssertEquals(EWDaysInMonth(-23), 28, @"February 1999");
	STAssertEquals(EWDaysInMonth(-11), 29, @"February 2000 leap");
	STAssertEquals(EWDaysInMonth(1), 28, @"February 2001");
	STAssertEquals(EWDaysInMonth(13), 28, @"February 2002");
	STAssertEquals(EWDaysInMonth(25), 28, @"February 2003");
	STAssertEquals(EWDaysInMonth(37), 29, @"February 2004 leap");
	STAssertEquals(EWDaysInMonth(-1211), 28, @"February 1900 not a leap");
	STAssertEquals(EWDaysInMonth(1189), 28, @"February 2100 not a leap");
}


// EW_EXTERN NSInteger EWDaysBetweenMonthDays(EWMonthDay mdA, EWMonthDay mdB);


- (void)testEWDaysBetweenMonthDays {
	EWMonthDay jan_15_2000 = EWMonthDayMake(-12, 15);
	EWMonthDay feb_15_2000 = EWMonthDayMake(-11, 15);
	EWMonthDay mar_15_2000 = EWMonthDayMake(-10, 15);
	EWMonthDay jan_01_2009 = EWMonthDayMake(96, 1);
	EWMonthDay jan_31_2009 = EWMonthDayMake(96, 31);
	EWMonthDay feb_01_2009 = EWMonthDayMake(97, 1);
	EWMonthDay mar_01_2009 = EWMonthDayMake(98, 1);
	
	STAssertEquals(EWDaysBetweenMonthDays(jan_15_2000, jan_15_2000), 0, @"same");
	STAssertEquals(EWDaysBetweenMonthDays(feb_15_2000, feb_15_2000), 0, @"same");
	STAssertEquals(EWDaysBetweenMonthDays(mar_15_2000, mar_15_2000), 0, @"same");
	STAssertEquals(EWDaysBetweenMonthDays(jan_01_2009, jan_01_2009), 0, @"same");
	STAssertEquals(EWDaysBetweenMonthDays(jan_31_2009, jan_31_2009), 0, @"same");
	STAssertEquals(EWDaysBetweenMonthDays(feb_01_2009, feb_01_2009), 0, @"same");
	STAssertEquals(EWDaysBetweenMonthDays(mar_01_2009, mar_01_2009), 0, @"same");

	STAssertEquals(EWDaysBetweenMonthDays(jan_15_2000, feb_15_2000), 31, @"");
	STAssertEquals(EWDaysBetweenMonthDays(feb_15_2000, jan_15_2000), -31, @"");
	
	STAssertEquals(EWDaysBetweenMonthDays(jan_01_2009, jan_31_2009), 30, @"");
	STAssertEquals(EWDaysBetweenMonthDays(jan_31_2009, jan_01_2009), -30, @"");

	STAssertEquals(EWDaysBetweenMonthDays(jan_31_2009, feb_01_2009), 1, @"");
	STAssertEquals(EWDaysBetweenMonthDays(feb_01_2009, jan_31_2009), -1, @"");
	
	STAssertEquals(EWDaysBetweenMonthDays(feb_01_2009, mar_01_2009), 28, @"");
	STAssertEquals(EWDaysBetweenMonthDays(mar_01_2009, feb_01_2009), -28, @"");

	STAssertEquals(EWDaysBetweenMonthDays(feb_15_2000, mar_15_2000), 29, @"");
	STAssertEquals(EWDaysBetweenMonthDays(mar_15_2000, feb_15_2000), -29, @"");
}


// EW_EXTERN EWMonthDay EWMonthDayNext(EWMonthDay md);


- (void)testEWMonthDayNext {
	// 37 = February 2004 (leap year)
	STAssertEquals(EWMonthDayNext(EWMonthDayMake(37, 1)), EWMonthDayMake(37, 2), @"2/1 -> 2/2");
	STAssertEquals(EWMonthDayNext(EWMonthDayMake(36, 31)), EWMonthDayMake(37, 1), @"1/31 -> 2/1");
	STAssertEquals(EWMonthDayNext(EWMonthDayMake(13, 28)), EWMonthDayMake(14, 1), @"2/28/02 -> 3/1");
	STAssertEquals(EWMonthDayNext(EWMonthDayMake(25, 28)), EWMonthDayMake(26, 1), @"2/28/03 -> 3/1");
	STAssertEquals(EWMonthDayNext(EWMonthDayMake(37, 28)), EWMonthDayMake(37, 29), @"2/28/04 -> 2/29");
	STAssertEquals(EWMonthDayNext(EWMonthDayMake(37, 29)), EWMonthDayMake(38, 1), @"2/29/04 -> 3/1");
}


// EW_EXTERN EWMonthDay EWMonthDayPrevious(EWMonthDay md);


- (void)testEWMonthDayPrevious {
	// 37 = February 2004 (leap year)
	STAssertEquals(EWMonthDayPrevious(EWMonthDayMake(37, 2)), EWMonthDayMake(37, 1), @"2/1 -> 2/2");
	STAssertEquals(EWMonthDayPrevious(EWMonthDayMake(37, 1)), EWMonthDayMake(36, 31), @"1/31 -> 2/1");
	STAssertEquals(EWMonthDayPrevious(EWMonthDayMake(14, 1)), EWMonthDayMake(13, 28), @"2/28/02 -> 3/1");
	STAssertEquals(EWMonthDayPrevious(EWMonthDayMake(26, 1)), EWMonthDayMake(25, 28), @"2/28/03 -> 3/1");
	STAssertEquals(EWMonthDayPrevious(EWMonthDayMake(38, 1)), EWMonthDayMake(37, 29), @"2/29/04 -> 3/1");
	STAssertEquals(EWMonthDayPrevious(EWMonthDayMake(37, 29)), EWMonthDayMake(37, 28), @"2/28/04 -> 2/29");
}


// EW_EXTERN NSDate *EWDateFromMonthAndDay(EWMonth m, EWDay d);


- (void)assertMonth:(EWMonth)m day:(EWDay)d convertsToTimeInterval:(NSTimeInterval)ti {
	NSDate *date1 = EWDateFromMonthAndDay(m, d);
	NSDate *dateRef = [NSDate dateWithTimeIntervalSinceReferenceDate:5 * 3600];
	NSDate *date2 = [dateRef dateByAddingTimeInterval:ti];
	STAssertEqualObjects(date1, date2, @"equal dates");
}


- (void)testEWDateFromMonthAndDay {
	[self assertMonth:0 day:1 convertsToTimeInterval:0*86400];
	[self assertMonth:0 day:2 convertsToTimeInterval:1*86400];
	[self assertMonth:0 day:3 convertsToTimeInterval:2*86400];
	[self assertMonth:0 day:31 convertsToTimeInterval:30*86400];
	[self assertMonth:1 day:1 convertsToTimeInterval:31*86400];
}


// EW_EXTERN EWMonthDay EWMonthDayFromDate(NSDate *theDate);


- (void)assertTimeInterval:(NSTimeInterval)ti convertsToMonth:(EWMonth)m day:(EWDay)d {
	NSDate *dateRef = [NSDate dateWithTimeIntervalSinceReferenceDate:5 * 3600];
	NSDate *date = [dateRef dateByAddingTimeInterval:ti];
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


// EW_EXTERN BOOL EWMonthAndDayIsWeekend(EWMonth m, EWDay d);
// EW_EXTERN NSUInteger EWWeekdayFromMonthAndDay(EWMonth m, EWDay d);


- (void)testEWWeekdayFromMonthAndDay {
	EWMonth jan2009 = 12 * 8;
	STAssertEquals(EWWeekdayFromMonthAndDay(jan2009, 1), (NSUInteger)5, @"1/1/09 = R");
	STAssertEquals(EWWeekdayFromMonthAndDay(jan2009, 2), (NSUInteger)6, @"1/2/09 = F");
	STAssertEquals(EWWeekdayFromMonthAndDay(jan2009, 3), (NSUInteger)7, @"1/3/09 = S");
	STAssertEquals(EWWeekdayFromMonthAndDay(jan2009, 4), (NSUInteger)1, @"1/4/09 = U");
	STAssertEquals(EWWeekdayFromMonthAndDay(jan2009, 5), (NSUInteger)2, @"1/5/09 = M");
	STAssertEquals(EWWeekdayFromMonthAndDay(jan2009, 6), (NSUInteger)3, @"1/6/09 = T");
	STAssertEquals(EWWeekdayFromMonthAndDay(jan2009, 7), (NSUInteger)4, @"1/7/09 = W");
	STAssertEquals(EWWeekdayFromMonthAndDay(jan2009, 14), (NSUInteger)4, @"1/14/09 = W");
	STAssertEquals(EWWeekdayFromMonthAndDay(jan2009, 21), (NSUInteger)4, @"1/21/09 = W");
	STAssertEquals(EWWeekdayFromMonthAndDay(jan2009, 28), (NSUInteger)4, @"1/28/09 = W");
}


@end
