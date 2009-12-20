//
//  HeightEntryViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 11/15/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRMixedNumberFormatter.h"
#import "EWGoal.h"
#import "HeightEntryViewController.h"
#import "NSUserDefaults+EWAdditions.h"


static const float kMaximumHeight = 3.00;
static const float kDefaultHeight = 1.70;

@implementation HeightEntryViewController


@synthesize pickerView;


+ (UIViewController *)controller {
	UIViewController *c = [[HeightEntryViewController alloc] init];
	[c view];
	return [c autorelease];
}


- (NSFormatter *)heightFormatter {
	switch ([[NSUserDefaults standardUserDefaults] weightUnit]) {
		case EWWeightUnitKilograms:
		case EWWeightUnitGrams: {
			NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
			[nf setPositiveFormat:@"0.00 m"];
			return [nf autorelease];
		}
		default:
			return [BRMixedNumberFormatter metersAsFeetFormatter];
	}
}


- (id)init {
	if ([super initWithNibName:@"HeightEntryView" bundle:nil]) {
		formatter = [[self heightFormatter] retain];
		increment = [[NSUserDefaults standardUserDefaults] heightIncrement];
	}
	return self;
}


- (void)dealloc {
	[pickerView release];
	[formatter release];
    [super dealloc];
}


- (NSInteger)pickerRowForValue:(float)value {
	return roundf((value / increment) - 1);
}


- (float)valueForPickerRow:(NSInteger)pickerRow {
	return (pickerRow + 1) * increment;
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
	[[NSUserDefaults standardUserDefaults] setHeight:height];
	[[NSUserDefaults standardUserDefaults] setBMIEnabled:YES];
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)cancelAction:(id)sender {
	[[NSUserDefaults standardUserDefaults] setBMIEnabled:NO];
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark UIPickerViewDelegate & DataSource


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return (kMaximumHeight / increment) - 1;
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
