/*
 * BRTableSwitchRow.m
 * Created by Benjamin Ragheb on 7/25/08.
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

#import "BRTableSwitchRow.h"


@interface BRTableSwitchRow ()
- (void)toggleSwitch:(UISwitch *)sender;
@end



@implementation BRTableSwitchRow
{
	NSString *key;
}

@synthesize key;


- (id)init {
	if ((self = [super init])) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		UISwitch *control = [[UISwitch alloc] init];
		[control addTarget:self 
					action:@selector(toggleSwitch:) 
		  forControlEvents:UIControlEventValueChanged];
		self.accessoryView = control;
	}
	return self;
}


- (void)configureCell:(UITableViewCell *)cell {
	[super configureCell:cell];
	UISwitch *control = (id)self.accessoryView;
	control.on = [[self.object valueForKey:self.key] boolValue];
}


- (void)toggleSwitch:(UISwitch *)sender {
	[self.object setValue:@(sender.on) forKey:self.key];
}


@end
