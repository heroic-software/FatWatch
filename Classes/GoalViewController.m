//
//  GoalViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRColorPalette.h"
#import "BRRangeColorFormatter.h"
#import "BRTableButtonRow.h"
#import "BRTableDatePickerRow.h"
#import "BRTableNumberPickerRow.h"
#import "BRTableValueRow.h"
#import "EWDBMonth.h"
#import "EWDatabase.h"
#import "EWDate.h"
#import "EWGoal.h"
#import "EWWeightChangeFormatter.h"
#import "EWWeightFormatter.h"
#import "GoalViewController.h"
#import "NSUserDefaults+EWAdditions.h"


/*Goal screen:
 
 Start
 Date: [pick] [default: first day of data]
 Weight: [retrieved from log]
 
 Goal:
 Date: [pick] [default: computed from others]
 Weight: [pick] [default: -10 lbs]
 
 Plan:
 Energy: [pick] cal/day [default -500]
 Weight: [pick] lbs/week [default -1]
 
 Progress:
 Energy: cal/day (actual from start date to today)
 Weight: lbs/week (actual from start date to today)
 "X days to go"
 "X lbs to go"
 
 Clear Goal (button) [are you sure? prompt]
 
 
 change Start Date, update Goal Date
 change Goal Date, update Plan *
 change Goal Weight, update Goal Date
 change Plan *, update Goal Date
 
 Initially display only a "Set Goal" button, when pressed, display whole form with defaults.
 
 */


@implementation GoalViewController


- (NSNumberFormatter *)makeBMIFormatter {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setPositiveFormat:NSLocalizedString(@"BMI 0.0", @"BMI format")];
	return [formatter autorelease];
}


- (void)addWeightRowsToSection:(BRTableSection *)section {
	BRTableNumberPickerRow *weightRow = [[BRTableNumberPickerRow alloc] init];
	weightRow.title = NSLocalizedString(@"Goal Weight", @"Goal end weight");
	weightRow.object = [EWGoal sharedGoal];
	weightRow.key = @"endWeightNumber";
	weightRow.formatter = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleWhole];
	weightRow.increment = [[NSUserDefaults standardUserDefaults] weightWholeIncrement];
	weightRow.minimumValue = 0;
	weightRow.maximumValue = 500;
	weightRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	// TODO: pick default
	weightRow.defaultValue = [NSNumber numberWithFloat:150];
	[section addRow:weightRow animated:NO];
	[weightRow release];
	
	if ([[NSUserDefaults standardUserDefaults] isBMIEnabled]) {
		
		float w[3];
		[EWWeightFormatter getBMIWeights:w];
		BRColorPalette *palette = [BRColorPalette sharedPalette];
		NSArray *colorArray = [NSArray arrayWithObjects:
							   [[palette colorNamed:@"BMIUnderweight"] colorWithAlphaComponent:0.4],
							   [[palette colorNamed:@"BMINormal"] colorWithAlphaComponent:0.4],
							   [[palette colorNamed:@"BMIOverweight"] colorWithAlphaComponent:0.4],
							   [[palette colorNamed:@"BMIObese"] colorWithAlphaComponent:0.4],
							   nil];
		BRRangeColorFormatter *colorFormatter = [[BRRangeColorFormatter alloc] initWithColors:colorArray forValues:w];
		weightRow.backgroundColorFormatter = colorFormatter;
		[colorFormatter release];

		BRTableNumberPickerRow *bmiRow = [[BRTableNumberPickerRow alloc] init];
		bmiRow.title = NSLocalizedString(@"Goal BMI", @"Goal end BMI");
		bmiRow.object = weightRow.object;
		bmiRow.key = weightRow.key;
		bmiRow.minimumValue = weightRow.minimumValue;
		bmiRow.maximumValue = weightRow.maximumValue;
		NSNumberFormatter *bmiFormatter = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleBMILabeled];
		bmiRow.formatter = bmiFormatter;
		bmiRow.increment = 0.5f / [[bmiFormatter multiplier] floatValue];
		bmiRow.backgroundColorFormatter = weightRow.backgroundColorFormatter;
		bmiRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		bmiRow.defaultValue = weightRow.defaultValue;
		[section addRow:bmiRow animated:NO];
		[bmiRow release];
	}
}


- (void)addNoGoalSection {
	BRTableSection *goalSection = [self addNewSection];
	goalSection.headerTitle = NSLocalizedString(@"Goal", @"Goal end section title");
	
	[self addWeightRowsToSection:goalSection];
}


- (void)addGoalSection {
	BRTableSection *goalSection = [self addNewSection];
	goalSection.headerTitle = NSLocalizedString(@"Goal", @"Goal end section title");

	[self addWeightRowsToSection:goalSection];
	
	BRTableDatePickerRow *dateRow = [[BRTableDatePickerRow alloc] init];
	dateRow.title = NSLocalizedString(@"Goal Date", @"Goal end date");
	dateRow.object = [EWGoal sharedGoal];
	dateRow.key = @"endDate";
	dateRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[goalSection addRow:dateRow animated:NO];
	[dateRow release];
}


- (void)addPlanSection {
	BRTableSection *planSection = [self addNewSection];
	planSection.headerTitle = NSLocalizedString(@"Plan", @"Goal plan section title");
	planSection.footerTitle = NSLocalizedString(@"Change the plan to update your goal date.", @"Goal plan section footer");
	
	BRTableNumberPickerRow *energyRow = [[BRTableNumberPickerRow alloc] init];
	energyRow.title = NSLocalizedString(@"Energy Plan", @"Goal plan energy");
	energyRow.object = [EWGoal sharedGoal];
	energyRow.key = @"weightChangePerDay";
	energyRow.formatter = [[[EWWeightChangeFormatter alloc] initWithStyle:EWWeightChangeFormatterStyleEnergyPerDay] autorelease];
	energyRow.increment = [EWWeightChangeFormatter energyChangePerDayIncrement];
	energyRow.minimumValue = -1000 * energyRow.increment;
	energyRow.maximumValue = 1000 * energyRow.increment;
	energyRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[planSection addRow:energyRow animated:NO];
	[energyRow release];
	
	BRTableNumberPickerRow *weightRow = [[BRTableNumberPickerRow alloc] init];
	weightRow.title = NSLocalizedString(@"Weight Plan", @"Goal plan weight");
	weightRow.object = [EWGoal sharedGoal];
	weightRow.key = @"weightChangePerDay";
	weightRow.formatter = [[[EWWeightChangeFormatter alloc] initWithStyle:EWWeightChangeFormatterStyleWeightPerWeek] autorelease];
	weightRow.increment = [EWWeightChangeFormatter weightChangePerWeekIncrement];
	weightRow.minimumValue = -1000 * weightRow.increment;
	weightRow.maximumValue = 1000 * weightRow.increment;
	weightRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[planSection addRow:weightRow animated:NO];
	[weightRow release];
}


- (id)init {
	if ([super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"Goal", @"Goal view title");
		self.tabBarItem.image = [UIImage imageNamed:@"TabIconGoal.png"];
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"Clear Goal nav button") style:UIBarButtonItemStyleBordered target:self action:@selector(clearGoal:)] autorelease];
	}
	return self;
}


#pragma mark View Crap


- (void)viewDidLoad {
	[super viewDidLoad];
	self.tableView.scrollEnabled = NO;
}


- (void)updateTableSections {
	// no goal set: 1 sections (goal)
	// goal set: 2 sections (goal, plan)
	
	BOOL goalDefined = [[EWGoal sharedGoal] isDefined];
	BOOL bmiEnabled = [[NSUserDefaults standardUserDefaults] isBMIEnabled];
	BOOL needsUpdate = ((goalDefined != isSetupForGoal) || 
						(bmiEnabled != isSetupForBMI) ||
						[self numberOfSections] < 1);
	
	if (needsUpdate) {
		[self removeAllSections];
		if (goalDefined) {
			[self addGoalSection];
			[self addPlanSection];
		} else {
			[self addNoGoalSection];
		}
		[self.tableView reloadData];
		isSetupForGoal = goalDefined;
		isSetupForBMI = bmiEnabled;
	}
}


- (void)viewWillAppear:(BOOL)animated {
	[self updateTableSections];
}


- (void)viewDidAppear:(BOOL)animated {
	for (UITableViewCell *cell in [self.tableView visibleCells]) {
		[cell setHighlighted:NO animated:animated];
	}
}


#pragma mark Clearing


- (void)clearGoal:(id)sender {
	UIActionSheet *sheet = [[UIActionSheet alloc] init];
	sheet.delegate = self;

	sheet.destructiveButtonIndex = 
	[sheet addButtonWithTitle:NSLocalizedString(@"Clear Goal", @"Clear goal button")];
	
	sheet.cancelButtonIndex =
	[sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button")];

	[sheet showInView:self.view.window];
	[sheet release];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		[EWGoal deleteGoal];
		[self updateTableSections];
	}
}


@end
