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
#import "EWWeightFormatter.h"
#import "NSUserDefaults+EWAdditions.h"
#import "BRTextView.h"
#import "RungEntryViewController.h"


const CGFloat kWeightPickerComponentWidth = 320 - 88;


enum {
	kModeWeightAndFat,
	kModeWeight,
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
@synthesize noteView;
@synthesize annotationContainerView;
@synthesize navigationBar;
@synthesize flag0Button;
@synthesize flag1Button;
@synthesize flag2Button;
@synthesize flag3Button;


- (id)init {
	if (self = [super initWithNibName:@"LogEntryView" bundle:nil]) {
		scaleIncrement = [[NSUserDefaults standardUserDefaults] weightIncrement];
		weightFormatter = [[EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleDisplay] retain];
		NSAssert(scaleIncrement > 0, @"scale increment must be greater than 0");
	}
	return self;
}


- (void)viewDidLoad {
	flagButtons[0] = flag0Button;
	flagButtons[1] = flag1Button;
	flagButtons[2] = flag2Button;
	flagButtons[3] = flag3Button;
}


- (void)dealloc {
	[weightControl release];
	[weightContainerView release];
	[weightPickerView release];
	[noWeightView release];
	[flag0Button release];
	[flag1Button release];
	[flag2Button release];
	[flag3Button release];
	[noteView release];
	[annotationContainerView release];
	[navigationBar release];
	[weightFormatter release];
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


- (int)rung {
	return [[flag3Button titleForState:UIControlStateNormal] intValue];
}


- (void)setValue:(EWFlagValue)value forFlagIndex:(int)f {
	BOOL selected;
	NSString *title;
	if ([[NSUserDefaults standardUserDefaults] isNumericFlag:f]) {
		if (value) {
			title = [NSString stringWithFormat:@"%d", value];
		} else {
			title = @"\xe2\x97\x86"; // LOZENGE
		}
		selected = NO;
	} else {
		title = @"";
		selected = value != 0;
	}
	[flagButtons[f] setTitle:title forState:UIControlStateNormal];
	flagButtons[f].selected = selected;
}


- (void)setRung:(int)rung {
	[self setValue:rung forFlagIndex:3];
}


- (IBAction)toggleFlagButton:(UIButton *)sender {
	int f;
	for (f = 0; f < 4; f++) {
		if (flagButtons[f] == sender) {
			if ([[NSUserDefaults standardUserDefaults] isNumericFlag:f]) {
				RungEntryViewController *controller = [[RungEntryViewController alloc] init];
				controller.target = self;
				controller.key = @"rung";
				[self presentModalViewController:controller animated:YES];
				[controller release];
			} else {
				sender.selected = !sender.selected;
			}
			return;
		}
	}
}


- (IBAction)cancelAction:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)saveAction:(id)sender {
	EWDBDay dbd;
	
	if (weightMode == kModeWeight) {
		dbd.scaleWeight = [self weightForPickerRow:weightRow];
		dbd.scaleFat = 0;
	} else if (weightMode == kModeWeightAndFat) {
		dbd.scaleWeight = [self weightForPickerRow:weightRow];
		dbd.scaleFat = [self bodyFatForPickerRow:fatRow];
	} else {
		dbd.scaleWeight = 0;
		dbd.scaleFat = 0;
	}
	
	int f;
	for (f = 0; f < 4; f++) {
		if ([[NSUserDefaults standardUserDefaults] isNumericFlag:f]) {
			dbd.flags[f] = [[flagButtons[f] titleForState:UIControlStateNormal] intValue];
		} else {
			dbd.flags[f] = flagButtons[f].selected ? 1 : 0;
		}
	}
	
	dbd.note = noteView.text;
	
	[monthData setDBDay:&dbd onDay:day];

	[[EWDatabase sharedDatabase] commitChanges];
	
	[self dismissModalViewControllerAnimated:YES];
}


- (float)chooseDefaultWeight {
	// no weight on this day, so get the trend on this day, searching earlier months if needed
	float weight = [monthData inputTrendOnDay:day];
	if (weight > 0) return weight;
	
	// there is no weight on or earlier than this day, so find first measurement
	weight = [monthData.database earliestWeight];
	if (weight > 0) return weight;

	// database is empty!
	return 200.0f;
}


- (float)chooseDefaultFat {
	// no fat today, search earlier
	float fat = [monthData latestFatBeforeDay:day];
	if (fat > 0) return fat;
	
	// nothing on or earlier, find first
	fat = [monthData.database earliestFat];
	if (fat > 0) return fat;
	
	return 0.25f;
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
	
	[weightPickerView becomeFirstResponder];
	[[weightContainerView layer] removeAnimationForKey:kCATransition];
}


- (void)configureForDay:(EWDay)aDay dbMonth:(EWDBMonth *)aDBMonth {
	day = aDay;
	[monthData release];
	monthData = [aDBMonth retain];
	
	[self view]; // force load of view
	
	NSDate *date = [monthData dateOnDay:day];
	NSDateFormatter *titleFormatter = [[NSDateFormatter alloc] init];
	[titleFormatter setDateStyle:NSDateFormatterMediumStyle];
	[titleFormatter setTimeStyle:NSDateFormatterNoStyle];
	navigationBar.topItem.title = [titleFormatter stringFromDate:date];
	[titleFormatter release];

	const EWDBDay *dd = [monthData getDBDayOnDay:day];

	weightRow = [self pickerRowForWeight:dd->scaleWeight];
	fatRow = [self pickerRowForBodyFat:dd->scaleFat];
	
	BOOL weighIn = (![monthData hasDataOnDay:day] &&
					(EWMonthDayToday() == EWMonthDayMake(monthData.month, day)));

	if (weighIn) {
		if ([monthData didRecordFatBeforeDay:day]) {
			weightMode = kModeWeightAndFat;
		} else {
			weightMode = kModeWeight;
		}
	} else {
		if (fatRow > 0) {
			weightMode = kModeWeightAndFat;
		} else if (weightRow > 0) {
			weightMode = kModeWeight;
		} else {
			weightMode = kModeNone;
		}
	}
	
	weightControl.selectedSegmentIndex = weightMode;

	if (weightRow == 0) {
		weightRow = [self pickerRowForWeight:[self chooseDefaultWeight]];
	}
	
	if (fatRow == 0) {
		fatRow = [self pickerRowForBodyFat:[self chooseDefaultFat]];
	}
	
	[self toggleWeight];

	int f;
	for (f = 0; f < 4; f++) {
		[self setValue:dd->flags[f] forFlagIndex:f];
	}
	
	noteView.text = dd->note;
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
		label.text = [weightFormatter stringForFloat:weight];
		label.backgroundColor = [EWWeightFormatter backgroundColorForWeight:weight];
	} else {
		float bodyFat = [self bodyFatForPickerRow:row];
		label.text = [NSString stringWithFormat:@"%0.1f%%", (100.0f * bodyFat)];
		label.backgroundColor = [UIColor clearColor];
	}

	return label;
}


@end
