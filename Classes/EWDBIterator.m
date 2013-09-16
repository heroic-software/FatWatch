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
@synthesize earliestMonthDay;
@synthesize latestMonthDay;
@synthesize skipEmptyRecords;


- (id)initWithDatabase:(EWDatabase *)db
{
	if ((self = [super init])) {
		database = db;
		earliestMonthDay = EWMonthDayMake(database.earliestMonth, 1);
		latestMonthDay = EWMonthDayMake(database.latestMonth, 31);
	}
	return self;
}




- (const EWDBDay *)currentDBDay
{
	EWMonth month = EWMonthDayGetMonth(currentMonthDay);
	if (dbm == nil || dbm.month != month) {
		dbm = [database getDBMonth:month];
	}
	return [dbm getDBDayOnDay:EWMonthDayGetDay(currentMonthDay)];
}


- (BOOL)shouldSkipDBDay:(const EWDBDay *)dd
{
	return skipEmptyRecords && EWDBDayIsEmpty(dd);
}


- (const EWDBDay *)nextDBDay
{
	NSAssert(earliestMonthDay != 0, @"Iterator earliestMonthDay not set");
	NSAssert(latestMonthDay != 0, @"Iterator latestMonthDay not set");
	const EWDBDay *dd;
	do {
		if (currentMonthDay == 0) {
			currentMonthDay = earliestMonthDay;
		} else {
			currentMonthDay = EWMonthDayNext(currentMonthDay);
		}
		if (currentMonthDay > latestMonthDay) return NULL;
		dd = [self currentDBDay];
	} while ([self shouldSkipDBDay:dd]);
	return dd;
}


- (const EWDBDay *)previousDBDay
{
	NSAssert(earliestMonthDay != 0, @"Iterator earliestMonthDay not set");
	NSAssert(latestMonthDay != 0, @"Iterator latestMonthDay not set");
	const EWDBDay *dd;
	do {
		if (currentMonthDay == 0) {
			currentMonthDay = latestMonthDay;
		} else {
			currentMonthDay = EWMonthDayPrevious(currentMonthDay);
		}			
		if (currentMonthDay < earliestMonthDay) return NULL;
		dd = [self currentDBDay];
	} while ([self shouldSkipDBDay:dd]);
	return dd;
}


@end
