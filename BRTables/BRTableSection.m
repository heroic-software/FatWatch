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


+ (BRTableSection *)section {
	return [[[BRTableSection alloc] init] autorelease];
}


- (id)init {
	if ((self = [super init])) {
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


- (void)willRemoveFromController {
	controller = nil;
}


- (NSUInteger)numberOfRows {
	return [rows count];
}


- (BRTableRow *)rowAtIndex:(NSUInteger)rowIndex {
	return rows[rowIndex];
}


- (NSIndexPath *)indexPathOfRow:(BRTableRow *)row {
	return [NSIndexPath indexPathForRow:[rows indexOfObject:row] 
							  inSection:[controller	indexOfSection:self]];
}


- (void)addRow:(BRTableRow *)tableRow animated:(BOOL)animated {
	[rows addObject:tableRow];
	[tableRow didAddToSection:self];
	if (animated) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([rows count] - 1) inSection:[controller indexOfSection:self]];
		[controller.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}


- (void)removeRowAtIndex:(NSUInteger)rowIndex animated:(BOOL)animated {
	[rows[rowIndex] willRemoveFromSection];
	[rows removeObjectAtIndex:rowIndex];
	if (animated) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:[controller indexOfSection:self]];
		[controller.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}


- (UITableViewCell *)cellForRowAtIndex:(NSUInteger)rowIndex {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:[controller indexOfSection:self]];
	return [controller.tableView cellForRowAtIndexPath:indexPath];
}


- (UITableViewCell *)cellForRow:(BRTableRow *)row {
	NSIndexPath *indexPath = [self indexPathOfRow:row];
	return [controller.tableView cellForRowAtIndexPath:indexPath];
}


- (void)configureCell:(UITableViewCell *)cell forRowAtIndex:(NSUInteger)rowIndex {
	[[self rowAtIndex:rowIndex] configureCell:cell];
}


- (void)didSelectRowAtIndex:(NSUInteger)rowIndex {
	// retain the row because it might be removing itself from the table
	BRTableRow *row = [[self rowAtIndex:rowIndex] retain];
	[row didSelect];
	[row release];
}


@end


@implementation  BRTableRadioSection


@synthesize selectedIndex;


- (id)init {
	if ((self = [super init])) {
		selectedIndex = -1;
	}
	return self;
}


- (void)configureCell:(UITableViewCell *)cell forRowAtIndex:(NSUInteger)rowIndex {
	[super configureCell:cell forRowAtIndex:rowIndex];
	if (rowIndex == (NSUInteger)selectedIndex) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
}


- (void)didSelectRowAtIndex:(NSUInteger)rowIndex {
	if (selectedIndex >= 0) {
		UITableViewCell *oldCell = [self cellForRowAtIndex:selectedIndex];
		oldCell.accessoryType = UITableViewCellAccessoryNone;
	}
	selectedIndex = rowIndex;
	UITableViewCell *cell = [self cellForRowAtIndex:selectedIndex];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	[super didSelectRowAtIndex:selectedIndex];
	[[self rowAtIndex:selectedIndex] deselectAnimated:YES];
}


- (BRTableRow *)selectedRow {
	if (selectedIndex >= 0) {
		return [self rowAtIndex:selectedIndex];
	} else {
		return nil;
	}
}


@end
