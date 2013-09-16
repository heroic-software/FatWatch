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


@interface LogViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate> {
	EWDatabase *database;
	UITableView *tableView;
	NSDateFormatter *sectionTitleFormatter;
	EWMonth earliestMonth, latestMonth;
	NSIndexPath *lastIndexPath;
	EWMonthDay scrollDestination;
	LogInfoPickerController *infoPickerController;
	LogDatePickerController *datePickerController;
}
@property (nonatomic,strong) IBOutlet EWDatabase *database;
@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,strong) IBOutlet LogInfoPickerController *infoPickerController;
@property (nonatomic,strong) IBOutlet LogDatePickerController *datePickerController;
@property (weak, nonatomic,readonly) NSDate *currentDate;
- (void)scrollToDate:(NSDate *)date;
@end
