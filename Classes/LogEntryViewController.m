//
//  LogEntryViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/30/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "LogEntryViewController.h"

#import "MonthData.h"

const CGFloat kOFFSET_FOR_KEYBOARD = 216;

@implementation LogEntryViewController

@synthesize monthData;
@synthesize day;
@synthesize weightPickerView;
@synthesize flagSwitch;
@synthesize noteField;

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
	// Create a custom view hierarchy.
	UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	view.backgroundColor = [UIColor whiteColor];
	
	self.weightPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
	weightPickerView.delegate = self;
	[view addSubview:weightPickerView];
	[weightPickerView release];
	
	UILabel *flagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 216 + 16, 156, 27)];
	flagLabel.text = @"Checked";
	flagLabel.textAlignment = UITextAlignmentRight;
	[view addSubview:flagLabel];
	[flagLabel release];
	
	self.flagSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(160, 216 + 16, 94, 27)];
	[view addSubview:flagSwitch];
	
	self.noteField = [[UITextField alloc] initWithFrame:CGRectMake(0, 300, 320, 40)];
	noteField.placeholder = @"Note";
	noteField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	noteField.returnKeyType = UIReturnKeyDone;
	noteField.borderStyle = UITextFieldBorderStyleBezel;
	noteField.font = [UIFont systemFontOfSize:24];
	noteField.adjustsFontSizeToFit = YES;
	noteField.minimumFontSize = 12;
	noteField.delegate = self;
	[view addSubview:noteField];
	[noteField release];
	
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
							flag:flagSwitch.on
							note:noteField.text
						   onDay:day];
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
	
	flagSwitch.on = [monthData isFlaggedOnDay:day];
	
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
