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
	
	// Create reference date relative to the current time zone
	NSDateComponents *refComps = [[NSDateComponents alloc] init];
	refComps.year = 2001;
	refComps.month = 1;
	refComps.day = 1;
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
	NSDateComponents *monthComponents = [calendar components:NSMonthCalendarUnit | NSDayCalendarUnit fromDate:refDate toDate:theDate options:0];
	NSDateComponents *dayComponents = [calendar components:NSDayCalendarUnit fromDate:theDate];
	return EWMonthDayMake(monthComponents.month, dayComponents.day);
}
