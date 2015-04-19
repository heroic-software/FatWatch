/*
 * BRTableDatePickerRow.m
 * Created by Benjamin Ragheb on 7/26/08.
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

#import "BRTableDatePickerRow.h"
#import "BRTableSection.h"
#import "BRTableViewController.h"
#import "BRPickerViewController.h"


@implementation BRTableDatePickerRow
{
	NSDate *minimumDate;
	NSDate *maximumDate;
	UIDatePickerMode datePickerMode;
}

@synthesize minimumDate, maximumDate, datePickerMode;


- (id)init {
	if ((self = [super init])) {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.datePickerMode = UIDatePickerModeDate;
	}
	return self;
}


- (BOOL)isValueInRange {
	NSDate *date = self.value;
	if (self.minimumDate) {
		NSTimeInterval t = [date timeIntervalSinceDate:self.minimumDate];
		if (t < 0) return NO;
	}
	if (self.maximumDate) {
		NSTimeInterval t = [date timeIntervalSinceDate:self.maximumDate];
		if (t > 0) return NO;
	}
	return YES;
}


- (UIColor *)titleColor {
	if ([self isValueInRange]) {
		return [super titleColor];
	} else {
		return [UIColor colorWithRed:0.9f green:0 blue:0 alpha:1];
	}
}


- (NSFormatter *)formatter {
	NSFormatter *f = [super formatter];
	if (f == nil) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		if (self.datePickerMode == UIDatePickerModeDate) {
			[df setDateStyle:NSDateFormatterLongStyle];
			[df setTimeStyle:NSDateFormatterNoStyle];
		} else if (self.datePickerMode == UIDatePickerModeTime) {
			[df setDateStyle:NSDateFormatterNoStyle];
			[df setTimeStyle:NSDateFormatterShortStyle];
		} else if (self.datePickerMode == UIDatePickerModeDateAndTime) {
			[df setDateStyle:NSDateFormatterLongStyle];
			[df setTimeStyle:NSDateFormatterShortStyle];
		}
		self.formatter = df;
		return df;
	}
	return f;
}




- (void)didSelect {
	[super didSelect];
	BRDatePickerViewController *controller = [[BRDatePickerViewController alloc] initWithRow:self];
	[self.section.controller presentViewController:controller forRow:self];
}


@end
