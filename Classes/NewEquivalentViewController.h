/*
 * NewEquivalentViewController.h
 * Created by Benjamin Ragheb on 1/9/10.
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
