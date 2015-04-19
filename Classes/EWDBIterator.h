/*
 * EWDBIterator.h
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


@interface EWDBIterator : NSObject
@property (nonatomic,readonly) EWMonthDay currentMonthDay;
@property (nonatomic) EWMonthDay earliestMonthDay;
@property (nonatomic) EWMonthDay latestMonthDay;
@property (nonatomic) BOOL skipEmptyRecords;
- (id)initWithDatabase:(EWDatabase *)db;
- (const EWDBDay *)nextDBDay;
- (const EWDBDay *)previousDBDay;
@end
