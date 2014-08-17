//
//  LogInfoPickerController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/13/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "BRPopUpViewController.h"


@interface LogInfoPickerController : BRPopUpViewController <UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic,strong) IBOutlet UIButton *infoTypeButton;
@property (nonatomic,strong) IBOutlet UIPickerView *infoTypePicker;
- (IBAction)toggleDown:(UIButton *)sender;
- (IBAction)toggleUp:(UIButton *)sender;
- (IBAction)toggleCancel:(UIButton *)sender;
@end
