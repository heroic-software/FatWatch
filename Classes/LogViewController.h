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
@class LogInfoPickerController;
@class LogDatePickerController;
@class EWDBMonth;
@class EWDatabase;


@interface LogViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	EWDatabase *database;
	UITableView *tableView;
	NSDateFormatter *sectionTitleFormatter;
	EWMonth earliestMonth, latestMonth;
	NSIndexPath *lastIndexPath;
	EWMonthDay scrollDestination;
	LogInfoPickerController *infoPickerController;
	LogDatePickerController *datePickerController;
}
+ (void)setCurrentMonthDay:(EWMonthDay)monthday;
+ (EWMonthDay)currentMonthDay;
@property (nonatomic,retain) EWDatabase *database;
@property (nonatomic,retain) IBOutlet UITableView *tableView;
@property (nonatomic,retain) IBOutlet LogInfoPickerController *infoPickerController;
@property (nonatomic,retain) IBOutlet LogDatePickerController *datePickerController;
@property (nonatomic,readonly) NSDate *currentDate;
- (void)scrollToDate:(NSDate *)date;
@end
