//
//  BRTableNumberPickerRow.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTableNumberPickerRow.h"
#import "BRTableSection.h"
#import "BRTableViewController.h"


@interface BRNumberPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>{
	BRTableNumberPickerRow *row;
}
- (id)initWithRow:(BRTableNumberPickerRow *)theRow;
@end


@implementation BRTableNumberPickerRow


@synthesize minimumValue, maximumValue, increment;


- (id)init {
	if ([super init]) {
		self.minimumValue = 0;
		self.maximumValue = 100;
		self.increment = 1;
	}
	return self;
}


- (void)didSelect {
	UIViewController *controller = [[BRNumberPickerViewController alloc] initWithRow:self];
	[self.section.controller presentViewController:controller forRow:self];
	[controller release];
}


@end


@implementation BRNumberPickerViewController


- (id)initWithRow:(BRTableNumberPickerRow *)theRow {
	if ([super initWithNibName:nil bundle:nil]) {
		row = [theRow retain];
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
	
	UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
	picker.delegate = self;
	picker.tag = 411;
	[view addSubview:picker];
	[picker release];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
	[cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
	[cancelButton setFrame:CGRectMake(10, 480-10-50-10-50, 300, 50)];
	cancelButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[view addSubview:cancelButton];
	
	UIButton *okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[okButton setTitle:@"OK" forState:UIControlStateNormal];
	[okButton addTarget:self action:@selector(okAction:) forControlEvents:UIControlEventTouchUpInside];
	[okButton setFrame:CGRectMake(10, 480-10-50, 300, 50)];
	okButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[view addSubview:okButton];
	
	self.view = view;
	[view release];
}


- (UIPickerView *)pickerView {
	return (UIPickerView *)[self.view viewWithTag:411];
}


- (NSInteger)pickerRowForValue:(float)value {
	return (value - row.minimumValue) / row.increment;
}


- (float)valueForPickerRow:(NSInteger)pickerRow {
	return (pickerRow * row.increment) + row.minimumValue;
}


- (void)viewWillAppear:(BOOL)animated {
	float value = [[row.object valueForKey:row.key] floatValue];
	[[self pickerView] selectRow:[self pickerRowForValue:value] inComponent:0 animated:NO];
}


#pragma mark Actions


- (void)okAction:(id)sender {
	NSInteger pickerRow = [[self pickerView] selectedRowInComponent:0];
	NSNumber *number = [NSNumber numberWithFloat:[self valueForPickerRow:pickerRow]];
	[row.object setValue:number forKey:row.key];
	[row.section.controller dismissViewController:self forRow:row];
}


- (void)cancelAction:(id)sender {
	[row.section.controller dismissViewController:self forRow:row];
}


#pragma mark UIPickerViewDelegate & DataSource


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return (row.maximumValue - row.minimumValue) / row.increment;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)pickerRow forComponent:(NSInteger)component {
	NSNumber *number = [NSNumber numberWithFloat:[self valueForPickerRow:pickerRow]];
	return [row.formatter stringForObjectValue:number];
}			

@end
