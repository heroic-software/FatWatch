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


@synthesize minimumValue, maximumValue, increment, defaultValue;


- (id)init {
	if ([super init]) {
		self.minimumValue = 0;
		self.maximumValue = 100;
		self.increment = 1;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
	picker.dataSource = self;
	picker.showsSelectionIndicator = YES;
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
	[okButton setTitle:[NSString stringWithFormat:@"Set %@", row.title] forState:UIControlStateNormal];
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
	return roundf((value - row.minimumValue) / row.increment);
}


- (float)valueForPickerRow:(NSInteger)pickerRow {
	return (pickerRow * row.increment) + row.minimumValue;
}


- (void)viewWillAppear:(BOOL)animated {
	float f;
	id value = row.value;
	if (value) {
		f = [value floatValue];
	} else {
		f = [row.defaultValue floatValue];
	}
	[[self pickerView] selectRow:[self pickerRowForValue:f] inComponent:0 animated:NO];
}


#pragma mark Actions


- (void)okAction:(id)sender {
	NSInteger pickerRow = [[self pickerView] selectedRowInComponent:0];
	row.value = [NSNumber numberWithFloat:[self valueForPickerRow:pickerRow]];
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


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)pickerRow forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel *label;
	
	if ([view isKindOfClass:[UILabel class]]) {
		label = (UILabel *)view;
	} else {
		label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 44)] autorelease];
		label.textAlignment = UITextAlignmentCenter;
		label.textColor = [UIColor blackColor];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize:20];
	}
	
	NSNumber *number = [NSNumber numberWithFloat:[self valueForPickerRow:pickerRow]];
	label.text = [row.formatter stringForObjectValue:number];
	
	return label;
}


@end
