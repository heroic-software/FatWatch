//
//  BRTableDatePickerRow.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTableDatePickerRow.h"
#import "BRTableSection.h"
#import "BRTableViewController.h"
#import "BRPickerViewController.h"


@implementation BRTableDatePickerRow


@synthesize minimumDate, maximumDate, datePickerMode;


- (id)init {
	if ([super init]) {
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
		return [UIColor colorWithRed:0.9 green:0 blue:0 alpha:1];
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
		[df release];
		return df;
	}
	return f;
}


- (void)dealloc {
	[minimumDate release];
	[maximumDate release];
	[super dealloc];
}


- (void)didSelect {
	[super didSelect];
	BRDatePickerViewController *controller = [[BRDatePickerViewController alloc] initWithRow:self];
	[self.section.controller presentViewController:controller forRow:self];
	[controller release];
}


@end
