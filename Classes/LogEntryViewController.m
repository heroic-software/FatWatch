//
//  LogEntryViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/30/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "LogEntryViewController.h"
#import "Database.h"
#import "MonthData.h"

@implementation LogEntryViewController

@synthesize monthData;
@synthesize day;
@synthesize weighIn;

- (id)init
{
	if (self = [super init]) {
		titleFormatter = [[NSDateFormatter alloc] init];
		[titleFormatter setDateStyle:NSDateFormatterMediumStyle];
		[titleFormatter setTimeStyle:NSDateFormatterNoStyle];
		
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		[defs registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.5f] forKey:@"ScaleIncrement"]];
		scaleIncrement = [defs floatForKey:@"ScaleIncrement"]; 
	}
	return self;
}

- (NSInteger)pickerRowForWeight:(float)weight
{
	return weight / scaleIncrement;
}

- (float)weightForPickerRow:(NSInteger)row
{
	return row * scaleIncrement;
}

- (void)loadView
{
	UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	view.backgroundColor = [UIColor lightGrayColor];
	
	weightControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Weight", @"No Weight", nil]];
	weightControl.frame = CGRectMake(11, 11, 320-22, 30);
	weightControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[weightControl addTarget:self action:@selector(toggleWeightAction) forControlEvents:UIControlEventValueChanged];
	[view addSubview:weightControl];
	[weightControl release];
	
	weightPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 52, 320, 216)];
	weightPickerView.delegate = self;
	[view addSubview:weightPickerView];
	[weightPickerView release];
	
	noWeightView = [[UIView alloc] initWithFrame:CGRectMake(0, 52, 320, 88)];
	noWeightView.backgroundColor = [UIColor darkGrayColor];
 	[view addSubview:noWeightView];
	[noWeightView release];
	
	UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeGlass];
	[deleteButton setTitle:@"Clear Entry" forState:UIControlStateNormal];
	[deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
	deleteButton.frame = CGRectMake(22, 22, 320-44, 44);
	[noWeightView addSubview:deleteButton];

	flagAndNoteView = [[UIView alloc] initWithFrame:CGRectZero]; // see toggleWeight
	[view addSubview:flagAndNoteView];
	[flagAndNoteView release];
	
	flagControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"", @"✓", nil]];
	flagControl.frame = CGRectMake(11, 11, 320-22, 44);
	[flagAndNoteView addSubview:flagControl];
	[flagControl release];
	
	noteField = [[UITextField alloc] initWithFrame:CGRectMake(11, 66, 320-22, 28)];
	noteField.placeholder = @"Note";
	noteField.borderStyle = UITextFieldBorderStyleBezel;
	noteField.returnKeyType = UIReturnKeyDone;
	noteField.font = [UIFont systemFontOfSize:18];
	noteField.backgroundColor = [UIColor whiteColor];
	noteField.delegate = self;
	[flagAndNoteView addSubview:noteField];
	[noteField release];
	
	self.view = view;
	[view release];

	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeNavigation];
	[cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
	[cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.customLeftView = cancelButton;
	
	UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeNavigationDone];
	[saveButton setTitle:@"Save" forState:UIControlStateNormal];
	[saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.customRightView = saveButton;
}

- (void)dealloc
{
	[titleFormatter release];
	[super dealloc];
}

- (void)toggleWeight
{
	if (weightControl.selectedSegmentIndex == 0) {
		weightPickerView.alpha = 1.0;
		noWeightView.alpha = 0.0;
		flagAndNoteView.frame = CGRectMake(0, 52+216, 320, 88+28+22);
	} else {
		weightPickerView.alpha = 0.0;
		noWeightView.alpha = 1.0;
		flagAndNoteView.frame = CGRectMake(0, 52+88, 320, 88+28+22);
	}
}

- (void)toggleWeightAction
{
	[UIView beginAnimations:@"toggleWeightAction" context:nil];
	[self toggleWeight];
	[UIView commitAnimations];
}

- (void)cancelAction
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)saveAction
{
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
	[[Database sharedDatabase] commitChanges]; // TODO: should be in separate thread
	[self dismissModalViewControllerAnimated:YES];
}

- (void)deleteAction
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:@"Clear Entry"
													otherButtonTitles:nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		[monthData setMeasuredWeight:0 
								flag:0
								note:@""
							   onDay:day];
		[[Database sharedDatabase] commitChanges]; // TODO: should be in separate thread
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
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
	}
	int row = [self pickerRowForWeight:weight];
	[weightPickerView selectRow:row inComponent:0 animated:NO];
	[weightPickerView becomeFirstResponder];
	
	flagControl.selectedSegmentIndex = [monthData isFlaggedOnDay:day];
	
	noteField.text = [monthData noteOnDay:day];

	[self toggleWeight];
}

- (void)keyboardWillShow:(NSNotification *)notice
{
//	NSValue *value = [notice object];
//	CGRect keyboardRect = [value CGRectValue];
	[UIView beginAnimations:@"keyboardWillShow" context:nil];
	weightControl.alpha = 0;
	weightPickerView.alpha = 0;
	noWeightView.alpha = 0;
	CGRect viewFrame = flagAndNoteView.frame;
	viewFrame.origin.y = 0;
	flagAndNoteView.frame = viewFrame;
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notice
{
	[UIView beginAnimations:@"keyboardWillHide" context:nil];
	weightControl.alpha = 1.0;
	[self toggleWeight];
	[UIView commitAnimations];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[noteField resignFirstResponder];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITextFieldDelegate (Optional)

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	return [textField resignFirstResponder];
}

#pragma mark UIPickerViewDelegate (Required)

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [self pickerRowForWeight:500.0f];
}

- (CGSize)pickerView:(UIPickerView *)pickerView rowSizeForComponent:(NSInteger)component
{
	return CGSizeMake(320-88, 0);
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UILabel *label;
	
	if ([view isKindOfClass:[UILabel class]]) {
		label = (UILabel *)view;
	} else {
		label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320-88, 44)];
		label.textAlignment = UITextAlignmentCenter;
		label.textColor = [UIColor blackColor];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize:20];
	}

	label.text = [NSString stringWithFormat:@"%.1f", [self weightForPickerRow:row]];
	return label;
}

@end
