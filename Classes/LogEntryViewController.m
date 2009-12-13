//
//  LogEntryViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/30/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "LogEntryViewController.h"
#import "EWDatabase.h"
#import "EWDBMonth.h"
#import "WeightFormatters.h"
#import "BRTextView.h"


const CGFloat kWeightPickerComponentWidth = 320 - 88;


enum {
	kModeWeight,
	kModeWeightAndFat,
	kModeNone
};


@implementation LogEntryViewController


+ (LogEntryViewController *)sharedController {
	static LogEntryViewController *controller = nil;
	
	if (controller == nil) {
		controller = [[LogEntryViewController alloc] init];
		[controller view];
	}
	
	return controller;
}


@synthesize weightControl;
@synthesize weightContainerView;
@synthesize weightPickerView;
@synthesize noWeightView;
@synthesize flagControl;
@synthesize noteView;
@synthesize annotationContainerView;
@synthesize navigationBar;
@synthesize monthData;
@synthesize day;
@synthesize weighIn;


- (id)init {
	if (self = [super initWithNibName:@"LogEntryView" bundle:nil]) {
		scaleIncrement = [WeightFormatters scaleIncrement];
		NSAssert(scaleIncrement > 0, @"scale increment must be greater than 0");
	}
	return self;
}


- (void)dealloc {
	[weightControl release];
	[weightContainerView release];
	[weightPickerView release];
	[noWeightView release];
	[flagControl release];
	[noteView release];
	[annotationContainerView release];
	[navigationBar release];
	[super dealloc];
}


- (NSInteger)pickerRowForWeight:(float)weight {
	return roundf(weight / scaleIncrement);
}


- (float)weightForPickerRow:(NSInteger)row {
	return row * scaleIncrement;
}


- (NSInteger)pickerRowForBodyFat:(float)bodyFat {
	return roundf(bodyFat * 1000.0f);
}


- (float)bodyFatForPickerRow:(NSInteger)row {
	return row / 1000.0f;
}


- (void)toggleWeight {
	if (weightMode == kModeWeight || weightMode == kModeWeightAndFat) {
		if ([weightPickerView superview] == nil) {
			[noWeightView removeFromSuperview];
			[weightContainerView addSubview:weightPickerView];
		}
		[weightPickerView reloadAllComponents];
		[weightPickerView selectRow:weightRow inComponent:0 animated:NO];
		if (weightMode == kModeWeightAndFat) {
			[weightPickerView selectRow:fatRow inComponent:1 animated:NO];
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
	[animation setType:kCATransitionPush];
	[animation setSubtype:((weightMode < weightControl.selectedSegmentIndex) 
						   ? kCATransitionFromRight
						   : kCATransitionFromLeft)];

	weightMode = weightControl.selectedSegmentIndex;
	[self toggleWeight];
	
	[[weightContainerView layer] addAnimation:animation forKey:nil];
}


- (IBAction)cancelAction:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)saveAction:(id)sender {
	float scaleWeight, scaleFat;
	
	if (weightMode == kModeWeight) {
		scaleWeight = [self weightForPickerRow:weightRow];
		scaleFat = 0;
	} else if (weightMode == kModeWeightAndFat) {
		scaleWeight = [self weightForPickerRow:weightRow];
		scaleFat = [self bodyFatForPickerRow:fatRow];
	} else {
		scaleWeight = 0;
		scaleFat = 0;
	}
	
	[monthData setScaleWeight:scaleWeight
					 scaleFat:scaleFat
						 flag:flagControl.selectedSegmentIndex
						 note:noteView.text
						onDay:day];

	[[EWDatabase sharedDatabase] commitChanges];
	
	[self dismissModalViewControllerAnimated:YES];
}


- (float)chooseDefaultWeight {
	// no weight on this day, so get the trend on this day, searching earlier months if needed
	float weight = [monthData inputTrendOnDay:day];
	if (weight > 0) return weight;
	
	// there is no weight on or earlier than this day, so find first measurement
	weight = [[EWDatabase sharedDatabase] earliestWeight];
	if (weight > 0) return weight;

	// database is empty!
	return 200.0f;
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
	NSDateFormatter *titleFormatter = [[NSDateFormatter alloc] init];
	[titleFormatter setDateStyle:NSDateFormatterMediumStyle];
	[titleFormatter setTimeStyle:NSDateFormatterNoStyle];
	navigationBar.topItem.title = [titleFormatter stringFromDate:date];
	[titleFormatter release];

	struct EWDBDay *dd = [monthData getDBDay:day];

	weightRow = [self pickerRowForWeight:dd->scaleWeight];
	fatRow = [self pickerRowForBodyFat:dd->scaleFat];
	
	// TODO: default segment should be based on whether previous weigh-in included fat
	if (fatRow > 0) {
		weightMode = kModeWeightAndFat;
	} else if (weightRow > 0) {
		weightMode = kModeWeight;
	} else {
		weightMode = kModeNone;
	}

	if (weighIn) {
		// TODO: if previous entry included fat, show fat entry also
		weightMode = kModeWeight;
	}
	
	weightControl.selectedSegmentIndex = weightMode;

	if (weightRow == 0) {
		weightRow = [self pickerRowForWeight:[self chooseDefaultWeight]];
	}
	if (fatRow == 0) {
		fatRow = [self pickerRowForBodyFat:0.2]; // TODO choose default
	}
	
	[self toggleWeight];

	flagControl.selectedSegmentIndex = (dd->flags != 0);
	
	noteView.text = dd->note;

	[weightPickerView becomeFirstResponder];
	[[weightContainerView layer] removeAnimationForKey:kCATransition];
}


- (void)keyboardWillShow:(NSNotification *)notice {
	NSValue *kbBoundsValue = [[notice userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
	float kbHeight = CGRectGetHeight([kbBoundsValue CGRectValue]);
	float viewHeight = CGRectGetHeight(self.view.frame) - 44;
	
	[UIView beginAnimations:@"keyboardWillShow" context:nil];
	[UIView setAnimationDuration:0.3];
	weightControl.alpha = 0;
	weightContainerView.alpha = 0;
	annotationContainerView.frame = CGRectMake(0, 44, 320, viewHeight - kbHeight);
	[UIView commitAnimations];
}


- (void)keyboardWillHide:(NSNotification *)notice {
	[UIView beginAnimations:@"keyboardWillHide" context:nil];
	[UIView setAnimationDuration:0.3];
	weightControl.alpha = 1;
	weightContainerView.alpha = 1;
	annotationContainerView.frame = CGRectMake(0, 305, 320, 155);
	[UIView commitAnimations];
}


- (void)viewWillDisappear:(BOOL)animated {
	[noteView resignFirstResponder];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark UITextFieldDelegate (Optional)


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return [textField resignFirstResponder];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if ([text length] > 0 && [text characterAtIndex:0] == '\n') {
		[textView resignFirstResponder];
		return NO;
	}
	return YES;
}


#pragma mark UIPickerViewDelegate (Required)


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	if (weightMode == kModeWeight) {
		return 1;
	} else {
		return 2;
	}
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if (component == 0) {
		return [self pickerRowForWeight:500.0f];
	} else {
		return [self pickerRowForBodyFat:1.0f];
	}
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if (component == 0) {
		weightRow = row;
	} else {
		fatRow = row;
	}
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel *label;

	if ([view isKindOfClass:[UILabel class]]) {
		label = (UILabel *)view;
	} else {
		label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.textAlignment = UITextAlignmentCenter;
		label.textColor = [UIColor blackColor];
		label.font = [UIFont boldSystemFontOfSize:20];
	}
	
	if (component == 0) {
		float weight = [self weightForPickerRow:row];
		label.text = [WeightFormatters stringForWeight:weight];
		label.backgroundColor = [WeightFormatters backgroundColorForWeight:weight];
	} else {
		float bodyFat = [self bodyFatForPickerRow:row];
		label.text = [NSString stringWithFormat:@"%0.1f%%", (100.0f * bodyFat)];
		label.backgroundColor = [UIColor clearColor];
	}

	return label;
}


@end
