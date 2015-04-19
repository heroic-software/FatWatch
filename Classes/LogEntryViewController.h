/*
 * LogEntryViewController.h
 * Created by Benjamin Ragheb on 3/30/08.
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
