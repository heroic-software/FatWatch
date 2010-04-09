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


@interface EWRatePickerRow : BRTableNumberPickerRow
{
}
@end


@implementation EWRatePickerRow
- (void)didSelect {
	if ([self.value floatValue] < 0) {
		self.minimumValue = -1000 * self.increment;
		self.maximumValue = -self.increment;
	} else {
		self.minimumValue = self.increment;
		self.maximumValue = 1000 * self.increment;
	}
	[super didSelect];
}
@end


@implementation GoalViewController


- (NSNumberFormatter *)makeBMIFormatter {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setPositiveFormat:NSLocalizedString(@"BMI 0.0", @"BMI format")];
	return [formatter autorelease];
}


- (void)addGoalSection {
	BRTableSection *section = [self addNewSection];
	section.headerTitle = NSLocalizedString(@"Goal", @"Goal end section title");

	BRTableNumberPickerRow *weightRow = [[BRTableNumberPickerRow alloc] init];
	weightRow.title = NSLocalizedString(@"Goal Weight", @"Goal end weight");
	weightRow.object = [EWGoal sharedGoal];
	weightRow.key = @"endWeightNumber";
	weightRow.formatter = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleWhole];
	weightRow.increment = [[NSUserDefaults standardUserDefaults] weightWholeIncrement];
	weightRow.minimumValue = 0;
	weightRow.maximumValue = 500;
	weightRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	float w = [[EWDatabase sharedDatabase] latestWeight];
	if (w == 0) w = 150;
	weightRow.defaultValue = [NSNumber numberWithFloat:w];
	
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


- (void)addPlanSection {
	BRTableSection *planSection = [self addNewSection];
	planSection.headerTitle = NSLocalizedString(@"Plan", @"Goal plan section title");
	planSection.footerTitle = NSLocalizedString(@"Unlocked values are updated as your weight changes. Edit a value to lock it.", @"Goal plan section footer");
	
	BRTableDatePickerRow *dateRow = [[BRTableDatePickerRow alloc] init];
	dateRow.title = NSLocalizedString(@"Goal Date", @"Goal end date");
	dateRow.object = [EWGoal sharedGoal];
	dateRow.key = @"endDate";
	dateRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	dateRow.minimumDate = EWDateFromMonthDay(EWMonthDayNext(EWMonthDayToday()));
	[planSection addRow:dateRow animated:NO];
	[dateRow release];

	BRTableNumberPickerRow *energyRow = [[EWRatePickerRow alloc] init];
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
	
	BRTableNumberPickerRow *weightRow = [[EWRatePickerRow alloc] init];
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
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearGoal:)] autorelease];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(databaseDidChange:) name:EWDatabaseDidChangeNotification object:nil];
	}
	return self;
}


- (void)databaseDidChange:(NSNotification *)notification {
	needsReload = YES;
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
		[self addGoalSection];
		if (goalDefined) {
			[self addPlanSection];
		}
		needsReload = YES;
		isSetupForGoal = goalDefined;
		isSetupForBMI = bmiEnabled;
	}
	
	self.navigationItem.leftBarButtonItem.enabled = goalDefined;
	
	if (needsReload) {
		[self.tableView reloadData];
		needsReload = NO;
	}
}


- (void)viewWillAppear:(BOOL)animated {
	[self updateTableSections];
	
	if ([self numberOfSections] >= 2) {
		BRTableSection *planSection = [self sectionAtIndex:1];
		BRTableRow *dateRow = [planSection rowAtIndex:0];
		BRTableRow *rateRow1 = [planSection rowAtIndex:1];
		BRTableRow *rateRow2 = [planSection rowAtIndex:2];
		UIImage *lock0Image = [UIImage imageNamed:@"Lock0.png"];
		UIImage *lock1Image = [UIImage imageNamed:@"Lock1.png"];
		switch ([[EWGoal sharedGoal] state]) {
			case EWGoalStateFixedDate:
				dateRow.image = lock1Image;
				rateRow1.image = lock0Image;
				rateRow2.image = lock0Image;
				break;
			case EWGoalStateFixedRate:
				dateRow.image = lock0Image;
				rateRow1.image = lock1Image;
				rateRow2.image = lock1Image;
			default:
				break;
		}
		[dateRow configureCell:[dateRow cell]];
		[rateRow1 configureCell:[rateRow1 cell]];
		[rateRow2 configureCell:[rateRow2 cell]];
	}
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
