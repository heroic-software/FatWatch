//
//  LogInfoPickerController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/13/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "BRPopUpViewController.h"


@interface LogInfoPickerController : BRPopUpViewController <UIPickerViewDelegate,UIPickerViewDataSource> {
	UIButton *infoTypeButton;
	UIPickerView *infoTypePicker;
	NSArray *infoTypeArray;
}
@property (nonatomic,retain) IBOutlet UIButton *infoTypeButton;
@property (nonatomic,retain) IBOutlet UIPickerView *infoTypePicker;
- (void)updateButton;
@end
