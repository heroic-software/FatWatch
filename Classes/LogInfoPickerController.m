//
//  LogInfoPickerController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/13/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "LogInfoPickerController.h"
#import "LogTableViewCell.h"
#import "NSUserDefaults+EWAdditions.h"


@implementation LogInfoPickerController


@synthesize infoTypeButton;
@synthesize infoTypePicker;


- (void)updateButton {
	int auxInfoType = [LogTableViewCell auxiliaryInfoType];
	NSString *title = [LogTableViewCell nameForAuxiliaryInfoType:auxInfoType];
	[infoTypeButton setTitle:title forState:UIControlStateNormal];
}


- (void)bmiStatusDidChange:(NSNotification *)notification {
	[infoTypeArray release];
	infoTypeArray = [[LogTableViewCell availableAuxiliaryInfoTypes] copy];
	int auxInfoType = [LogTableViewCell auxiliaryInfoType];
	int row = [infoTypeArray indexOfObject:[NSNumber numberWithInt:auxInfoType]];
	[infoTypePicker reloadComponent:0];
	[infoTypePicker selectRow:row inComponent:0 animated:NO];
	[self updateButton];
}


#pragma mark BRPopUpViewController


- (void)setSuperview:(UIView *)aView {
	[super setSuperview:aView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bmiStatusDidChange:) name:EWBMIStatusDidChangeNotification object:nil];
	[self bmiStatusDidChange:nil];
}


- (IBAction)toggleDown:(UIButton *)sender {
	if (self.visible) {
		[self toggle:sender];
	} else {
		[self performSelector:@selector(toggle:) withObject:sender afterDelay:0.5];
	}
}


- (IBAction)toggleUp:(UIButton *)sender {
	[LogInfoPickerController cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggle:) object:sender];
	if (! self.visible) {
		int auxInfoType = [LogTableViewCell auxiliaryInfoType];
		int row = [infoTypeArray indexOfObject:[NSNumber numberWithInt:auxInfoType]];
		row = (row + 1) % [infoTypeArray count];
		auxInfoType = [[infoTypeArray objectAtIndex:row] intValue];
		[LogTableViewCell setAuxiliaryInfoType:auxInfoType];
		[self updateButton];
	}
}


- (IBAction)toggleCancel:(UIButton *)sender {
	[LogInfoPickerController cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggle:) object:sender];
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[infoTypeButton release];
	[infoTypePicker release];
	[infoTypeArray release];
	[super dealloc];
}


@end
