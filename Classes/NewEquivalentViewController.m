//
//  NewEquivalentViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/9/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "NewEquivalentViewController.h"
#import "NSUserDefaults+EWAdditions.h"

@implementation NewEquivalentViewController


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
    if (self = [super initWithNibName:@"NewEquivalentView" bundle:nil]) {
		self.title = NSLocalizedString(@"Add Equivalent", @"new equivalent view title");
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)] autorelease];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction:)] autorelease];
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
	metLabel.text = [nf stringFromNumber:[NSNumber numberWithFloat:metSlider.value]];
	[nf release];
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
	[equiv release];
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


#pragma mark Cleanup


- (void)dealloc {
	[nameField release];
	[energyField release];
	[unitField release];
	[metSlider release];
	[metLabel release];
	[energyPerLabel release];
	[groupHostView release];
	[activityGroupView release];
	[foodGroupView release];
	[typeControl release];
    [super dealloc];
}


@end
