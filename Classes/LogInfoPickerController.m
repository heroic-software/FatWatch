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


- (void)updatePicker {
	[infoTypeArray release];
	infoTypeArray = [[LogTableViewCell availableAuxiliaryInfoTypes] copy];
	int auxInfoType = [LogTableViewCell auxiliaryInfoType];
	int row = [infoTypeArray indexOfObject:[NSNumber numberWithInt:auxInfoType]];
	[infoTypePicker selectRow:row inComponent:0 animated:NO];
}


#pragma mark UIPickerViewDataSource


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
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
