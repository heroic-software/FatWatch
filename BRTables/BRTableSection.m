//
//  BRTableSection.m
//  TimeTracker
//
//  Created by Benjamin Ragheb on 7/18/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTableViewController.h"


@implementation BRTableSection

@synthesize headerTitle, footerTitle, controller;


- (id)init {
	if ([super init]) {
		rows = [[NSMutableArray alloc] init];
	}
	return self;
}


- (void)dealloc {
	[rows release];
	[headerTitle release];
	[footerTitle release];
	[super dealloc];
}


- (void)didAddToController:(BRTableViewController *)aController {
	controller = aController;
}


- (NSUInteger)numberOfRows {
	return [rows count];
}


- (BRTableRow *)rowAtIndex:(NSUInteger)index {
	return [rows objectAtIndex:index];
}


- (void)addRow:(BRTableRow *)tableRow animated:(BOOL)animated {
	[rows addObject:tableRow];
	[tableRow didAddToSection:self];
	if (animated) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([rows count] - 1) inSection:[controller indexOfSection:self]];
		[controller.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}


- (void)removeRowAtIndex:(NSUInteger)index animated:(BOOL)animated {
	[[rows objectAtIndex:index] willRemoveFromSection];
	[rows removeObjectAtIndex:index];
	if (animated) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:[controller indexOfSection:self]];
		[controller.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}


- (UITableViewCell *)cellForRowAtIndex:(NSUInteger)index {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:[controller indexOfSection:self]];
	return [controller.tableView cellForRowAtIndexPath:indexPath];
}


- (UITableViewCell *)cellForRow:(BRTableRow *)row {
	return [self cellForRowAtIndex:[rows indexOfObject:row]];
}


- (void)configureCell:(UITableViewCell *)cell forRowAtIndex:(NSUInteger)index {
	[[self rowAtIndex:index] configureCell:cell];
}


- (void)didSelectRowAtIndex:(NSUInteger)index {
	// retain the row because it might be removing itself from the table
	BRTableRow *row = [[self rowAtIndex:index] retain];
	[row didSelect];
	[row release];
}


@end


@implementation  BRTableRadioSection


@synthesize selectedIndex;


- (id)init {
	if ([super init]) {
		selectedIndex = -1;
	}
	return self;
}


- (void)configureCell:(UITableViewCell *)cell forRowAtIndex:(NSUInteger)index {
	[super configureCell:cell forRowAtIndex:index];
	if (index == selectedIndex) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
}


- (void)didSelectRowAtIndex:(NSUInteger)index {
	if (selectedIndex >= 0) {
		UITableViewCell *oldCell = [self cellForRowAtIndex:selectedIndex];
		oldCell.accessoryType = UITableViewCellAccessoryNone;
	}
	selectedIndex = index;
	UITableViewCell *cell = [self cellForRowAtIndex:selectedIndex];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	[super didSelectRowAtIndex:index];
}


@end
