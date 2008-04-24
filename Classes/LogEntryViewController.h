//
//  LogEntryViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/30/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EWDate.h"

@class MonthData;

@interface LogEntryViewController : UIViewController <UIModalViewDelegate, UIPickerViewDelegate, UITextFieldDelegate> {
	MonthData *monthData;
	EWDay day;
	BOOL weighIn;
	UISegmentedControl *weightControl;
	UIPickerView *weightPickerView;
	UIView *noWeightView;
	UIView *flagAndNoteView;
	UISegmentedControl *flagControl;
	UITextField *noteField;
	NSDateFormatter *titleFormatter;
	float scaleIncrement;
}
@property (nonatomic,retain) MonthData *monthData;
@property (nonatomic) EWDay day;
@property (nonatomic,getter=isWeighIn) BOOL weighIn;
@end
