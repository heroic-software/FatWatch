//
//  LogInfoPickerController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/13/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "LogInfoPickerController.h"
#import "LogTableViewCell.h"


@implementation LogInfoPickerController


@synthesize infoTypeButton;
@synthesize infoTypePicker;


- (void)updateButton {
	int auxInfoType = [LogTableViewCell auxiliaryInfoType];
	NSString *title = [LogTableViewCell nameForAuxiliaryInfoType:auxInfoType];
	[infoTypeButton setTitle:title forState:UIControlStateNormal];
}


#pragma mark UIPickerViewDataSource


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if (infoTypeArray == nil) {
		infoTypeArray = [[LogTableViewCell availableAuxiliaryInfoTypes] copy];
	}
	return [infoTypeArray count];
}


#pragma mark UIPickerViewDelegate


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	int auxInfoType = [[infoTypeArray objectAtIndex:row] intValue];
	return [LogTableViewCell nameForAuxiliaryInfoType:auxInfoType];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	int auxInfoType = [[infoTypeArray objectAtIndex:row] intValue];
	[LogTableViewCell setAuxiliaryInfoType:auxInfoType];
	[self updateButton];
}


#pragma mark Cleanup


- (void)dealloc {
	[infoTypeButton release];
	[infoTypePicker release];
	[infoTypeArray release];
	[super dealloc];
}


@end
