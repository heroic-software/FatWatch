//
//  LogDatePickerController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/13/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "LogDatePickerController.h"
#import "LogViewController.h"


@implementation LogDatePickerController
{
	LogViewController *__weak logViewController;
	UIDatePicker *datePicker;
}

@synthesize logViewController;
@synthesize datePicker;


- (void)awakeFromNib {
	datePicker.minimumDate = [NSDate distantPast];
	datePicker.maximumDate = [NSDate date];
}


- (void)willShow {
	[datePicker setDate:[logViewController currentDate] animated:NO];
}


- (IBAction)pickToday {
	[datePicker setDate:[NSDate date] animated:YES];
}


- (IBAction)goToPickedDate {
	[logViewController scrollToDate:[datePicker date]];
	[self hideAnimated:YES];
}




@end
