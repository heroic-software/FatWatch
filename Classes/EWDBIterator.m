/*
 * EWDBIterator.m
 * Created by Benjamin Ragheb on 9/17/10.
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

#import "EWDBIterator.h"
#import "EWDatabase.h"
#import "EWDBMonth.h"


@implementation EWDBIterator
{
	EWDatabase *database;
	EWDBMonth *dbm;
	EWMonthDay currentMonthDay;
	EWMonthDay earliestMonthDay;
	EWMonthDay latestMonthDay;
	BOOL skipEmptyRecords;
}

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
