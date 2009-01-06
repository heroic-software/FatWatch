//
//  EWDate.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/12/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "EWDate.h"


const NSInteger kReferenceYear = 2001;
const NSInteger kReferenceMonth = 1;
const NSInteger kReferenceDay = 1;


NSUInteger EWDaysInMonth(EWMonth m) {
	static NSUInteger dayCount[12] = {
		31,  0, 31, // Jan Feb Mar
		30, 31, 30, // Apr May Jun
		31, 31, 30, // Jul Aug Sep
		31, 30, 31  // Oct Nov Dec
	};
	
	NSInteger m0 = (m % 12);

	if (m0 < 0) m0 += 12;

	if (m0 == 1) {
		NSInteger year = (24012 + m) / 12; 	// 0 = 2001-01
		if (((year % 4 == 0) && (year % 100) != 0) || ((year % 400) == 0)) {
			return 29;
		} else {
			return 28;
		}
	} else {
		return dayCount[m0];
	}
}


NSInteger EWDaysBetweenMonthDays(EWMonthDay mdA, EWMonthDay mdB) {
	if (EWMonthDayGetMonth(mdB) == EWMonthDayGetMonth(mdA)) {
		return EWMonthDayGetDay(mdB) - EWMonthDayGetDay(mdA);
	}
	NSDate *dateA = EWDateFromMonthDay(mdA);
	NSDate *dateB = EWDateFromMonthDay(mdB);
	const NSTimeInterval kSecondsPerDay = 60 * 60 * 24;
	// Because of daylight savings, the difference might be slightly more or 
	// less than a full day, so we must round.
	return round([dateB timeIntervalSinceDate:dateA] / kSecondsPerDay);
}


EWMonthDay EWMonthDayNext(EWMonthDay md) {
	EWMonth month = EWMonthDayGetMonth(md);
	if (EWMonthDayGetDay(md) < 28) { // no month has fewer than 28 days
		return md + 1;
	} else if (EWMonthDayGetDay(md) < EWDaysInMonth(month)) {
		return md + 1;
	} else {
		return EWMonthDayMake(month + 1, 1);
	}
}


EWMonthDay EWMonthDayPrevious(EWMonthDay md) {
	if (EWMonthDayGetDay(md) == 1) {
		EWMonth newMonth = EWMonthDayGetMonth(md) - 1;
		return EWMonthDayMake(newMonth, EWDaysInMonth(newMonth));
	} else {
		return md - 1;
	}
}


NSDate *EWDateFromMonthAndDay(EWMonth m, EWDay d) {
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

	NSDate *refDateGMT = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
	NSTimeInterval refDateOffset = -[[calendar timeZone] secondsFromGMTForDate:refDateGMT];
	NSDate *refDate = [refDateGMT addTimeInterval:refDateOffset];
	
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.month = m;
	components.day = d - 1;
	NSDate *theDate = [calendar dateByAddingComponents:components
												toDate:refDate
											   options:0];
	[components release];
	[calendar release];
	return theDate;
}


EWMonthDay EWMonthDayFromDate(NSDate *theDate) {
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

	NSDateComponents *dc = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:theDate];
	EWMonth month = ((dc.year - kReferenceYear) * 12) + (dc.month - 1);
	
	[calendar release];
	return EWMonthDayMake(month, dc.day);
}


BOOL EWMonthAndDayIsWeekend(EWMonth m, EWDay d) {
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

	NSDate *date = EWDateFromMonthAndDay(m, d);
	NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit fromDate:date];

	[calendar release];
	return (comps.weekday == 1 || comps.weekday == 7);
}


NSUInteger EWWeekdayFromMonthAndDay(EWMonth m, EWDay d) {
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDate *date = EWDateFromMonthAndDay(m, d);
	NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit fromDate:date];
	
	[calendar release];
	return comps.weekday;
}
