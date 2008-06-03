//
//  GoToDateViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 6/2/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "GoToDateViewController.h"


@implementation GoToDateViewController


@synthesize target;
@synthesize action;


- (id)initWithDate:(NSDate *)date {
	if (self = [super initWithNibName:nil bundle:nil]) {
		initialDate = [date retain];
	}
	return self;
}


- (void)loadView {
	UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	
	datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
	datePicker.datePickerMode = UIDatePickerModeDate;
	datePicker.maximumDate = [NSDate date];
	datePicker.date = initialDate;
	[view addSubview:datePicker];
	[datePicker release];
	
	UIButton *goButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	goButton.frame = CGRectMake(0, 230, 320, 44);
	[goButton setTitle:@"Go To Date" forState:UIControlStateNormal];
	[goButton addTarget:self action:@selector(goAction) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:goButton];

	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	cancelButton.frame = CGRectMake(0, 300, 320, 44);
	[cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
	[cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:cancelButton];
	
	self.view = view;
	[view release];
}


- (void)goAction {
	[target performSelector:action withObject:datePicker.date];
	[self dismissModalViewControllerAnimated:YES];
}


- (void)cancelAction {
	[self dismissModalViewControllerAnimated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
	[initialDate release];
	[super dealloc];
}

@end
