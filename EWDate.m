//
//  EWDate.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/12/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "EWDate.h"


static NSCalendar *calendar = nil;
static NSDate *refDate = nil;
static NSDateComponents *components = nil;


const NSInteger kReferenceYear = 2001;
const NSInteger kReferenceMonth = 1;
const NSInteger kReferenceDay = 1;


void EWDateInit() {
	calendar = [[NSCalendar currentCalendar] retain];
	
	// Create reference date relative to the current time zone
	NSDateComponents *refComps = [[NSDateComponents alloc] init];
	refComps.year = kReferenceYear;
	refComps.month = kReferenceMonth;
	refComps.day = kReferenceDay;
	refDate = [[calendar dateFromComponents:refComps] retain];
	[refComps release];
	
	components = [[NSDateComponents alloc] init];
}


NSUInteger EWDaysInMonth(EWMonth m) {
	components.month = m;
	components.day = 0;
	NSDate *monthDate = [calendar dateByAddingComponents:components
												  toDate:refDate
												 options:0];
	NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit
								   inUnit:NSMonthCalendarUnit
								  forDate:monthDate];
	return range.length;
}


NSDate *EWDateFromMonthAndDay(EWMonth m, EWDay d) {
	components.month = m;
	components.day = d - 1;
	NSDate *theDate = [calendar dateByAddingComponents:components
												toDate:refDate
											   options:0];
	return theDate;
}


EWMonthDay EWMonthDayFromDate(NSDate *theDate) {
	NSDateComponents *dc = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:theDate];
	EWMonth month = ((dc.year - kReferenceYear) * 12) + (dc.month - 1);
	return EWMonthDayMake(month, dc.day);
}


BOOL EWMonthAndDayIsWeekend(EWMonth m, EWDay d) {
	NSDate *date = EWDateFromMonthAndDay(m, d);
	NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit fromDate:date];
	return (comps.weekday == 1 || comps.weekday == 7);
}
