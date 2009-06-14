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
	UITableView *tableView;
	UISegmentedControl *auxControl;
	NSDateFormatter *sectionTitleFormatter;
	EWMonth earliestMonth, latestMonth;
	NSIndexPath *lastIndexPath;
	EWMonthDay scrollDestination;
}
+ (void)setCurrentMonthDay:(EWMonthDay)monthday;
+ (EWMonthDay)currentMonthDay;
@property (nonatomic,retain) IBOutlet UITableView *tableView;
@property (nonatomic,retain) IBOutlet UISegmentedControl *auxControl;
@property (nonatomic,readonly) NSDate *currentDate;
- (void)scrollToDate:(NSDate *)date;
- (IBAction)goToDateAction;
- (IBAction)auxControlAction;
@end
