//
//  BRTableSwitchRow.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/25/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTableSwitchRow.h"


@implementation BRTableSwitchRow


@synthesize key;


- (NSString *)reuseableCellIdentifier {
	return @"BRTableSwitchRowCell";
}


- (UITableViewCell *)createCell {
	UITableViewCell *cell = [super createCell];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}


- (void)configureCell:(UITableViewCell *)cell {
	[super configureCell:cell];
	UISwitch *control = [[UISwitch alloc] init];
	control.on = [[self.object valueForKey:self.key] boolValue];
	[control addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
	cell.accessoryView = control;
	[control release];
}


- (void)toggleSwitch:(UISwitch *)sender {
	[self.object setValue:[NSNumber numberWithBool:sender.on] forKey:self.key];
}


@end
