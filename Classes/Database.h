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

#define kMonthColumnIndex 0
#define kDayColumnIndex 1
#define kMeasuredValueColumnIndex 2
#define kTrendValueColumnIndex 3
#define kFlagColumnIndex 4
#define kNoteColumnIndex 5

@class MonthData;

@interface Database : NSObject {
	sqlite3 *database;
	NSMutableDictionary *monthCache;
}
- (sqlite3_stmt *)prepareStatement:(const char *)sql;
- (void)close;
- (EWMonth)earliestMonth;
- (MonthData *)dataForMonth:(EWMonth)m;
- (MonthData *)dataForMonthBefore:(EWMonth)m;
- (MonthData *)dataForMonthAfter:(EWMonth)m;
- (float)minimumWeight;
- (float)maximumWeight;
- (void)commitChanges;
@end
