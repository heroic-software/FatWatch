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
#import "NewEquivalentViewController.h"


@implementation EnergyViewController


- (id)initWithWeight:(float)aWeight andChangePerDay:(float)rate database:(EWDatabase *)db {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
		energyFormatter = [[EWEnergyFormatter alloc] init];
		weight = aWeight;
		energy = kCaloriesPerPound * rate;
		database = [db retain];
		
		EWWeightFormatter *wf = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleDisplay];
		NSString *activitiesTitle = [NSString stringWithFormat:@"%@ (%@)",
									 NSLocalizedString(@"Activities", @"Activities section"),
									 [wf stringForFloat:weight]];
		
		titleArray = [[NSArray alloc] initWithObjects:
					  activitiesTitle,
					  NSLocalizedString(@"Foods & Nutrients", @"Foods section"),
					  nil];
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


- (void)showNewEquivalentView:(id)sender {
	if (newEquivalentController == nil) {
		newEquivalentController = [[NewEquivalentViewController alloc] init];
	}
	[self.navigationController pushViewController:newEquivalentController animated:YES];
}


- (void)updateCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	NSArray *sectionDataArray = [dataArray objectAtIndex:indexPath.section];
	id <EWEnergyEquivalent> equiv = [sectionDataArray objectAtIndex:indexPath.row];
	cell.textLabel.text = equiv.name;
	if (self.editing) {
		cell.detailTextLabel.text = [equiv description];
	} else {
		cell.detailTextLabel.text = [equiv stringForEnergy:energy];
	}
	[cell setNeedsLayout];
}


#pragma mark UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[dataArray release];
	dataArray = [[database loadEnergyEquivalents] copy];
	
	UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 320, 20)];
	label.opaque = NO;
	label.backgroundColor = nil;
	label.shadowColor = [UIColor whiteColor];
	label.shadowOffset = CGSizeMake(0, 1);
	label.textColor = [UIColor colorWithRed:0.24f green:0.269f blue:0.344f alpha:1];
	label.font = [UIFont boldSystemFontOfSize:20];
	label.text = [self.navigationItem.title stringByAppendingString:@" is equivalent to..."];
	label.textAlignment = UITextAlignmentCenter;
	[header addSubview:label];
	self.tableView.tableHeaderView = header;
	[label release];
	[header release];
}


- (void)viewDidUnload {
	[super viewDidUnload];
	[dataArray release];
	dataArray = nil;
}


- (void)viewDidAppear:(BOOL)animated {
	id equiv = newEquivalentController.newEquivalent;
	if (equiv) {
		int sec = [equiv isKindOfClass:[EWActivityEquivalent class]] ? 0 : 1;
		NSMutableArray *array = [dataArray objectAtIndex:sec];
		int row = [array count];
		[array addObject:equiv];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:sec];
		[self.tableView	insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							  withRowAnimation:UITableViewRowAnimationTop];
		[self.tableView scrollToRowAtIndexPath:indexPath 
							  atScrollPosition:UITableViewScrollPositionNone
									  animated:YES];
		dirty = YES;
		newEquivalentController.newEquivalent = nil;
	}
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	if (!editing && dirty) {
		[database saveEnergyEquivalents:dataArray];
		dirty = NO;
	}

	UIBarButtonItem *newLeftItem;
	if (editing) {
		newLeftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showNewEquivalentView:)];
	} else {
		newLeftItem = nil;
	}
	[self.navigationItem setLeftBarButtonItem:newLeftItem animated:YES];
	[newLeftItem release];
	
	for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		[self updateCell:cell forIndexPath:indexPath];
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


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0) {
		return NSLocalizedString(@"Amount of energy burned by an activity depends on current body weight.", nil);
	} else {
		return nil;
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	[self updateCell:cell forIndexPath:indexPath];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSMutableArray *array = [dataArray objectAtIndex:indexPath.section];
		[array removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
						 withRowAnimation:UITableViewRowAnimationFade];
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
	[database release];
	[titleArray release];
	[dataArray release];
	[newEquivalentController release];
    [super dealloc];
}


@end

