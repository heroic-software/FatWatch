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


@interface EWDBIterator : NSObject {
	EWDatabase *database;
	EWDBMonth *dbm;
	EWMonthDay currentMonthDay;
}
@property (nonatomic) EWMonthDay currentMonthDay;
- (id)initWithDatabase:(EWDatabase *)db;
- (const EWDBDay *)nextDBDay; // return current, then increment
- (const EWDBDay *)previousDBDay; // return current, then decrement
@end
