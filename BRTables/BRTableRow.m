/*
 * BRTableRow.m
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
#import <objc/runtime.h>


@implementation BRTableRow
{
	BRTableSection *__weak section;
	id object;
	UITableViewCellStyle cellStyle;
	NSString *title;
	NSString *detail;
	UITextAlignment titleAlignment;
	UIColor *titleColor;
	UITableViewCellAccessoryType accessoryType;
	UIView *accessoryView;
	UITableViewCellSelectionStyle selectionStyle;
	UIImage *image;
}

@synthesize title;
@synthesize detail;
@synthesize cellStyle;
@synthesize titleAlignment;
@synthesize titleColor;
@synthesize object;
@synthesize section;
@synthesize accessoryType;
@synthesize accessoryView;
@synthesize selectionStyle;
@synthesize image;


+ (BRTableRow *)rowWithTitle:(NSString *)aTitle {
	BRTableRow *row = [[BRTableRow alloc] init];
	row.title = aTitle;
	return row;
}


+ (BRTableRow *)rowWithObject:(id)anObject {
	BRTableRow *row = [BRTableRow rowWithTitle:[anObject description]];
	row.object = anObject;
	return row;
}


- (id)init {
	if ((self = [super init])) {
		self.titleAlignment = NSTextAlignmentLeft;
		self.titleColor = [UIColor blackColor];
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	return self;
}




- (NSString *)reuseableCellIdentifier {
    const char *name = class_getName([self class]);
	return [NSString stringWithFormat:@"%s:%d", name, (int)cellStyle];
}


- (UITableViewCell *)createCell {
	return [[UITableViewCell alloc] initWithStyle:self.cellStyle reuseIdentifier:[self reuseableCellIdentifier]];
}


- (void)configureCell:(UITableViewCell *)cell {
	if (self.title) {
		cell.textLabel.text = self.title;
	} else {
		cell.textLabel.text = [self.object description];
	}
	cell.imageView.image = self.image;
	cell.detailTextLabel.text = self.detail;
	cell.textLabel.textAlignment = self.titleAlignment;
	cell.textLabel.textColor = self.titleColor;
	cell.accessoryView = self.accessoryView;
	cell.accessoryType = self.accessoryType;
	cell.selectionStyle = self.selectionStyle;
}


- (UITableViewCell *)cell {
	return [section cellForRow:self];
}


- (NSIndexPath *)indexPath {
	return [section indexPathOfRow:self];
}


- (void)didAddToSection:(BRTableSection *)aSection {
	section = aSection;
}


- (void)willRemoveFromSection {
	section = nil;
}


- (void)didSelect {
}


- (void)updateCell {
	[self configureCell:[self cell]];
}


- (void)deselectAnimated:(BOOL)animated {
	UITableView *tableView = self.section.controller.tableView;
	[tableView deselectRowAtIndexPath:[self indexPath] animated:animated];
}


@end
