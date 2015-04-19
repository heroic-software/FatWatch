/*
 * LogInfoPickerController.m
 * Created by Benjamin Ragheb on 12/13/09.
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

#import "LogInfoPickerController.h"
#import "LogTableViewCell.h"
#import "NSUserDefaults+EWAdditions.h"


@implementation LogInfoPickerController
{
	UIButton *infoTypeButton;
	UIPickerView *infoTypePicker;
	NSArray *infoTypeArray;
	BOOL toggleTimerDidFire;
}

@synthesize infoTypeButton;
@synthesize infoTypePicker;


- (void)updateButton {
	AuxiliaryInfoType auxInfoType = [LogTableViewCell auxiliaryInfoType];
	NSString *title = [LogTableViewCell nameForAuxiliaryInfoType:auxInfoType];
	[infoTypeButton setTitle:title forState:UIControlStateNormal];
}


- (void)bmiStatusDidChange:(NSNotification *)notification {
	infoTypeArray = [[LogTableViewCell availableAuxiliaryInfoTypes] copy];
	AuxiliaryInfoType auxInfoType = [LogTableViewCell auxiliaryInfoType];
	NSUInteger row = [infoTypeArray indexOfObject:@(auxInfoType)];
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


- (IBAction)toggle:(UIButton *)sender {
	toggleTimerDidFire = YES;
	[super toggle:sender];
}


- (IBAction)toggleDown:(UIButton *)sender {
	toggleTimerDidFire = NO;
	[self performSelector:@selector(toggle:) withObject:sender afterDelay:0.250];
}


- (IBAction)toggleUp:(UIButton *)sender {
	if (toggleTimerDidFire) return;
	[LogInfoPickerController cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggle:) object:sender];
	AuxiliaryInfoType auxInfoType = [LogTableViewCell auxiliaryInfoType];
	NSUInteger row = [infoTypeArray indexOfObject:@(auxInfoType)];
	row = (row + 1) % [infoTypeArray count];
	auxInfoType = [infoTypeArray[row] intValue];
	[LogTableViewCell setAuxiliaryInfoType:auxInfoType];
	[infoTypePicker selectRow:row inComponent:0 animated:self.visible];
	[self updateButton];
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


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)rowView
{
    UILabel *label;

    if ([rowView isKindOfClass:[UILabel class]]) {
        label = (UILabel *)rowView;
    } else {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = nil;
        label.opaque = NO;
        label.font = [UIFont boldSystemFontOfSize:20];
    }

    int auxInfoType = [infoTypeArray[row] intValue];
    label.text = [LogTableViewCell nameForAuxiliaryInfoType:auxInfoType];
    [label sizeToFit];
    
    return label;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	int auxInfoType = [infoTypeArray[row] intValue];
	[LogTableViewCell setAuxiliaryInfoType:auxInfoType];
	[self updateButton];
}


#pragma mark Cleanup


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
