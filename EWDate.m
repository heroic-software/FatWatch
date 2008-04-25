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

void EWDateInit()
{
	calendar = [[NSCalendar currentCalendar] retain];
	refDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:0];
}

NSUInteger EWDaysInMonth(EWMonth m)
{
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.month = m;
	NSDate *monthDate = [calendar dateByAddingComponents:components
												  toDate:refDate
												 options:0];
	NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit
								   inUnit:NSMonthCalendarUnit
								  forDate:monthDate];
	[components release];
	return range.length;
}

NSDate *NSDateFromEWMonthAndDay(EWMonth m, EWDay d)
{
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.month = m;
	components.day = d;
	NSDate *theDate = [calendar dateByAddingComponents:components
												toDate:refDate
											   options:0];
	[components release];
	return theDate;
}

EWMonth EWMonthFromDate(NSDate *theDate)
{
	NSDateComponents *components;
	components = [calendar components:NSMonthCalendarUnit | NSDayCalendarUnit
							 fromDate:refDate
							   toDate:theDate
							  options:0];
	return components.month;
}

EWDay EWDayFromDate(NSDate *theDate)
{
	NSDateComponents *components;
	components = [calendar components:NSDayCalendarUnit fromDate:theDate];
	return components.day;
}
