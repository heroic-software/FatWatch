//
//  BRTableButtonRow.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/25/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTableButtonRow.h"


@implementation BRTableButtonRow

@synthesize target, action, disabled;


+ (BRTableButtonRow *)rowWithTitle:(NSString *)aTitle target:(id)aTarget action:(SEL)anAction {
	BRTableButtonRow *row = [[BRTableButtonRow alloc] init];
	row.title = aTitle;
	row.target = aTarget;
	row.action = anAction;
	return [row autorelease];
}


- (NSString *)reuseableCellIdentifier {
	return @"BRTableButtonRowCell";
}


- (void)configureCell:(UITableViewCell *)cell {
	[super configureCell:cell];
	cell.textColor = disabled ? [UIColor grayColor] : titleColor;
}


- (void)didSelect {
	if (! disabled) {
		if ((target == nil) && [object isKindOfClass:[NSURL class]]) {
			[[UIApplication sharedApplication] openURL:object];
		} else {
			[target performSelector:action withObject:self];
		}
	}
	[[self cell] setSelected:NO];
}

@end
