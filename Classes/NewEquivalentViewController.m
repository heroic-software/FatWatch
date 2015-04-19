/*
 * NewEquivalentViewController.m
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

#import "NewEquivalentViewController.h"
#import "NSUserDefaults+EWAdditions.h"


@interface NewEquivalentViewController ()
- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
@end


@implementation NewEquivalentViewController
{
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
	BOOL validationPending;
}

@synthesize newEquivalent;
@synthesize nameField;
@synthesize energyField;
@synthesize unitField;
@synthesize metLabel;
@synthesize metSlider;
@synthesize energyPerLabel;
@synthesize groupHostView;
@synthesize activityGroupView;
@synthesize foodGroupView;
@synthesize typeControl;


- (id)init {
    if ((self = [super initWithNibName:@"NewEquivalentView" bundle:nil])) {
		self.title = NSLocalizedString(@"Add Equivalent", @"new equivalent view title");
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction:)];
    }
    return self;
}


- (BOOL)isValid {
	return ([nameField.text length] > 0
			&&
			((typeControl.selectedSegmentIndex == 0 &&
			  metSlider.value >= 1)
			 ||
			 (typeControl.selectedSegmentIndex == 1 &&
			  ([energyField.text length] > 0) &&
			  ([unitField.text length] > 0))));
}


- (void)validateForm {
	UIBarButtonItem *saveButton = self.navigationItem.rightBarButtonItem;
	saveButton.enabled = [self isValid];
	validationPending = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	switch ([[NSUserDefaults standardUserDefaults] energyUnit]) {
		case EWEnergyUnitKilojoules:
			self.energyPerLabel.text = NSLocalizedString(@"kJ per", nil);
			break;
		case EWEnergyUnitCalories:
		default:
			self.energyPerLabel.text = NSLocalizedString(@"cal per", nil);
			break;
	}
	[self changeType:nil];
}


- (void)viewWillAppear:(BOOL)animated {
	nameField.text = nil;
	energyField.text = nil;
	[self changeMetValue:nil];
	self.navigationItem.rightBarButtonItem.enabled = NO;
}


- (IBAction)changeType:(id)sender {
	UIView *oldView, *newView;
	if (typeControl.selectedSegmentIndex == 0) {
		newView = activityGroupView;
		oldView = foodGroupView;
		[nameField resignFirstResponder];
	} else {
		newView = foodGroupView;
		oldView = activityGroupView;
		[energyField becomeFirstResponder];
	}
	[oldView removeFromSuperview];
	newView.frame = groupHostView.bounds;
	[groupHostView addSubview:newView];
	[self validateForm];
}


- (IBAction)changeMetValue:(id)sender {
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterDecimalStyle];
	[nf setMinimumFractionDigits:1];
	[nf setMaximumFractionDigits:1];
	[nf setPositiveSuffix:@" MET"];
	metLabel.text = [nf stringFromNumber:@(metSlider.value)];
}


- (IBAction)saveAction:(id)sender {
	if (![self isValid]) return;
	id <EWEnergyEquivalent> equiv;
	if (typeControl.selectedSegmentIndex == 0) {
		equiv = [[EWActivityEquivalent alloc] init];
		equiv.value = metSlider.value;
	} else {
		equiv = [[EWFoodEquivalent alloc] init];
		equiv.unitName = unitField.text;
		// floatValue is safe because user can only enter digits into field
		equiv.value = [energyField.text floatValue];
	}
	equiv.name = nameField.text;
	self.newEquivalent = equiv;
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cancelAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark UITextFieldDelegate


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (!validationPending) {
		[self performSelector:@selector(validateForm) withObject:nil afterDelay:0.1];
	}
	return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == nameField) {
		[nameField resignFirstResponder];
		if (typeControl.selectedSegmentIndex == 0) {
			[metSlider becomeFirstResponder];
		} else {
			[energyField becomeFirstResponder];
		}
	}
	else if (textField == energyField) {
		[unitField becomeFirstResponder];
	}
	else if (textField == unitField) {
		[nameField becomeFirstResponder];
	}
	[self validateForm];
	return NO;
}


@end
