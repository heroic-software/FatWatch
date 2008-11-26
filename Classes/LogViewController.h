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
	IBOutlet UITableView *tableView;
	NSDateFormatter *sectionTitleFormatter;
	EWMonth earliestMonth, latestMonth;
	NSIndexPath *lastIndexPath;
	EWMonthDay scrollDestination;
}
@property (nonatomic,readonly) NSDate *currentDate;
- (void)scrollToDate:(NSDate *)date;
- (IBAction)goToDateAction;
@end
