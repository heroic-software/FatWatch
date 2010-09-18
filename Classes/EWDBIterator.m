//
//  EWDBIterator.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EWDBIterator.h"
#import "EWDatabase.h"
#import "EWDBMonth.h"


@implementation EWDBIterator


@synthesize currentMonthDay;


- (id)initWithDatabase:(EWDatabase *)db
{
	if ((self = [super init])) {
		database = [db retain];
	}
	return self;
}


- (void)dealloc
{
	[database release];
	[dbm release];
	[super dealloc];
}


- (const EWDBDay *)currentDBDay
{
	EWMonth month = EWMonthDayGetMonth(currentMonthDay);
	if (dbm == nil || dbm.month != month) {
		[dbm release];
		dbm = [[database getDBMonth:month] retain];
	}
	return [dbm getDBDayOnDay:EWMonthDayGetDay(currentMonthDay)];
}


- (const EWDBDay *)nextDBDay // return current, then increment
{
	const EWDBDay *dd = [self currentDBDay];
	currentMonthDay = EWMonthDayNext(currentMonthDay);
	return dd;
}


- (const EWDBDay *)previousDBDay // return current, then decrement
{
	const EWDBDay *dd = [self currentDBDay];
	currentMonthDay = EWMonthDayPrevious(currentMonthDay);
	return dd;
}


@end
