//
//  Database.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/7/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "/usr/include/sqlite3.h"
#import "EWDate.h"

@class MonthData;

@interface Database : NSObject {
	sqlite3 *database;
	NSMutableDictionary *monthCache;
}
- (EWMonth)earliestMonth;
- (MonthData *)dataForMonth:(EWMonth)m;
@end
