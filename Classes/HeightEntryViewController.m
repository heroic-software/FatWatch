/*
 * HeightEntryViewController.m
 * Created by Benjamin Ragheb on 11/15/08.
 * Copyright 2015 Heroic Software Inc
 *
 * This file is part of FatWatch.
 *
 * FatWatch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FatWatch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "BRMixedNumberFormatter.h"
#import "HeightEntryViewController.h"
#import "NSUserDefaults+EWAdditions.h"


static const float kMaximumHeight = 3.00f;
static const float kDefaultHeight = 1.70f;

@implementation HeightEntryViewController
{
	UIPickerView *pickerView;
	NSFormatter *formatter;
	float increment;
}

@synthesize pickerView;


+ (UIViewController *)controller {
	UIViewController *c = [[HeightEntryViewController alloc] init];
	[c view];
	return c;
}


- (NSFormatter *)heightFormatter {
	switch ([[NSUserDefaults standardUserDefaults] weightUnit]) {
		case EWWeightUnitKilograms:
		case EWWeightUnitGrams: {
			NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
			[nf setPositiveFormat:@"0.00 m"];
			return nf;
		}
		default:
			return [BRMixedNumberFormatter metersAsFeetFormatter];
	}
}


- (id)init {
	if ((self = [super initWithNibName:@"HeightEntryView" bundle:nil])) {
		formatter = [self heightFormatter];
		increment = [[NSUserDefaults standardUserDefaults] heightIncrement];
	}
	return self;
}




- (NSInteger)pickerRowForValue:(float)value {
	return roundf((value / increment) - 1);
}


- (float)valueForPickerRow:(NSInteger)pickerRow {
	return (pickerRow + 1) * increment;
}


- (void)viewWillAppear:(BOOL)animated {
	float height = [[NSUserDefaults standardUserDefaults] height];
	if (height == 0) height = kDefaultHeight;
	NSInteger row = [self pickerRowForValue:height];
	[pickerView selectRow:row inComponent:0 animated:NO];
}


- (IBAction)saveAction:(id)sender {
	NSInteger row = [pickerView selectedRowInComponent:0];
	float height = [self valueForPickerRow:row];
	[[NSUserDefaults standardUserDefaults] setHeight:height];
	[[NSUserDefaults standardUserDefaults] setBMIEnabled:YES];
	[self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)cancelAction:(id)sender {
	[[NSUserDefaults standardUserDefaults] setBMIEnabled:NO];
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UIPickerViewDelegate & DataSource


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return (kMaximumHeight / increment) - 1;
}


- (UIView *)pickerView:(UIPickerView *)aPickerView viewForRow:(NSInteger)pickerRow forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel *label;
	
	if ([view isKindOfClass:[UILabel class]]) {
		label = (UILabel *)view;
	} else {
        CGRect frame = CGRectZero;
        frame.size = [pickerView rowSizeForComponent:component];
		label = [[UILabel alloc] initWithFrame:frame];
		label.textAlignment = NSTextAlignmentCenter;
		label.textColor = [UIColor blackColor];
		label.backgroundColor = nil;
        label.opaque = NO;
		label.font = [UIFont boldSystemFontOfSize:20];
	}
	
	NSNumber *number = @([self valueForPickerRow:pickerRow]);
	label.text = [formatter stringForObjectValue:number];

	return label;
}


@end
