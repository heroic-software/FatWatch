//
//  BRTableRow.m
//  TimeTracker
//
//  Created by Benjamin Ragheb on 7/18/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTableViewController.h"


@implementation BRTableRow

@synthesize title, titleAlignment, titleColor, object, section, accessoryType;
@synthesize accessoryView;


+ (BRTableRow *)rowWithTitle:(NSString *)aTitle {
	BRTableRow *row = [[[BRTableRow alloc] init] autorelease];
	row.title = aTitle;
	return row;
}


+ (BRTableRow *)rowWithObject:(id)anObject {
	BRTableRow *row = [BRTableRow rowWithTitle:[anObject description]];
	row.object = anObject;
	return row;
}


- (id)init {
	if ([super init]) {
		self.titleAlignment = UITextAlignmentLeft;
		self.titleColor = [UIColor blackColor];
	}
	return self;
}


- (void)dealloc {
	[titleColor release];
	[title release];
	[object release];
	[super dealloc];
}


- (NSString *)reuseableCellIdentifier {
	return @"BRTableRowCell";
}


- (UITableViewCell *)createCell {
	return [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:[self reuseableCellIdentifier]] autorelease];
}


- (void)configureCell:(UITableViewCell *)cell {
	if (title) {
		cell.textLabel.text = title;
	} else {
		cell.textLabel.text = [object description];
	}
	cell.textLabel.textAlignment = titleAlignment;
	cell.textLabel.textColor = titleColor;
	cell.accessoryView = accessoryView;
	cell.accessoryType = accessoryType;
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
