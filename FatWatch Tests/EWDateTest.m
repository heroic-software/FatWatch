/*
 * EWDateTest.m
 * Created by Benjamin Ragheb on 7/24/08.
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

#import "EWDate.h"


@interface EWDateTest : XCTestCase
@end


@implementation EWDateTest


// EW_EXTERN NSUInteger EWDaysInMonth(EWMonth m);


- (void)testEWDaysInMonth {
	XCTAssertEqual(EWDaysInMonth(-15), 31, @"October 1999");
	XCTAssertEqual(EWDaysInMonth(-3), 31, @"October 2000");
	XCTAssertEqual(EWDaysInMonth(-2), 30, @"November 2000");
	XCTAssertEqual(EWDaysInMonth(-1), 31, @"December 2000");
	XCTAssertEqual(EWDaysInMonth(0), 31, @"January 2001");
	XCTAssertEqual(EWDaysInMonth(1), 28, @"February 2001");
	XCTAssertEqual(EWDaysInMonth(2), 31, @"March 2001");
	XCTAssertEqual(EWDaysInMonth(3), 30, @"April 2001");
	XCTAssertEqual(EWDaysInMonth(4), 31, @"May 2001");
	XCTAssertEqual(EWDaysInMonth(5), 30, @"June 2001");
	XCTAssertEqual(EWDaysInMonth(6), 31, @"July 2001");
	XCTAssertEqual(EWDaysInMonth(7), 31, @"August 2001");
	XCTAssertEqual(EWDaysInMonth(8), 30, @"September 2001");
	XCTAssertEqual(EWDaysInMonth(9), 31, @"October 2001");
	XCTAssertEqual(EWDaysInMonth(10), 30, @"November 2001");
	XCTAssertEqual(EWDaysInMonth(11), 31, @"December 2001");
	XCTAssertEqual(EWDaysInMonth(12), 31, @"January 2002");
	XCTAssertEqual(EWDaysInMonth(24), 31, @"January 2003");
	// test februaries, for leap years
	XCTAssertEqual(EWDaysInMonth(-59), 29, @"February 1996 leap");
	XCTAssertEqual(EWDaysInMonth(-47), 28, @"February 1997");
	XCTAssertEqual(EWDaysInMonth(-35), 28, @"February 1998");
	XCTAssertEqual(EWDaysInMonth(-23), 28, @"February 1999");
	XCTAssertEqual(EWDaysInMonth(-11), 29, @"February 2000 leap");
	XCTAssertEqual(EWDaysInMonth(1), 28, @"February 2001");
	XCTAssertEqual(EWDaysInMonth(13), 28, @"February 2002");
	XCTAssertEqual(EWDaysInMonth(25), 28, @"February 2003");
	XCTAssertEqual(EWDaysInMonth(37), 29, @"February 2004 leap");
	XCTAssertEqual(EWDaysInMonth(-1211), 28, @"February 1900 not a leap");
	XCTAssertEqual(EWDaysInMonth(1189), 28, @"February 2100 not a leap");
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
	
	XCTAssertEqual(EWDaysBetweenMonthDays(jan_15_2000, jan_15_2000), 0, @"same");
	XCTAssertEqual(EWDaysBetweenMonthDays(feb_15_2000, feb_15_2000), 0, @"same");
	XCTAssertEqual(EWDaysBetweenMonthDays(mar_15_2000, mar_15_2000), 0, @"same");
	XCTAssertEqual(EWDaysBetweenMonthDays(jan_01_2009, jan_01_2009), 0, @"same");
	XCTAssertEqual(EWDaysBetweenMonthDays(jan_31_2009, jan_31_2009), 0, @"same");
	XCTAssertEqual(EWDaysBetweenMonthDays(feb_01_2009, feb_01_2009), 0, @"same");
	XCTAssertEqual(EWDaysBetweenMonthDays(mar_01_2009, mar_01_2009), 0, @"same");

	XCTAssertEqual(EWDaysBetweenMonthDays(jan_15_2000, feb_15_2000), 31, @"");
	XCTAssertEqual(EWDaysBetweenMonthDays(feb_15_2000, jan_15_2000), -31, @"");
	
	XCTAssertEqual(EWDaysBetweenMonthDays(jan_01_2009, jan_31_2009), 30, @"");
	XCTAssertEqual(EWDaysBetweenMonthDays(jan_31_2009, jan_01_2009), -30, @"");

	XCTAssertEqual(EWDaysBetweenMonthDays(jan_31_2009, feb_01_2009), 1, @"");
	XCTAssertEqual(EWDaysBetweenMonthDays(feb_01_2009, jan_31_2009), -1, @"");
	
	XCTAssertEqual(EWDaysBetweenMonthDays(feb_01_2009, mar_01_2009), 28, @"");
	XCTAssertEqual(EWDaysBetweenMonthDays(mar_01_2009, feb_01_2009), -28, @"");

	XCTAssertEqual(EWDaysBetweenMonthDays(feb_15_2000, mar_15_2000), 29, @"");
	XCTAssertEqual(EWDaysBetweenMonthDays(mar_15_2000, feb_15_2000), -29, @"");
}


// EW_EXTERN EWMonthDay EWMonthDayNext(EWMonthDay md);


- (void)testEWMonthDayNext {
	// 37 = February 2004 (leap year)
	XCTAssertEqual(EWMonthDayNext(EWMonthDayMake(37, 1)), EWMonthDayMake(37, 2), @"2/1 -> 2/2");
	XCTAssertEqual(EWMonthDayNext(EWMonthDayMake(36, 31)), EWMonthDayMake(37, 1), @"1/31 -> 2/1");
	XCTAssertEqual(EWMonthDayNext(EWMonthDayMake(13, 28)), EWMonthDayMake(14, 1), @"2/28/02 -> 3/1");
	XCTAssertEqual(EWMonthDayNext(EWMonthDayMake(25, 28)), EWMonthDayMake(26, 1), @"2/28/03 -> 3/1");
	XCTAssertEqual(EWMonthDayNext(EWMonthDayMake(37, 28)), EWMonthDayMake(37, 29), @"2/28/04 -> 2/29");
	XCTAssertEqual(EWMonthDayNext(EWMonthDayMake(37, 29)), EWMonthDayMake(38, 1), @"2/29/04 -> 3/1");
}


// EW_EXTERN EWMonthDay EWMonthDayPrevious(EWMonthDay md);


- (void)testEWMonthDayPrevious {
	// 37 = February 2004 (leap year)
	XCTAssertEqual(EWMonthDayPrevious(EWMonthDayMake(37, 2)), EWMonthDayMake(37, 1), @"2/1 -> 2/2");
	XCTAssertEqual(EWMonthDayPrevious(EWMonthDayMake(37, 1)), EWMonthDayMake(36, 31), @"1/31 -> 2/1");
	XCTAssertEqual(EWMonthDayPrevious(EWMonthDayMake(14, 1)), EWMonthDayMake(13, 28), @"2/28/02 -> 3/1");
	XCTAssertEqual(EWMonthDayPrevious(EWMonthDayMake(26, 1)), EWMonthDayMake(25, 28), @"2/28/03 -> 3/1");
	XCTAssertEqual(EWMonthDayPrevious(EWMonthDayMake(38, 1)), EWMonthDayMake(37, 29), @"2/29/04 -> 3/1");
	XCTAssertEqual(EWMonthDayPrevious(EWMonthDayMake(37, 29)), EWMonthDayMake(37, 28), @"2/28/04 -> 2/29");
}


// EW_EXTERN NSDate *EWDateFromMonthAndDay(EWMonth m, EWDay d);


- (void)assertMonth:(EWMonth)m day:(EWDay)d convertsToTimeInterval:(NSTimeInterval)ti {
	NSDate *date1 = EWDateFromMonthAndDay(m, d);
	NSDate *dateRef = [NSDate dateWithTimeIntervalSinceReferenceDate:5 * 3600];
	NSDate *date2 = [dateRef dateByAddingTimeInterval:ti];
	XCTAssertEqualObjects(date1, date2, @"equal dates");
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
	XCTAssertEqual(EWMonthDayGetMonth(md1), m, @"month");
	XCTAssertEqual(EWMonthDayGetDay(md1), d, @"day");
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
	XCTAssertEqual(EWWeekdayFromMonthAndDay(jan2009, 1), (NSUInteger)5, @"1/1/09 = R");
	XCTAssertEqual(EWWeekdayFromMonthAndDay(jan2009, 2), (NSUInteger)6, @"1/2/09 = F");
	XCTAssertEqual(EWWeekdayFromMonthAndDay(jan2009, 3), (NSUInteger)7, @"1/3/09 = S");
	XCTAssertEqual(EWWeekdayFromMonthAndDay(jan2009, 4), (NSUInteger)1, @"1/4/09 = U");
	XCTAssertEqual(EWWeekdayFromMonthAndDay(jan2009, 5), (NSUInteger)2, @"1/5/09 = M");
	XCTAssertEqual(EWWeekdayFromMonthAndDay(jan2009, 6), (NSUInteger)3, @"1/6/09 = T");
	XCTAssertEqual(EWWeekdayFromMonthAndDay(jan2009, 7), (NSUInteger)4, @"1/7/09 = W");
	XCTAssertEqual(EWWeekdayFromMonthAndDay(jan2009, 14), (NSUInteger)4, @"1/14/09 = W");
	XCTAssertEqual(EWWeekdayFromMonthAndDay(jan2009, 21), (NSUInteger)4, @"1/21/09 = W");
	XCTAssertEqual(EWWeekdayFromMonthAndDay(jan2009, 28), (NSUInteger)4, @"1/28/09 = W");
}


@end
