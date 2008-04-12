//
//  LogEntryViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/30/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "LogEntryViewController.h"

#import "MonthData.h"

@implementation LogEntryViewController

@synthesize monthData;
@synthesize day;
@synthesize weightPickerView;
@synthesize noteField;

- (id)init
{
	if (self = [super init]) {
		// Initialize your view controller.
		self.title = @"LogEntryViewController";
	}
	return self;
}

#define INCREMENT 0.5f

- (NSInteger)pickerRowForWeight:(float)weight
{
	return weight / INCREMENT;
}

- (float)weightForPickerRow:(NSInteger)row
{
	return row * INCREMENT;
}

- (void)loadView
{
	// Create a custom view hierarchy.
	UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	view.backgroundColor = [UIColor yellowColor];
	
	self.weightPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
	weightPickerView.delegate = self;
	[view addSubview:weightPickerView];
	[weightPickerView release];
	
	self.noteField = [[UITextField alloc] initWithFrame:CGRectMake(20, 240, 280, 30)];
	noteField.placeholder = @"Note";
	noteField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	noteField.returnKeyType = UIReturnKeyDone;
	noteField.borderStyle = UITextFieldBorderStyleBezel;
	noteField.delegate = self;
	[view addSubview:noteField];
	[noteField release];
	
	// Flag Switch
	// Clear Button
	// Button for Numeric Entry?
	
	self.view = view;
	[view release];
}

- (void)dealloc
{
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
	self.title = [monthData titleOnDay:day];

	float weight = [monthData measuredWeightOnDay:day];
	int row = [self pickerRowForWeight:weight];
	[weightPickerView selectRow:row inComponent:0 animated:NO];
	[weightPickerView becomeFirstResponder];
	
	noteField.text = [monthData noteOnDay:day];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[noteField resignFirstResponder];

	NSInteger row = [weightPickerView selectedRowInComponent:0];
	float weight = [self weightForPickerRow:row];
	[monthData setMeasuredWeight:weight 
							flag:NO
							note:noteField.text
						   onDay:day];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview.
	// Release anything that's not essential, such as cached data.
}

const CGFloat kOFFSET_FOR_KEYBOARD = 100;

- (void)makeRoomForKeyboard:(BOOL)shiftUp
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	CGRect rect = self.view.frame;
	if (shiftUp) {
		rect.origin.y -= kOFFSET_FOR_KEYBOARD;
		rect.size.height += kOFFSET_FOR_KEYBOARD;
	} else {
		rect.origin.y += kOFFSET_FOR_KEYBOARD;
		rect.size.height -= kOFFSET_FOR_KEYBOARD;
	}
	self.view.frame = rect;
	[UIView commitAnimations];
}

#pragma mark UITextFieldDelegate (Optional)

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	[self makeRoomForKeyboard:YES];
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[self makeRoomForKeyboard:NO];
	return YES;
}

#pragma mark UIPickerViewDelegate (Required)

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [self pickerRowForWeight:400.0f];
}

- (CGSize)pickerView:(UIPickerView *)pickerView rowSizeForComponent:(NSInteger)component
{
	return CGSizeMake(200, 30);
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [NSString stringWithFormat:@"%.1f", [self weightForPickerRow:row]];
}

@end
