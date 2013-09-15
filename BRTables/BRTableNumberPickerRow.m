//
//  BRTableNumberPickerRow.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTableNumberPickerRow.h"
#import "BRTableSection.h"
#import "BRTableViewController.h"
#import "BRPickerViewController.h"


@implementation BRTableNumberPickerRow


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
	[controller release];
}


@end
