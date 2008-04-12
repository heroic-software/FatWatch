//
//  LogViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EWDate.h"

@class Database;
@class LogEntryViewController;
@class MonthData;

@interface LogViewController : UIViewController {
	Database *database;
	LogEntryViewController *logEntryViewController;
}
- (id)initWithDatabase:(Database *)db;
- (void)presentLogEntryViewForMonthData:(MonthData *)monthData onDay:(EWDay)day;
@end
