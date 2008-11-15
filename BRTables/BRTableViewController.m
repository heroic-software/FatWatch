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


- (id)initWithStyle:(UITableViewStyle)style {
	if ([super initWithStyle:style]) {
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
		NSIndexSet *index = [NSIndexSet indexSetWithIndex:([sections count] - 1)];
		[self.tableView insertSections:index withRowAnimation:UITableViewRowAnimationFade];
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
	NSUInteger index = [indexSet lastIndex];
	while (index != NSNotFound) {
		BRTableSection *section = [sections objectAtIndex:index];
		[section willRemoveFromController];
		[[section retain] autorelease];
		[sections removeObjectAtIndex:index];
		index = [indexSet indexLessThanIndex:index];
	}
}


- (void)removeAllSections {
	[sections makeObjectsPerformSelector:@selector(willRemoveFromController)];
	[sections removeAllObjects];
}


- (BRTableSection *)sectionAtIndex:(NSUInteger)index {
	return [sections objectAtIndex:index];
}


- (NSUInteger)indexOfSection:(BRTableSection *)section {
	return [sections indexOfObject:section];
}


- (void)presentViewController:(UIViewController *)controller forRow:(BRTableRow *)row {
	if (self.navigationController) {
		controller.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:controller animated:YES];
	} else {
		// TODO: replace this with a simple nav bar
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
	return [[sections objectAtIndex:section] numberOfRows];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	BRTableSection *section = [sections	objectAtIndex:indexPath.section];
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
	BRTableSection* section = [sections	objectAtIndex:indexPath.section];
	[section retain];
	[section didSelectRowAtIndex:indexPath.row];
	[section release];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex {
	BRTableSection *section = [sections	objectAtIndex:sectionIndex];
	return section.headerTitle;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)sectionIndex {
	BRTableSection *section = [sections	objectAtIndex:sectionIndex];
	return section.footerTitle;
}


- (void)viewDidLoad {
	[super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


@end

