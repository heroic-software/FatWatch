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
					  NSLocalizedString(@"Nutrients", @"Nutrients section"),
					  NSLocalizedString(@"Foods", @"Foods section"),
					  activitiesTitle,
					  nil];
		dataArray = [[NSArray alloc] initWithObjects:
					 [NSMutableArray array],
					 [NSMutableArray array],
					 [NSMutableArray array],
					 nil];
		self.title = NSLocalizedString(@"Energy", @"Energy view title");
		self.navigationItem.title = [energyFormatter stringFromFloat:energy];
		self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}


- (EWEnergyEquivalent *)makeNewEquivalent {
	EWEnergyEquivalent *equiv = [[EWEnergyEquivalent alloc] init];
	equiv.name = @"Kilojoules";
	equiv.energyPerUnit = 1.0f / kKilojoulesPerCalorie;
	equiv.unitName = @"kJ";
	return [equiv autorelease];
}


#pragma mark UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	NSMutableArray *array;
	EWEnergyEquivalent *equiv;
	
	array = [dataArray objectAtIndex:0];

	equiv = [[EWEnergyEquivalent alloc] init];
	equiv.name = @"protein";
	equiv.energyPerUnit = 4; // 16.7 kJ
	equiv.unitName = @"g";
	[array addObject:equiv];
	[equiv release];
	
	equiv = [[EWEnergyEquivalent alloc] init];
	equiv.name = @"carbohydrate";
	equiv.energyPerUnit = 4; // 16.7 kJ
	equiv.unitName = @"g";
	[array addObject:equiv];
	[equiv release];
	
	equiv = [[EWEnergyEquivalent alloc] init];
	equiv.name = @"fat";
	equiv.energyPerUnit = 9; // 37.7 kJ
	equiv.unitName = @"g";
	[array addObject:equiv];
	[equiv release];
	
	equiv = [[EWEnergyEquivalent alloc] init];
	equiv.name = @"alcohol";
	equiv.energyPerUnit = 7;
	equiv.unitName = @"g";
	[array addObject:equiv];
	[equiv release];
	
	array = [dataArray objectAtIndex:1];
	
	equiv = [[EWEnergyEquivalent alloc] init];
	equiv.name = @"Apple (approx 3 per lb)";
	equiv.energyPerUnit = 71.8;
	equiv.unitName = @"medium";
	[array addObject:equiv];
	[equiv release];
	
	equiv = [[EWEnergyEquivalent alloc] init];
	equiv.name = @"Cola";
	equiv.energyPerUnit = 100.f/8.f;
	equiv.unitName = @"oz";
	[array addObject:equiv];
	[equiv release];
	
	equiv = [[EWEnergyEquivalent alloc] init];
	equiv.name = @"Cola (12 oz)";
	equiv.energyPerUnit = 12.f*100.f/8.f;
	equiv.unitName = @"can";
	[array addObject:equiv];
	[equiv release];

	equiv = [[EWEnergyEquivalent alloc] init];
	equiv.name = @"Cola (20 oz)";
	equiv.energyPerUnit = 20.f*100.f/8.f;
	equiv.unitName = @"bottle";
	[array addObject:equiv];
	[equiv release];
	
	equiv = [[EWEnergyEquivalent alloc] init];
	equiv.name = @"Beer (regular)";
	equiv.energyPerUnit = 153.1f;
	equiv.unitName = @"can";
	[array addObject:equiv];
	[equiv release];
	
	equiv = [[EWEnergyEquivalent alloc] init];
	equiv.name = @"Beer (light)";
	equiv.energyPerUnit = 102.7f;
	equiv.unitName = @"can";
	[array addObject:equiv];
	[equiv release];
	
	array = [dataArray objectAtIndex:2];

	equiv = [[EWEnergyEquivalent alloc] init];
	equiv.name = @"Dancing";
	[equiv setEnergyPerMinuteByMets:4.5 forWeight:weight];
	[array addObject:equiv];
	[equiv release];

	equiv = [[EWEnergyEquivalent alloc] init];
	equiv.name = @"3.5 METs";
	[equiv setEnergyPerMinuteByMets:3.5 forWeight:weight];
	[array addObject:equiv];
	[equiv release];

	equiv = [[EWEnergyEquivalent alloc] init];
	equiv.name = @"Two METs";
	[equiv setEnergyPerMinuteByMets:2.0 forWeight:weight];
	[array addObject:equiv];
	[equiv release];

	equiv = [[EWEnergyEquivalent alloc] init];
	equiv.name = @"Sitting Around";
	[equiv setEnergyPerMinuteByMets:1.0 forWeight:weight];
	[array addObject:equiv];
	[equiv release];
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


- (void)setEditing:(BOOL)flag animated:(BOOL)animated {
	[super setEditing:flag animated:animated];
	NSMutableArray *paths = [[NSMutableArray alloc] initWithCapacity:[dataArray count]];
	int s = 0;
	for (NSArray *array in dataArray) {
		[paths addObject:[NSIndexPath indexPathForRow:[array count] inSection:s++]];
	}
	if (flag) {
		[self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
	} else {
		[self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
	}
	[paths release];
}	


#pragma mark UITableViewDelegate & UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [dataArray count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[dataArray objectAtIndex:section] count] + (self.editing ? 1 : 0);
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
	if (indexPath.row < [sectionDataArray count]) {
		EWEnergyEquivalent *equiv = [sectionDataArray objectAtIndex:indexPath.row];
		cell.textLabel.text = equiv.name;
		cell.detailTextLabel.text = [equiv stringForEnergy:energy];
	} else {
		cell.textLabel.text = @"Add New";
		cell.detailTextLabel.text = nil;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [[dataArray objectAtIndex:indexPath.section] count]) {
		return UITableViewCellEditingStyleDelete;
	} else {
		return UITableViewCellEditingStyleInsert;
	}
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[[dataArray objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
						 withRowAnimation:UITableViewRowAnimationBottom];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
		[[dataArray objectAtIndex:indexPath.section] insertObject:[self makeNewEquivalent]
														  atIndex:indexPath.row];
		[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
						 withRowAnimation:UITableViewRowAnimationBottom];
    }   
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	NSArray *destinationSection = [dataArray objectAtIndex:proposedDestinationIndexPath.section];
	if (proposedDestinationIndexPath.row < [destinationSection count]) {
		return proposedDestinationIndexPath;
	} else {
		int newRow = [destinationSection count];
		if (sourceIndexPath.section == proposedDestinationIndexPath.section) {
			newRow -= 1;
		}
		return [NSIndexPath indexPathForRow:newRow inSection:proposedDestinationIndexPath.section];
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
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row < [[dataArray objectAtIndex:indexPath.section] count];
}


- (void)dealloc {
	[titleArray release];
	[dataArray release];
    [super dealloc];
}


@end

