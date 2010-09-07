    //
//  BRPickerViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BRPickerViewController.h"
#import "BRTableValueRow.h"
#import "BRTableSection.h"
#import "BRTableViewController.h"
#import "BRTableNumberPickerRow.h"
#import "BRTableDatePickerRow.h"


static const int kBRPickerViewTag = 411;


@interface BRPickerViewController (Abstract)
- (UIView *)loadPickerView;
- (id)pickerValue;
@end


@implementation BRPickerViewController


- (id)initWithRow:(BRTableValueRow *)aRow {
    if ((self = [super initWithNibName:nil bundle:nil])) {
		tableRow = [aRow retain];
		self.title = tableRow.title;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}


- (id)tableRow {
	return tableRow;
}


- (id)pickerView {
	return [self.view viewWithTag:kBRPickerViewTag];
}


- (void)cancelAction:(id)sender {
	[tableRow.section.controller dismissViewController:self forRow:tableRow];
}


- (void)doneAction:(id)sender {
	tableRow.value = [self pickerValue];
	[tableRow.section.controller dismissViewController:self forRow:tableRow];
}


#pragma mark UIViewController


- (void)loadView {
	static const CGFloat viewHeight = 400;
	
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, viewHeight)];
	view.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
							 UIViewAutoresizingFlexibleHeight);
	view.backgroundColor = [UIColor colorWithRed:0.158739604791f
										   green:0.165285725185f
											blue:0.220828564889f
										   alpha:1];
	
	UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
	self.navigationItem.leftBarButtonItem = cancelItem;
	[cancelItem release];
	
	UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(doneAction:)];
	self.navigationItem.rightBarButtonItem = doneItem;
	[doneItem release];
	
	CGFloat pickerY;
	
	if (self.navigationController) {
		pickerY = 0;
	} else {
		UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
		[bar pushNavigationItem:self.navigationItem animated:NO];
		[view addSubview:bar];
		pickerY = CGRectGetMaxY(bar.frame);
		[bar release];
	}
	
	UIView *pickerView = [self loadPickerView];
	pickerView.tag = kBRPickerViewTag;
	pickerView.frame = CGRectMake(0, pickerY, 320, 216);
	[view addSubview:pickerView];

	if (tableRow.valueDescription) {
		CGFloat helpY = pickerY + 216;
		CGFloat helpHeight = viewHeight - helpY;
		UILabel *helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, helpY, 280, helpHeight)];
		helpLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
									  UIViewAutoresizingFlexibleHeight);
		helpLabel.textAlignment = UITextAlignmentCenter;
		helpLabel.textColor = [UIColor whiteColor];
		helpLabel.backgroundColor = view.backgroundColor;
		helpLabel.numberOfLines = 0;
		helpLabel.text = tableRow.valueDescription;
		[view addSubview:helpLabel];
		[helpLabel release];
	}
	
	self.view = view;
	[view release];
}


- (void)dealloc {
	[tableRow release];
    [super dealloc];
}


@end



@implementation BRNumberPickerViewController

- (NSNumber *)valueForPickerRow:(NSInteger)pickerRow {
	BRTableNumberPickerRow *row = [self tableRow];
	float value = (pickerRow * row.increment) + row.minimumValue;
	return [NSNumber numberWithFloat:value];
}

#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	BRTableNumberPickerRow *row = [self tableRow];
	float f;
	id value = row.value;
	if (value) {
		f = [value floatValue];
	} else {
		f = [row.defaultValue floatValue];
	}
	NSInteger i = roundf((f - row.minimumValue) / row.increment);
	UIPickerView *pickerView = [self pickerView];
	if (i >= [pickerView numberOfRowsInComponent:0]) {
		i = [pickerView numberOfRowsInComponent:0] - 1;
	}
	[pickerView selectRow:i inComponent:0 animated:NO];
}

#pragma mark BRPickerViewController

- (UIView *)loadPickerView {
	UIPickerView *picker = [[UIPickerView alloc] init];
	picker.delegate = self;
	picker.dataSource = self;
	picker.showsSelectionIndicator = YES;
	return [picker autorelease];
}

- (id)pickerValue {
	UIPickerView *pickerView = [self pickerView];
	NSInteger pickerRow = [pickerView selectedRowInComponent:0];
	return [self valueForPickerRow:pickerRow];
}

#pragma mark UIPickerViewDelegate & UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	BRTableNumberPickerRow *row = [self tableRow];
	return 1 + ceilf((row.maximumValue - row.minimumValue) / row.increment);
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
	
	BRTableDatePickerRow *row = [self tableRow];
	NSNumber *number = [self valueForPickerRow:pickerRow];
	label.text = [row.formatter stringForObjectValue:number];
	
	if (row.textColorFormatter) {
		label.textColor = [row.textColorFormatter colorForObjectValue:number];
	}
	
	if (row.backgroundColorFormatter) {
		label.backgroundColor = [row.backgroundColorFormatter colorForObjectValue:number];
	}
	
	return label;
}

@end



@implementation BRDatePickerViewController

#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	BRTableDatePickerRow *row = [self tableRow];
	UIDatePicker *datePicker = [self pickerView];
	// Clamp date value to defined range.
	NSDate *date = row.value;
	if (row.minimumDate) date = [date laterDate:row.minimumDate];
	if (row.maximumDate) date = [date earlierDate:row.maximumDate];
	datePicker.date = date;
	datePicker.minimumDate = row.minimumDate;
	datePicker.maximumDate = row.maximumDate;
}

#pragma mark BRPickerViewController

- (UIView *)loadPickerView {
	BRTableDatePickerRow *row = [self tableRow];
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	datePicker.datePickerMode = row.datePickerMode;
	return [datePicker autorelease];
}

- (id)pickerValue {
	UIDatePicker *datePicker = [self pickerView];
	return datePicker.date;
}

@end
