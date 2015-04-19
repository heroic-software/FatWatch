/*
 * BRTableNumberPickerRow.m
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

#import "BRTableNumberPickerRow.h"
#import "BRTableSection.h"
#import "BRTableViewController.h"
#import "BRPickerViewController.h"


@implementation BRTableNumberPickerRow
{
	float minimumValue;
	float maximumValue;
	float increment;
	NSNumber *defaultValue;
}

@synthesize minimumValue, maximumValue, increment, defaultValue;


- (id)init {
	if ((self = [super init])) {
		self.minimumValue = 0;
		self.maximumValue = 100;
		self.increment = 1;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	return self;
}


- (void)didSelect {
	[super didSelect];
	UIViewController *controller = [[BRNumberPickerViewController alloc] initWithRow:self];
	[self.section.controller presentViewController:controller forRow:self];
}


@end
