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
@class EWFlagButton;

@interface LogEntryViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
+ (LogEntryViewController *)sharedController;
@property (nonatomic,strong) IBOutlet UISegmentedControl *weightControl;
@property (nonatomic,strong) IBOutlet UIView *weightContainerView;
@property (nonatomic,strong) IBOutlet UIPickerView *weightPickerView;
@property (nonatomic,strong) IBOutlet UIView *noWeightView;
@property (nonatomic,strong) IBOutlet BRTextView *noteView;
@property (nonatomic,strong) IBOutlet UIView *annotationContainerView;
@property (nonatomic,strong) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic,strong) IBOutlet UIButton *flag0Button;
@property (nonatomic,strong) IBOutlet UIButton *flag1Button;
@property (nonatomic,strong) IBOutlet UIButton *flag2Button;
@property (nonatomic,strong) IBOutlet UIButton *flag3Button;
- (void)configureForDay:(EWDay)aDay dbMonth:(EWDBMonth *)aDBMonth;
- (IBAction)toggleWeightAction:(id)sender;
- (IBAction)toggleFlagButton:(UIButton *)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;
@end
