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
	if ([super initWithNibName:@"GoToDateView" bundle:nil]) {
		initialDate = [date retain];
	}
	return self;
}


- (void)dealloc {
	[initialDate release];
	[super dealloc];
}


- (void)viewDidLoad {
	datePicker.minimumDate = [NSDate distantPast];
	datePicker.maximumDate = [NSDate date];
}


- (void)viewWillAppear:(BOOL)animated {
	[datePicker setDate:initialDate animated:animated];
}


- (IBAction)goToDate:(id)sender {
	[target performSelector:action withObject:datePicker.date];
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)cancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)pickToday:(id)sender {
	[datePicker setDate:[NSDate date] animated:YES];
}


@end
