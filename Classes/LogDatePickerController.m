/*
 * LogDatePickerController.m
 * Created by Benjamin Ragheb on 12/13/09.
 * Copyright 2015 Heroic Software Inc
 *
 * This file is part of FatWatch.
 *
 * FatWatch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FatWatch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
 */

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
