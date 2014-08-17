//
//  NewEquivalentViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/9/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWEnergyEquivalent.h"


@interface NewEquivalentViewController : UIViewController
@property (nonatomic,strong,getter=equivalent,setter=setEquivalent:) id <EWEnergyEquivalent> newEquivalent;
@property (nonatomic,strong) IBOutlet UITextField *nameField;
@property (nonatomic,strong) IBOutlet UITextField *energyField;
@property (nonatomic,strong) IBOutlet UITextField *unitField;
@property (nonatomic,strong) IBOutlet UISlider *metSlider;
@property (nonatomic,strong) IBOutlet UILabel *metLabel;
@property (nonatomic,strong) IBOutlet UILabel *energyPerLabel;
@property (nonatomic,strong) IBOutlet UIView *groupHostView;
@property (nonatomic,strong) IBOutlet UIView *activityGroupView;
@property (nonatomic,strong) IBOutlet UIView *foodGroupView;
@property (nonatomic,strong) IBOutlet UISegmentedControl *typeControl;
- (IBAction)changeType:(id)sender;
- (IBAction)changeMetValue:(id)sender;
@end
