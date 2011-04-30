//
//  BRTableRow.m
//  TimeTracker
//
//  Created by Benjamin Ragheb on 7/18/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTableViewController.h"
#import <objc/runtime.h>


@implementation BRTableRow


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
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
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
    const char *name = class_getName([self class]);
	return [NSString stringWithFormat:@"%s:%d", name, cellStyle];
}


- (UITableViewCell *)createCell {
	return [[[UITableViewCell alloc] initWithStyle:self.cellStyle reuseIdentifier:[self reuseableCellIdentifier]] autorelease];
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
