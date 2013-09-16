//
//  HeightEntryViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 11/15/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HeightEntryViewController : UIViewController {
	UIPickerView *pickerView;
	NSFormatter *formatter;
	float increment;
}
@property (nonatomic,strong) IBOutlet UIPickerView *pickerView;
+ (UIViewController *)controller;
- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
@end
