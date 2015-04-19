/*
 * EWDate.m
 * Created by Benjamin Ragheb on 4/12/08.
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


static const NSInteger kReferenceYear = 2001;
// static const NSInteger kReferenceMonth = 1;
// static const NSInteger kReferenceDay = 1;


int EWDaysInMonth(EWMonth m) {
	static unsigned int dayCount[12] = {
		31, 28, 31, // Jan Feb Mar
		30, 31, 30, // Apr May Jun
		31, 31, 30, // Jul Aug Sep
		31, 30, 31  // Oct Nov Dec
	};
	
	int m0 = (m % 12);

	if (m0 < 0) m0 += 12;
	
	if (m0 == 1) {
		NSInteger year = (24012 + m) / 12; 	// 0 = 2001-01
		if (((year % 4 == 0) && (year % 100) != 0) || ((year % 400) == 0)) {
			return 29;
		}
	}
	
	return dayCount[m0];
}


NSInteger EWDaysBetweenMonthDays(EWMonthDay mdA, EWMonthDay mdB) {
	if (EWMonthDayGetMonth(mdB) == EWMonthDayGetMonth(mdA)) {
		return EWMonthDayGetDay(mdB) - EWMonthDayGetDay(mdA);
	}
	NSDate *dateA = EWDateFromMonthDay(mdA);
	NSDate *dateB = EWDateFromMonthDay(mdB);
	static const NSTimeInterval kSecondsPerDay = 60 * 60 * 24;
	// Because of daylight savings, the difference might be slightly more or 
	// less than a full day, so we must round.
	return (NSInteger)round([dateB timeIntervalSinceDate:dateA] / kSecondsPerDay);
}


EWMonthDay EWMonthDayNext(EWMonthDay md) {
	if (EWMonthDayGetDay(md) < 28) { // no month has fewer than 28 days
		return md + 1;
	} 
	EWMonth month = EWMonthDayGetMonth(md);
	if (EWMonthDayGetDay(md) < EWDaysInMonth(month)) {
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
	if (d == 0) return nil;
	
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [[NSDateComponents alloc] init];

	NSInteger m0 = (m % 12);
	if (m0 < 0) m0 += 12;
	
	[components setYear:((24012 + m) / 12)];
	[components setMonth:(m0 + 1)];
	[components setDay:d];
	
	NSDate *theDate = [calendar dateFromComponents:components];
	
	return theDate;
}


EWMonthDay EWMonthDayFromDate(NSDate *theDate) {
	if (theDate == nil) return 0;
	
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

	NSDateComponents *dc = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:theDate];
	EWMonth month = (EWMonth)(((dc.year - kReferenceYear) * 12) + (dc.month - 1));
	
	return EWMonthDayMake(month, (EWDay)dc.day);
}


EWMonthDay EWMonthDayToday() {
	static EWMonthDay today = 0;
	
	if (today == 0) {
		today = EWMonthDayFromDate([NSDate date]);
	}
	
	return today;
}


BOOL EWMonthAndDayIsWeekend(EWMonth m, EWDay d) {
	NSUInteger weekday = EWWeekdayFromMonthAndDay(m, d);
	return (weekday == 1 || weekday == 7);
}


NSUInteger EWWeekdayFromMonthAndDay(EWMonth m, EWDay d) {
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDate *date = EWDateFromMonthAndDay(m, d);
	NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit fromDate:date];
	
	return comps.weekday;
}
