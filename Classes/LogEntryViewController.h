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
@class EWDBMonth;

@interface LogEntryViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate> {
	EWDBMonth *monthData;
	EWDay day;
	BOOL weighIn;
	UISegmentedControl *weightControl;
	UIView *weightContainerView;
	UIPickerView *weightPickerView;
	UIView *noWeightView;
	UISegmentedControl *flagControl;
	BRTextView *noteView;
	UIView *annotationContainerView;
	UINavigationBar *navigationBar;
	float scaleIncrement;
	NSInteger weightRow, fatRow;
	int weightMode;
}
+ (LogEntryViewController *)sharedController;
@property (nonatomic,retain) IBOutlet UISegmentedControl *weightControl;
@property (nonatomic,retain) IBOutlet UIView *weightContainerView;
@property (nonatomic,retain) IBOutlet UIPickerView *weightPickerView;
@property (nonatomic,retain) IBOutlet UIView *noWeightView;
@property (nonatomic,retain) IBOutlet UISegmentedControl *flagControl;
@property (nonatomic,retain) IBOutlet BRTextView *noteView;
@property (nonatomic,retain) IBOutlet UIView *annotationContainerView;
@property (nonatomic,retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic,retain) EWDBMonth *monthData;
@property (nonatomic) EWDay day;
@property (nonatomic,getter=isWeighIn) BOOL weighIn;
- (IBAction)toggleWeightAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;
@end
