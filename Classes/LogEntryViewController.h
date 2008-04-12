//
//  LogEntryViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/30/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MonthData;

@interface LogEntryViewController : UIViewController <UIPickerViewDelegate, UITextFieldDelegate> {
	MonthData *monthData;
	unsigned day;
	UIPickerView *weightPickerView;
	UITextField *noteField;
}
@property (nonatomic,retain) MonthData *monthData;
@property (nonatomic) unsigned day;
@property (nonatomic,retain) UIPickerView *weightPickerView;
@property (nonatomic,retain) UITextField *noteField;
@end
