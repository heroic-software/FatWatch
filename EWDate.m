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


void EWDateInit() {
	calendar = [[NSCalendar currentCalendar] retain];
	refDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:0];
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


NSDate *NSDateFromEWMonthAndDay(EWMonth m, EWDay d) {
	components.month = m;
	components.day = d;
	NSDate *theDate = [calendar dateByAddingComponents:components
												toDate:refDate
											   options:0];
	return theDate;
}


EWMonth EWMonthFromDate(NSDate *theDate) {
	NSDateComponents *components;
	components = [calendar components:NSMonthCalendarUnit | NSDayCalendarUnit
							 fromDate:refDate
							   toDate:theDate
							  options:0];
	return components.month;
}


EWDay EWDayFromDate(NSDate *theDate) {
	NSDateComponents *components;
	components = [calendar components:NSDayCalendarUnit fromDate:theDate];
	return components.day;
}
