//
//  LogEntryViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/30/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "LogEntryViewController.h"
#import "Database.h"
#import "MonthData.h"
#import "WeightFormatter.h"


const CGFloat kWeightPickerComponentWidth = 320 - 88;


@implementation LogEntryViewController


@synthesize monthData;
@synthesize day;
@synthesize weighIn;


- (id)init {
	if (self = [super initWithNibName:@"LogEntryView" bundle:nil]) {
		titleFormatter = [[NSDateFormatter alloc] init];
		[titleFormatter setDateStyle:NSDateFormatterMediumStyle];
		[titleFormatter setTimeStyle:NSDateFormatterNoStyle];

		scaleIncrement = [WeightFormatter scaleIncrement];
		NSAssert(scaleIncrement > 0, @"scale increment must be greater than 0");
	}
	return self;
}


- (NSInteger)pickerRowForWeight:(float)weight {
	return weight / scaleIncrement;
}


- (float)weightForPickerRow:(NSInteger)row {
	return row * scaleIncrement;
}


- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.navigationItem.leftBarButtonItem = cancelButton;
	self.navigationItem.rightBarButtonItem = saveButton;
}


- (void)dealloc {
	[titleFormatter release];
	[super dealloc];
}


- (void)toggleWeight {
	if (weightControl.selectedSegmentIndex == 0) {
		if ([weightPickerView superview] == nil) {
			[noWeightView removeFromSuperview];
			[weightContainerView addSubview:weightPickerView];
		}
	} else {
		if ([noWeightView superview] == nil) {
			[weightPickerView removeFromSuperview];
			[weightContainerView addSubview:noWeightView];
		}
	}
}


- (void)toggleWeightAction:(id)sender {
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[animation setDuration:0.3];
	if (weightControl.selectedSegmentIndex == 0) {
		[animation setSubtype:kCATransitionFromLeft];
	} else {
		[animation setSubtype:kCATransitionFromRight];
	}
	[self toggleWeight];
	[[weightContainerView layer] addAnimation:animation forKey:nil];
}


- (IBAction)cancelAction:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)saveAction:(id)sender {
	float weight;
	if (weightControl.selectedSegmentIndex == 0) {
		NSInteger row = [weightPickerView selectedRowInComponent:0];
		weight = [self weightForPickerRow:row];
	} else {
		weight = 0;
	}
	[monthData setMeasuredWeight:weight 
							flag:flagControl.selectedSegmentIndex
							note:noteField.text
						   onDay:day];
	[[Database sharedDatabase] commitChanges];
	[self dismissModalViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self
			   selector:@selector(keyboardWillShow:)
				   name:UIKeyboardWillShowNotification
				 object:nil];
	[center addObserver:self
			   selector:@selector(keyboardWillHide:)
				   name:UIKeyboardWillHideNotification
				 object:nil];
	
	NSDate *date = [monthData dateOnDay:day];
	self.title = [titleFormatter stringFromDate:date];

	float weight = [monthData measuredWeightOnDay:day];
	weightControl.selectedSegmentIndex = (weight > 0 || weighIn) ? 0 : 1;

	if (weight == 0) {
		weight = [monthData inputTrendOnDay:day];
		if (weight == 0) {
			Database *db = [Database sharedDatabase];
			
			weight = [[db dataForMonth:[db earliestMonth]] inputTrendOnDay:31];
			if (weight == 0) {
				weight = 150.0f;
			}
		}
	}
	int row = [self pickerRowForWeight:weight];
	[weightPickerView selectRow:row inComponent:0 animated:NO];
	[weightPickerView becomeFirstResponder];
	
	flagControl.selectedSegmentIndex = [monthData isFlaggedOnDay:day];
	
	noteField.text = [monthData noteOnDay:day];

	[self toggleWeight];
}


- (void)keyboardWillShow:(NSNotification *)notice {
	NSValue *kbBoundsValue = [[notice userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
	float kbHeight = CGRectGetHeight([kbBoundsValue CGRectValue]);
	
	UIView *view = self.view;
	CGRect rect = view.bounds;
	if (rect.origin.y < kbHeight) {
		[UIView beginAnimations:@"keyboardWillShow" context:nil];
		[UIView setAnimationDuration:0.3];
		rect.origin.y = kbHeight;
		view.bounds = rect;
		weightContainerView.alpha = 0;
		[UIView commitAnimations];
	}
}


- (void)keyboardWillHide:(NSNotification *)notice {
	UIView *view = self.view;
	CGRect rect = view.bounds;
	if (rect.origin.y > 0) {
		[UIView beginAnimations:@"keyboardWillHide" context:nil];
		[UIView setAnimationDuration:0.3];
		rect.origin.y = 0;
		view.bounds = rect;
		weightContainerView.alpha = 1;
		[UIView commitAnimations];
	}
}


- (void)viewWillDisappear:(BOOL)animated {
	[noteField resignFirstResponder];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark UITextFieldDelegate (Optional)


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return [textField resignFirstResponder];
}


#pragma mark UIPickerViewDelegate (Required)


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [self pickerRowForWeight:500.0f];
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	return kWeightPickerComponentWidth;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel *label;
	
	if ([view isKindOfClass:[UILabel class]]) {
		label = (UILabel *)view;
	} else {
		label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kWeightPickerComponentWidth, 44)];
		label.textAlignment = UITextAlignmentCenter;
		label.textColor = [UIColor blackColor];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize:20];
	}

	label.text = [[WeightFormatter sharedFormatter] stringFromMeasuredWeight:[self weightForPickerRow:row]];
	return label;
}


@end
