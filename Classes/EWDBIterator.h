//
//  EWDBIterator.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWDate.h"
#import "EWDBMonth.h"


@class EWDatabase;


/*
 General idea: create an iterator, then optionally set the
 earliest/latestMonthDay properties (if you don't, they default to cover all 
 data in the database). Then call next/previousDBDay to fetch records one by
 one. NULL will be returned when you go outside of the range. The
 currentMonthDay property can be used to determine the monthday of the last
 record fetched.
 */


@interface EWDBIterator : NSObject {
	EWDatabase *database;
	EWDBMonth *dbm;
	EWMonthDay currentMonthDay;
	EWMonthDay earliestMonthDay;
	EWMonthDay latestMonthDay;
	BOOL skipEmptyRecords;
}
@property (nonatomic,readonly) EWMonthDay currentMonthDay;
@property (nonatomic) EWMonthDay earliestMonthDay;
@property (nonatomic) EWMonthDay latestMonthDay;
@property (nonatomic) BOOL skipEmptyRecords;
- (id)initWithDatabase:(EWDatabase *)db;
- (const EWDBDay *)nextDBDay;
- (const EWDBDay *)previousDBDay;
@end
