//
//  NewDatabaseViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/24/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NewDatabaseViewController.h"
#import "Database.h"
#import "WeightFormatter.h"
#import "EatWatchAppDelegate.h"

@implementation NewDatabaseViewController

- (id)init {
	if ([super initWithNibName:nil bundle:nil]) {
		self.title = NSLocalizedString(@"NEW_DATABASE_VIEW_TITLE", nil);
	}
	return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}


- (void)loadView {
	UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tableView.delegate = self;
	tableView.dataSource = self;
	self.view = tableView;
	[tableView release];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [[WeightFormatter weightUnitNames] count];
		case 1:
			return [[WeightFormatter energyUnitNames] count];
		case 2:
			return 1;
		default:
			return 0;
	}
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"WEIGHT_UNIT", nil);
		case 1:
			return NSLocalizedString(@"ENERGY_UNIT", nil);
		default:
			return nil;
	}
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 2:
			return NSLocalizedString(@"NEW_DATABASE_DISMISS_FOOTER", nil);
		default:
			return nil;
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil];
	
	switch ([indexPath section]) {
		case 0:
			cell.text = [[WeightFormatter weightUnitNames] objectAtIndex:[indexPath row]];
			if ([indexPath row] == [WeightFormatter indexOfSelectedWeightUnit]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			break;
		case 1:
			cell.text = [[WeightFormatter energyUnitNames] objectAtIndex:[indexPath row]];
			if ([indexPath row] == [WeightFormatter indexOfSelectedEnergyUnit]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			break;
		case 2:
			cell.text = NSLocalizedString(@"NEW_DATABASE_DISMISS", nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
	}
	
	return [cell autorelease];
}


- (void)moveCheckmarkInTableView:(UITableView *)tableView toIndexPath:(NSIndexPath *)indexPath fromRow:(int)oldRow {
	UITableViewCell *cell;

	// uncheck old cell
	cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:oldRow inSection:[indexPath section]]];
	cell.accessoryType = UITableViewCellAccessoryNone;

	// check new cell
	cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	switch ([indexPath section]) {
		case 0:
			[self moveCheckmarkInTableView:tableView toIndexPath:indexPath 
								   fromRow:[WeightFormatter indexOfSelectedWeightUnit]];
			[WeightFormatter selectWeightUnitAtIndex:[indexPath row]];
			break;
		case 1:
			[self moveCheckmarkInTableView:tableView toIndexPath:indexPath 
								   fromRow:[WeightFormatter indexOfSelectedEnergyUnit]];
			[WeightFormatter selectEnergyUnitAtIndex:[indexPath row]];
			break;
		case 2:
			[self dismissView];
			break;
	}
}


- (void)dismissView {
	EatWatchAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate removeLaunchView:self.view transitionType:kCATransitionPush subType:kCATransitionFromRight];
	[self autorelease];
}

@end
