//
//  EnergyViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/5/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "EnergyViewController.h"
#import "NSUserDefaults+EWAdditions.h"
#import "EWEnergyFormatter.h"
#import "EWEnergyEquivalent.h"
#import "EWWeightFormatter.h"
#import "EWDatabase.h"


@implementation EnergyViewController


- (id)initWithWeight:(float)aWeight andChangePerDay:(float)rate {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		energyFormatter = [[EWEnergyFormatter alloc] init];
		weight = aWeight;
		energy = kCaloriesPerPound * rate;
		
		EWWeightFormatter *wf = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleDisplay];
		NSString *activitiesTitle = [NSString stringWithFormat:@"%@ (%@)",
									 NSLocalizedString(@"Activities", @"Activities section"),
									 [wf stringForFloat:weight]];
		
		titleArray = [[NSArray alloc] initWithObjects:
					  activitiesTitle,
					  NSLocalizedString(@"Foods & Nutrients", @"Foods section"),
					  nil];
		deletedItemArray = [[NSMutableArray alloc] init];
		self.title = NSLocalizedString(@"Energy", @"Energy view title");
		self.navigationItem.title = [energyFormatter stringFromFloat:energy];
		self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}


- (id <EWEnergyEquivalent>)makeNewEquivalentForSection:(NSInteger)section {
	id <EWEnergyEquivalent> equiv;
	if (section == 0) {
		equiv = [[EWActivityEquivalent alloc] init];
		equiv.name = @"Rest";
		equiv.value = 1;
	} else {
		equiv = [[EWFoodEquivalent alloc] init];
		equiv.name = @"Kilojoules";
		equiv.value = 1.0f / kKilojoulesPerCalorie;
		equiv.unitName = @"kJ";
	}
	return [equiv autorelease];
}


#pragma mark UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[dataArray release];
	dataArray = [[[EWDatabase sharedDatabase] loadEnergyEquivalents] copy];
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	if (!editing && dirty) {
		[[EWDatabase sharedDatabase] saveEnergyEquivalents:dataArray deletedItems:deletedItemArray];
		[deletedItemArray removeAllObjects];
		dirty = NO;
	}
}	


#pragma mark UITableViewDelegate & UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [dataArray count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[dataArray objectAtIndex:section] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [titleArray objectAtIndex:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	NSArray *sectionDataArray = [dataArray objectAtIndex:indexPath.section];
	id <EWEnergyEquivalent> equiv = [sectionDataArray objectAtIndex:indexPath.row];
	cell.textLabel.text = equiv.name;
	cell.detailTextLabel.text = [equiv stringForEnergy:energy];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSMutableArray *array = [dataArray objectAtIndex:indexPath.section];
		[deletedItemArray addObject:[array objectAtIndex:indexPath.row]];
		[array removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
						 withRowAnimation:UITableViewRowAnimationBottom];
		dirty = YES;
    }
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row < [[dataArray objectAtIndex:indexPath.section] count];
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	NSArray *array = [dataArray objectAtIndex:sourceIndexPath.section];
	if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
		// return last row in source section
		return [NSIndexPath indexPathForRow:([array count] - 1)
								  inSection:sourceIndexPath.section];
	}
	else if (sourceIndexPath.section > proposedDestinationIndexPath.section) {
		// return first row in source section
		return [NSIndexPath indexPathForRow:0
								  inSection:sourceIndexPath.section];
	}
	else if (proposedDestinationIndexPath.row < [array count]) {
		return proposedDestinationIndexPath;
	} else {
		return [NSIndexPath indexPathForRow:([array count] - 1) 
								  inSection:sourceIndexPath.section];
	}
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSMutableArray *fromSection = [dataArray objectAtIndex:fromIndexPath.section];
	id thing = [fromSection objectAtIndex:fromIndexPath.row];
	[thing retain];
	[fromSection removeObjectAtIndex:fromIndexPath.row];
	NSMutableArray *toSection = [dataArray objectAtIndex:toIndexPath.section];
	[toSection insertObject:thing atIndex:toIndexPath.row];
	[thing release];
	dirty = YES;
}


- (void)dealloc {
	[titleArray release];
	[dataArray release];
	[deletedItemArray release];
    [super dealloc];
}


@end

