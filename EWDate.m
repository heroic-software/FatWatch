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
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

	NSDate *refDateGMT = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
	NSTimeInterval refDateOffset = -[[calendar timeZone] secondsFromGMTForDate:refDateGMT];
	NSDate *refDate = [refDateGMT addTimeInterval:refDateOffset];

	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.month = m;
	NSDate *monthDate = [calendar dateByAddingComponents:components
												  toDate:refDate
												 options:0];
	NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit
								   inUnit:NSMonthCalendarUnit
								  forDate:monthDate];
	[components release];
	[calendar release];
	return range.length;
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
