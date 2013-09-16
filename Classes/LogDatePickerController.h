//
//  LogDatePickerController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/13/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "BRPopUpViewController.h"


@class LogViewController;


@interface LogDatePickerController : BRPopUpViewController {
	LogViewController *__weak logViewController;
	UIDatePicker *datePicker;
}
@property (nonatomic,weak) IBOutlet LogViewController *logViewController;
@property (nonatomic,strong) IBOutlet UIDatePicker *datePicker;
- (IBAction)pickToday;
- (IBAction)goToPickedDate;
@end
