//
//  HeightEntryViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 11/15/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "HeightEntryViewController.h"
#import "WeightFormatters.h"
#import "EWGoal.h"

const float kMinimumHeight = 0.01;
const float kMaximumHeight = 3.00;
const float kDefaultHeight = 1.70;

@implementation HeightEntryViewController


+ (UIViewController *)controller {
	UIViewController *c = [[HeightEntryViewController alloc] init];
	[c view];
	return [c autorelease];
}


- (id)init {
	if ([super initWithNibName:@"HeightEntryView" bundle:nil]) {
		formatter = [[WeightFormatters heightFormatter] retain];
		increment = [WeightFormatters heightIncrement];
	}
	return self;
}


- (void)dealloc {
	[formatter release];
    [super dealloc];
}


- (NSInteger)pickerRowForValue:(float)value {
	return roundf((value - kMinimumHeight) / increment);
}


- (float)valueForPickerRow:(NSInteger)pickerRow {
	return (pickerRow * increment) + kMinimumHeight;
}


- (void)viewWillAppear:(BOOL)animated {
	float height = [[NSUserDefaults standardUserDefaults] floatForKey:@"BMIHeight"];
	if (height == 0) height = kDefaultHeight;
	NSInteger row = [self pickerRowForValue:height];
	[pickerView selectRow:row inComponent:0 animated:NO];
}


- (IBAction)saveAction:(id)sender {
	NSInteger row = [pickerView selectedRowInComponent:0];
	float height = [self valueForPickerRow:row];
	[EWGoal setHeight:height];
	[EWGoal setBMIEnabled:YES];
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)cancelAction:(id)sender {
	[EWGoal setBMIEnabled:NO];
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark UIPickerViewDelegate & DataSource


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return (kMaximumHeight - kMinimumHeight) / increment;
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
	label.text = [formatter stringForObjectValue:number];
		
	return label;
}


@end
