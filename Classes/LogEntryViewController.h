//
//  LogEntryViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/30/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EWDate.h"

@class BRTextView;
@class MonthData;

@interface LogEntryViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate> {
	MonthData *monthData;
	EWDay day;
	BOOL weighIn;
	IBOutlet UISegmentedControl *weightControl;
	IBOutlet UIView *weightContainerView;
	IBOutlet UIPickerView *weightPickerView;
	IBOutlet UIView *noWeightView;
	IBOutlet UISegmentedControl *flagControl;
	IBOutlet BRTextView *noteView;
	float scaleIncrement;
}
+ (LogEntryViewController *)sharedController;
@property (nonatomic,retain) MonthData *monthData;
@property (nonatomic) EWDay day;
@property (nonatomic,getter=isWeighIn) BOOL weighIn;
- (IBAction)toggleWeightAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;
@end
