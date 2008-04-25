//
//  LogViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EWDate.h"

@class LogEntryViewController;
@class MonthData;

@interface LogViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	LogEntryViewController *logEntryViewController;
	BOOL firstLoad;
	EWMonth earliestMonth;
	NSDateFormatter *sectionTitleFormatter;
	NSUInteger numberOfSections;
	NSIndexPath *lastIndexPath;
}
- (void)presentLogEntryViewForMonthData:(MonthData *)monthData onDay:(EWDay)day weighIn:(BOOL)flag;
@end
