//
//  NewEquivalentViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/9/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWEnergyEquivalent.h"


@interface NewEquivalentViewController : UIViewController {
	UITextField *nameField;
	UITextField *energyField;
	UITextField *unitField;
	UISlider *metSlider;
	UILabel *metLabel;
	UILabel *energyPerLabel;
	UIView *groupHostView;
	UIView *activityGroupView;
	UIView *foodGroupView;
	UISegmentedControl *typeControl;
	id <EWEnergyEquivalent> newEquivalent;
}
@property (nonatomic,retain) id <EWEnergyEquivalent> newEquivalent;
@property (nonatomic,retain) IBOutlet UITextField *nameField;
@property (nonatomic,retain) IBOutlet UITextField *energyField;
@property (nonatomic,retain) IBOutlet UITextField *unitField;
@property (nonatomic,retain) IBOutlet UISlider *metSlider;
@property (nonatomic,retain) IBOutlet UILabel *metLabel;
@property (nonatomic,retain) IBOutlet UILabel *energyPerLabel;
@property (nonatomic,retain) IBOutlet UIView *groupHostView;
@property (nonatomic,retain) IBOutlet UIView *activityGroupView;
@property (nonatomic,retain) IBOutlet UIView *foodGroupView;
@property (nonatomic,retain) IBOutlet UISegmentedControl *typeControl;
- (IBAction)changeType:(id)sender;
- (IBAction)changeMetValue:(id)sender;
@end
