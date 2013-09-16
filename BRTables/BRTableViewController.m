//
//  BRTableViewController.m
//  TimeTracker
//
//  Created by Benjamin Ragheb on 7/18/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTableViewController.h"
#import "BRTableSection.h"
#import "BRTableRow.h"


@implementation BRTableViewController


- (id)initWithCoder:(NSCoder *)aDecoder	{
	if ((self = [super initWithCoder:aDecoder])) {
		sections = [[NSMutableArray alloc] init];
	}
	return self;
}


- (id)initWithStyle:(UITableViewStyle)style {
	if ((self = [super initWithStyle:style])) {
		sections = [[NSMutableArray alloc] init];
	}
	return self;
}


- (void)dealloc {
	[sections release];
	[super dealloc];
}


- (NSUInteger)numberOfSections {
	return [sections count];
}


- (void)addSection:(BRTableSection *)tableSection animated:(BOOL)animated {
	[sections addObject:tableSection];
	[tableSection didAddToController:self];
	if (animated) {
		NSIndexSet *set = [NSIndexSet indexSetWithIndex:([sections count] - 1)];
		[self.tableView insertSections:set withRowAnimation:UITableViewRowAnimationFade];
	}
}


- (BRTableSection *)addNewSection {
	BRTableSection *section = [[BRTableSection alloc] init];
	[self addSection:section animated:NO];
	[section release];
	return section;
}


- (void)removeSectionsAtIndexes:(NSIndexSet *)indexSet animated:(BOOL)animated {
	if (animated) {
		[self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
	}
	NSUInteger i = [indexSet lastIndex];
	while (i != NSNotFound) {
		BRTableSection *section = sections[i];
		[section willRemoveFromController];
		[sections removeObjectAtIndex:i];
		i = [indexSet indexLessThanIndex:i];
	}
}


- (void)removeAllSections {
	[sections makeObjectsPerformSelector:@selector(willRemoveFromController)];
	[sections removeAllObjects];
}


- (BRTableSection *)sectionAtIndex:(NSUInteger)i {
	return sections[i];
}


- (NSUInteger)indexOfSection:(BRTableSection *)section {
	return [sections indexOfObject:section];
}


- (void)presentViewController:(UIViewController *)controller forRow:(BRTableRow *)row {
	if (self.navigationController) {
		[self.navigationController pushViewController:controller animated:YES];
	} else {
		// Could replace this with a simple nav bar
		UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
		[self presentModalViewController:nav animated:YES];
		[nav release];
	}
}


- (void)dismissViewController:(UIViewController *)controller forRow:(BRTableRow *)row {
	if (self.navigationController) {
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		[controller dismissModalViewControllerAnimated:YES];
	}
}


#pragma mark UITableViewDataSource & UITableViewDelegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [sections count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [sections[section] numberOfRows];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	BRTableSection *section = sections[indexPath.section];
	BRTableRow* row = [section rowAtIndex:indexPath.row];
	
	UITableViewCell *cell = nil;
	
	NSString *reuseIdentifier = [row reuseableCellIdentifier];
	if (reuseIdentifier != nil) {
		cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	}
	
	if (cell == nil) {
		cell = [row createCell];
	}
	
	[section configureCell:cell forRowAtIndex:indexPath.row];
	
	return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	BRTableSection* section = sections[indexPath.section];
	[section retain];
	[section didSelectRowAtIndex:indexPath.row];
	[section release];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex {
	BRTableSection *section = sections[sectionIndex];
	return section.headerTitle;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)sectionIndex {
	BRTableSection *section = sections[sectionIndex];
	return section.footerTitle;
}


@end

