//
//  BRTableDatePickerRow.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTableDatePickerRow.h"
#import "BRTableSection.h"


@interface BRDatePickerViewController : UIViewController {
	BRTableDatePickerRow *row;
}
- (id)initWithRow:(BRTableDatePickerRow *)aRow;
@end


@implementation BRTableDatePickerRow


- (id)init {
	if ([super init]) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateStyle:NSDateFormatterLongStyle];
		[df setTimeStyle:NSDateFormatterNoStyle];
		self.formatter = df;
		[df release];
	}
	return self;
}


- (void)didSelect {
	BRDatePickerViewController *controller = [[BRDatePickerViewController alloc] initWithRow:self];
	[self.section.controller presentModalViewController:controller animated:YES];
	[controller release];
}


@end



@implementation BRDatePickerViewController


- (id)initWithRow:(BRTableDatePickerRow *)aRow {
	if ([super initWithNibName:nil bundle:nil]) {
		row = [aRow retain];
	}
	return self;
}


- (void)dealloc {
	[row release];
	[super dealloc];
}


- (void)loadView {
	UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	view.backgroundColor = [UIColor grayColor];
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
	datePicker.tag = 411;
	datePicker.datePickerMode = UIDatePickerModeDate;
	[view addSubview:datePicker];
	[datePicker release];
	
	UIButton *okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[okButton setTitle:@"OK" forState:UIControlStateNormal];
	[okButton addTarget:self action:@selector(okAction:) forControlEvents:UIControlEventTouchUpInside];
	[okButton setFrame:CGRectMake(10, 300, 300, 44)];
	[view addSubview:okButton];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
	[cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
	[cancelButton setFrame:CGRectMake(10, 350, 300, 44)];
	[view addSubview:cancelButton];
	
	self.view = view;
	[view release];
}


- (void)viewWillAppear:(BOOL)animated {
	UIDatePicker *datePicker = (UIDatePicker *)[self.view viewWithTag:411];
	datePicker.date = [row.object valueForKey:row.key];
}


- (void)okAction:(id)sender {
	UIDatePicker *datePicker = (UIDatePicker *)[self.view viewWithTag:411];
	[row.object setValue:datePicker.date forKey:row.key];
	[self dismissModalViewControllerAnimated:YES];
}


- (void)cancelAction:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}


@end
