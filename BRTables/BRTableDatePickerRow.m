//
//  BRTableDatePickerRow.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTableDatePickerRow.h"
#import "BRTableSection.h"
#import "BRTableViewController.h"


@interface BRDatePickerViewController : UIViewController {
	BRTableDatePickerRow *row;
}
- (id)initWithRow:(BRTableDatePickerRow *)aRow;
@end


@implementation BRTableDatePickerRow


@synthesize minimumDate, maximumDate;


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


- (void)dealloc {
	[minimumDate release];
	[maximumDate release];
	[super dealloc];
}


- (void)didSelect {
	BRDatePickerViewController *controller = [[BRDatePickerViewController alloc] initWithRow:self];
	[self.section.controller presentViewController:controller forRow:self];
	[controller release];
}


@end



@implementation BRDatePickerViewController


- (id)initWithRow:(BRTableDatePickerRow *)aRow {
	if ([super initWithNibName:nil bundle:nil]) {
		row = [aRow retain];
		self.title = row.title;
	}
	return self;
}


- (void)dealloc {
	[row release];
	[super dealloc];
}


- (void)loadView {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
	datePicker.tag = 411;
	datePicker.datePickerMode = UIDatePickerModeDate;
	[view addSubview:datePicker];
	[datePicker release];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
	[cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
	[cancelButton setFrame:CGRectMake(10, 480-10-50-10-50, 300, 50)];
	cancelButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[view addSubview:cancelButton];
	
	UIButton *okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[okButton setTitle:[NSString stringWithFormat:@"Set %@", row.title] forState:UIControlStateNormal];
	[okButton addTarget:self action:@selector(okAction:) forControlEvents:UIControlEventTouchUpInside];
	[okButton setFrame:CGRectMake(10, 480-10-50, 300, 50)];
	okButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[view addSubview:okButton];
	
	self.view = view;
	[view release];
}


- (void)viewWillAppear:(BOOL)animated {
	UIDatePicker *datePicker = (UIDatePicker *)[self.view viewWithTag:411];
	datePicker.date = [row.object valueForKey:row.key];
	datePicker.minimumDate = row.minimumDate;
	datePicker.maximumDate = row.maximumDate;
}


- (void)okAction:(id)sender {
	UIDatePicker *datePicker = (UIDatePicker *)[self.view viewWithTag:411];
	[row.object setValue:datePicker.date forKey:row.key];
	[row.section.controller dismissViewController:self forRow:row];
}


- (void)cancelAction:(id)sender {
	[row.section.controller dismissViewController:self forRow:row];
}


@end
