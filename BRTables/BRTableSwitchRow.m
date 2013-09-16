//
//  BRTableSwitchRow.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/25/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTableSwitchRow.h"


@interface BRTableSwitchRow ()
- (void)toggleSwitch:(UISwitch *)sender;
@end



@implementation BRTableSwitchRow


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
