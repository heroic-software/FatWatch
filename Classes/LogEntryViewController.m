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

#define kScreenWidth 320
#define kWeightControlMargin 11
#define kWeightControlHeight 30
#define kWeightControlAreaHeight (kWeightControlMargin + kWeightControlHeight + kWeightControlMargin)
#define kWeightPickerHeight 216
#define kNoWeightViewHeight 88
#define kWeightPickerComponentWidth 320-88

@implementation LogEntryViewController


@synthesize monthData;
@synthesize day;
@synthesize weighIn;


- (id)init {
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


- (NSInteger)pickerRowForWeight:(float)weight {
	return weight / scaleIncrement;
}


- (float)weightForPickerRow:(NSInteger)row {
	return row * scaleIncrement;
}


- (void)loadView {
	UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	weightContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
	[view addSubview:weightContainerView];

	weightControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Enter Weight", @"Leave Blank", nil]];
	weightControl.frame = CGRectInset(CGRectMake(0, 0, kScreenWidth, kWeightControlAreaHeight), kWeightControlMargin, kWeightControlMargin);
	weightControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[weightControl addTarget:self action:@selector(toggleWeightAction) forControlEvents:UIControlEventValueChanged];
	[weightContainerView addSubview:weightControl];
	
	weightPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, kWeightControlAreaHeight, kScreenWidth, kWeightPickerHeight)];
	weightPickerView.delegate = self;
	weightPickerView.showsSelectionIndicator = YES;
	
	noWeightView = [[UIView alloc] initWithFrame:CGRectMake(0, kWeightControlAreaHeight, kScreenWidth, kNoWeightViewHeight)];
	noWeightView.backgroundColor = [UIColor darkGrayColor];

	UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[deleteButton setTitle:@"Clear Everything" forState:UIControlStateNormal];
	[deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
	deleteButton.frame = CGRectInset(noWeightView.bounds, 22, 22);
	[noWeightView addSubview:deleteButton];

	flagAndNoteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 148)]; // see toggleWeight
	[view addSubview:flagAndNoteView];
	[flagAndNoteView release];
	
	CGFloat margin = 16;
	CGFloat height = (148 - (3 * margin)) / 2.0;
	
	flagControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"", @"✓", nil]];
	flagControl.frame = CGRectMake(margin, margin, 320 - 2*margin, height);
	[flagAndNoteView addSubview:flagControl];
	[flagControl release];
	
	noteField = [[UITextField alloc] initWithFrame:CGRectMake(margin, margin + height + margin, 320 - 2*margin, height)];
	noteField.placeholder = @"Note";
	noteField.borderStyle = UITextBorderStyleBezel;
	noteField.returnKeyType = UIReturnKeyDone;
	noteField.backgroundColor = [UIColor whiteColor];
	noteField.delegate = self;
	noteField.adjustsFontSizeToFitWidth = YES;
	noteField.minimumFontSize = 9;
	[flagAndNoteView addSubview:noteField];
	[noteField release];
	
	self.view = view;
	[view release];

	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																						   target:self 
																						   action:@selector(cancelAction)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																							target:self 
																							action:@selector(saveAction)] autorelease];
}


- (void)dealloc {
	[weightPickerView release];
	[noWeightView release];
	[titleFormatter release];
	[super dealloc];
}


- (void)updateFlagAndNoteViewFrame {
	CGRect frame = flagAndNoteView.frame;
	frame.origin.y = CGRectGetMaxY(weightContainerView.frame);
	flagAndNoteView.frame = frame;
}


- (void)toggleWeight {
	if (weightControl.selectedSegmentIndex == 0) {
		if ([weightPickerView superview] == nil) {
			[noWeightView removeFromSuperview];
			[weightContainerView addSubview:weightPickerView];
			CGRect frame = weightContainerView.frame;
			frame.size.height = CGRectGetMaxY(weightPickerView.frame);
			weightContainerView.frame = frame;
			[self updateFlagAndNoteViewFrame];
		}
	} else {
		if ([noWeightView superview] == nil) {
			[weightPickerView removeFromSuperview];
			[weightContainerView addSubview:noWeightView];
			CGRect frame = weightContainerView.frame;
			frame.size.height = CGRectGetMaxY(noWeightView.frame);
			weightContainerView.frame = frame;
			[self updateFlagAndNoteViewFrame];
		}
	}
}


- (void)toggleWeightAction {
	[UIView beginAnimations:nil context:nil];
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[self toggleWeight];
	[[weightContainerView layer] addAnimation:animation forKey:nil];
	[UIView commitAnimations];
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


- (void)deleteAction {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:@"Clear Day"
													otherButtonTitles:nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[monthData setMeasuredWeight:0 
								flag:0
								note:@""
							   onDay:day];
		[[Database sharedDatabase] commitChanges];
		[self dismissModalViewControllerAnimated:YES];
	}
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
	[UIView beginAnimations:@"keyboardWillShow" context:nil];

	CGRect wcFrame = weightContainerView.frame;
	wcFrame.origin.y = -wcFrame.size.height;
	weightContainerView.frame = wcFrame;
	
	[self updateFlagAndNoteViewFrame];
	
	[UIView commitAnimations];
}


- (void)keyboardWillHide:(NSNotification *)notice {
	[UIView beginAnimations:@"keyboardWillHide" context:nil];

	CGRect wcFrame = weightContainerView.frame;
	wcFrame.origin.y = 0;
	weightContainerView.frame = wcFrame;

	[self updateFlagAndNoteViewFrame];

	[UIView commitAnimations];
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

	label.text = [NSString stringWithFormat:@"%.1f", [self weightForPickerRow:row]];
	return label;
}


@end
