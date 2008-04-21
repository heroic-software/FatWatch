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
	
	UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeGlass];
	[deleteButton setTitle:@"Save With No Weight" forStates:UIControlStateNormal];
	[deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
	deleteButton.frame = CGRectMake(22, 22, 320-44, 44);
	[view addSubview:deleteButton];
	
	flagControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"", @"✓", nil]];
	flagControl.frame = CGRectMake(22, 88, 320-44, 44);
	[view addSubview:flagControl];
	[flagControl release];
	
	noteField = [[UITextField alloc] initWithFrame:CGRectMake(22, 200-28-22, 320-44, 28)];
	noteField.placeholder = @"Note";
	noteField.borderStyle = UITextFieldBorderStyleBezel;
	noteField.returnKeyType = UIReturnKeyDone;
	noteField.font = [UIFont systemFontOfSize:18];
	noteField.backgroundColor = [UIColor whiteColor];
	noteField.delegate = self;
	[view addSubview:noteField];
	[noteField release];
	
	weightPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, 320, 216)];
	weightPickerView.delegate = self;
	[view addSubview:weightPickerView];
	[weightPickerView release];
		
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeNavigation];
	[cancelButton setTitle:@"Cancel" forStates:UIControlStateNormal];
	[cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.customLeftView = cancelButton;
	
	UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeNavigationDone];
	[saveButton setTitle:@"Save" forStates:UIControlStateNormal];
	[saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.customRightView = saveButton;
	
	self.view = view;
	[view release];
}

- (void)dealloc
{
	[titleFormatter release];
	[super dealloc];
}

- (void)cancelAction
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)saveAction
{
	NSInteger row = [weightPickerView selectedRowInComponent:0];
	float weight = [self weightForPickerRow:row];
	[monthData setMeasuredWeight:weight 
							flag:flagControl.selectedSegmentIndex
							note:noteField.text
						   onDay:day];
	[[monthData database] commitChanges]; // TODO: should be in separate thread
	[self dismissModalViewControllerAnimated:YES];
}

- (void)deleteAction
{
	[monthData setMeasuredWeight:0 
							flag:flagControl.selectedSegmentIndex
							note:noteField.text
						   onDay:day];
	[[monthData database] commitChanges]; // TODO: should be in separate thread
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	NSDate *date = [monthData dateOnDay:day];
	self.title = [titleFormatter stringFromDate:date];

	float weight = [monthData measuredWeightOnDay:day];
	if (weight == 0) {
		weight = [monthData inputTrendOnDay:day];
	}
	int row = [self pickerRowForWeight:weight];
	[weightPickerView selectRow:row inComponent:0 animated:NO];
	[weightPickerView becomeFirstResponder];
	
	flagControl.selectedSegmentIndex = [monthData isFlaggedOnDay:day];
	
	noteField.text = [monthData noteOnDay:day];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[noteField resignFirstResponder];
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
