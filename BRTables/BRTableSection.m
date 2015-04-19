/*
 * BRTableSection.m
 * Created by Benjamin Ragheb on 7/18/08.
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

#import "BRTableViewController.h"


@implementation BRTableSection
{
	NSMutableArray *rows;
	BRTableViewController *__weak controller;
	NSString *headerTitle, *footerTitle;
}

@synthesize headerTitle, footerTitle, controller;


+ (BRTableSection *)section {
	return [[BRTableSection alloc] init];
}


- (id)init {
	if ((self = [super init])) {
		rows = [[NSMutableArray alloc] init];
	}
	return self;
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
	BRTableRow *row = [self rowAtIndex:rowIndex];
	[row didSelect];
}


@end


@implementation  BRTableRadioSection
{
	NSInteger selectedIndex;
}

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
