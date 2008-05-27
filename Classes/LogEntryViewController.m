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
	if (self = [super init]) {
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


- (void)loadView {
	const CGFloat kScreenWidth = 320;
	const CGFloat kWeightControlMargin = 11;
	const CGFloat kWeightControlHeight = 30;
	const CGFloat kWeightControlAreaHeight = (kWeightControlMargin + kWeightControlHeight + kWeightControlMargin);
	const CGFloat kWeightPickerHeight = 216;
	
	UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	CGFloat y = 0;
	
	weightControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Enter Weight", @"Leave Blank", nil]];
	weightControl.frame = CGRectInset(CGRectMake(0, y, kScreenWidth, kWeightControlAreaHeight), kWeightControlMargin, kWeightControlMargin);
	weightControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[weightControl addTarget:self action:@selector(toggleWeightAction) forControlEvents:UIControlEventValueChanged];
	[view addSubview:weightControl];
	[weightControl release];
	
	y = CGRectGetMaxY(weightControl.frame) + kWeightControlMargin;
	
	weightContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, y, kScreenWidth, kWeightPickerHeight)];
	[view addSubview:weightContainerView];
	[weightContainerView release];
	
	weightPickerView = [[UIPickerView alloc] initWithFrame:weightContainerView.bounds];
	weightPickerView.delegate = self;
	weightPickerView.showsSelectionIndicator = YES;
	
	noWeightView = [[UIView alloc] initWithFrame:weightContainerView.bounds];
	noWeightView.backgroundColor = [UIColor darkGrayColor];
	
	UILabel *noWeightLabel = [[UILabel alloc] initWithFrame:CGRectInset(noWeightView.bounds, 11, 0)];
	noWeightLabel.text = @"There will be no weight saved on this date, but you can still apply a check or a note using the fields below.";
	noWeightLabel.numberOfLines = 0;
	noWeightLabel.backgroundColor = [UIColor clearColor];
	noWeightLabel.textColor = [UIColor whiteColor];
	[noWeightView addSubview:noWeightLabel];
	[noWeightLabel release];
	
	const CGFloat margin = 16;
	const CGFloat height = (148 - (3 * margin)) / 2.0;
	
	y = CGRectGetMaxY(weightContainerView.frame) + margin;
	
	flagControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"", @"✓", nil]];
	flagControl.frame = CGRectMake(margin, y, 320 - 2*margin, height);
	[view addSubview:flagControl];
	[flagControl release];
	
	y = CGRectGetMaxY(flagControl.frame) + margin;
	
	noteField = [[UITextField alloc] initWithFrame:CGRectMake(margin, y, 320 - 2*margin, height)];
	noteField.placeholder = @"Note";
	noteField.borderStyle = UITextBorderStyleBezel;
	noteField.returnKeyType = UIReturnKeyDone;
	noteField.backgroundColor = [UIColor whiteColor];
	noteField.delegate = self;
	[view addSubview:noteField];
	[noteField release];
	
	self.view = view;
	[view release];

	self.navigationItem.leftBarButtonItem = 
		[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
													   target:self 
													   action:@selector(cancelAction)] autorelease];
	self.navigationItem.rightBarButtonItem = 
		[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
													   target:self 
													   action:@selector(saveAction)] autorelease];
}


- (void)dealloc {
	[weightPickerView release];
	[noWeightView release];
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


- (void)toggleWeightAction {
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


- (void)cancelAction {
	[self dismissModalViewControllerAnimated:YES];
}


- (void)saveAction {
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
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
