//
//  BRTableButtonRow.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/25/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTableButtonRow.h"
#import "BRTableSection.h"
#import "BRTableViewController.h"


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
	return [NSString stringWithFormat:@"BRTableButtonRowCell:%d", self.cellStyle];
}


- (void)configureCell:(UITableViewCell *)cell {
	[super configureCell:cell];
	cell.textLabel.textColor = self.disabled ? [UIColor grayColor] : self.titleColor;
}


- (void)didSelect {
	[self deselectAnimated:YES];
	if (disabled) return;
	if (self.target) {
		[self.target performSelector:self.action withObject:self];
	}
	if ([self.object isKindOfClass:[NSURL class]]) {
		[[UIApplication sharedApplication] openURL:self.object];
	}
	if ([self.object isKindOfClass:[UIViewController class]]) {
		[self.section.controller presentViewController:self.object forRow:self];
	}
}


@end
