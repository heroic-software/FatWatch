//
//  GoalViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "GoalViewController.h"
#import "EWDate.h"
#import "Database.h"
#import "MonthData.h"
#import "BRTableValueRow.h"
#import "BRTableDatePickerRow.h"
#import "BRTableNumberPickerRow.h"
#import "WeightFormatters.h"
#import "EWGoal.h"
#import "BRTableButtonRow.h"


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


- (void)addWarningSection {
	BRTableSection *section = [self addNewSection];
	section.footerTitle = NSLocalizedString(@"GOAL_NO_WEIGHT_WARNING", nil);
}


- (NSNumberFormatter *)makeBMIFormatter {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setPositiveFormat:NSLocalizedString(@"BMI_FORMAT", nil)];
	return [formatter autorelease];
}


- (void)addStartSection {
	BRTableSection *section = [self addNewSection];
	section.headerTitle = NSLocalizedString(@"START_SECTION_TITLE", nil);
	
	BRTableDatePickerRow *dateRow = [[BRTableDatePickerRow alloc] init];
	dateRow.title = NSLocalizedString(@"START_DATE", nil);
	dateRow.object = [EWGoal sharedGoal];
	dateRow.key = @"startDate";
	dateRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[section addRow:dateRow animated:NO];
	[dateRow release];
	
	BRTableValueRow *weightRow = [[BRTableValueRow alloc] init];
	weightRow.title = NSLocalizedString(@"START_WEIGHT", nil);
	weightRow.object = [EWGoal sharedGoal];
	weightRow.key = @"startWeight";
	weightRow.formatter = [WeightFormatters weightFormatter];
	[section addRow:weightRow animated:NO];
	[weightRow release];
	
	if ([EWGoal isBMIEnabled]) {
		BRTableValueRow *bmiRow = [[BRTableValueRow alloc] init];
		bmiRow.title = NSLocalizedString(@"START_BMI", nil);
		bmiRow.object = [EWGoal sharedGoal];
		bmiRow.key = @"startBMI";
		bmiRow.formatter = [self makeBMIFormatter];
		[section addRow:bmiRow animated:NO];
		[bmiRow release];
	}
}


- (void)addWeightRowsToSection:(BRTableSection *)section {
	BRTableNumberPickerRow *weightRow = [[BRTableNumberPickerRow alloc] init];
	weightRow.title = NSLocalizedString(@"GOAL_WEIGHT", nil);
	weightRow.object = [EWGoal sharedGoal];
	weightRow.key = @"endWeightNumber";
	weightRow.formatter = [WeightFormatters goalWeightFormatter];
	weightRow.increment = [WeightFormatters goalWeightIncrement];
	weightRow.minimumValue = 0;
	weightRow.maximumValue = 500;
	weightRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	weightRow.defaultValue = [NSNumber numberWithFloat:[[EWGoal sharedGoal] startWeight]];
	[section addRow:weightRow animated:NO];
	[weightRow release];
	
	if ([EWGoal isBMIEnabled]) {
		weightRow.backgroundColorFormatter = [WeightFormatters weightBackgroundColorFormatter];

		BRTableNumberPickerRow *bmiRow = [[BRTableNumberPickerRow alloc] init];
		bmiRow.title = NSLocalizedString(@"GOAL_BMI", nil);
		bmiRow.object = [EWGoal sharedGoal];
		bmiRow.key = @"endBMINumber";
		bmiRow.minimumValue = 0;
		bmiRow.maximumValue = 100;
		bmiRow.increment = 0.1f;
		bmiRow.formatter = [self makeBMIFormatter];
		bmiRow.backgroundColorFormatter = [WeightFormatters BMIBackgroundColorFormatter];
		bmiRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		bmiRow.defaultValue = [NSNumber numberWithFloat:[[EWGoal sharedGoal] startBMI]];
		[section addRow:bmiRow animated:NO];
		[bmiRow release];
	}
}


- (void)addGoalSection {
	BRTableSection *goalSection = [self addNewSection];
	goalSection.headerTitle = NSLocalizedString(@"GOAL_SECTION_TITLE", nil);
	
	BRTableDatePickerRow *dateRow = [[BRTableDatePickerRow alloc] init];
	dateRow.title = NSLocalizedString(@"GOAL_DATE", nil);
	dateRow.object = [EWGoal sharedGoal];
	dateRow.key = @"endDate";
	dateRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[goalSection addRow:dateRow animated:NO];
	[dateRow release];
	
	[self addWeightRowsToSection:goalSection];
}


- (void)addNoGoalSection {
	BRTableSection *goalSection = [self addNewSection];
	goalSection.headerTitle = NSLocalizedString(@"GOAL_SECTION_TITLE", nil);
	
	[self addWeightRowsToSection:goalSection];
}


- (void)addPlanSection {
	BRTableSection *planSection = [self addNewSection];
	planSection.headerTitle = NSLocalizedString(@"PLAN_SECTION_TITLE", nil);
	
	BRTableNumberPickerRow *energyRow = [[BRTableNumberPickerRow alloc] init];
	energyRow.title = NSLocalizedString(@"ENERGY_CHANGE_TITLE", nil);
	energyRow.object = [EWGoal sharedGoal];
	energyRow.key = @"weightChangePerDay";
	energyRow.formatter = [WeightFormatters energyChangePerDayFormatter];
	energyRow.increment = [WeightFormatters energyChangePerDayIncrement];
	energyRow.minimumValue = -1000 * energyRow.increment;
	energyRow.maximumValue = 1000 * energyRow.increment;
	energyRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[planSection addRow:energyRow animated:NO];
	[energyRow release];
	
	BRTableNumberPickerRow *weightRow = [[BRTableNumberPickerRow alloc] init];
	weightRow.title = NSLocalizedString(@"WEIGHT_CHANGE_TITLE", nil);
	weightRow.object = [EWGoal sharedGoal];
	weightRow.key = @"weightChangePerDay";
	weightRow.formatter = [WeightFormatters weightChangePerWeekFormatter];
	weightRow.increment = [WeightFormatters weightChangePerWeekIncrement];
	weightRow.minimumValue = -1000 * weightRow.increment;
	weightRow.maximumValue = 1000 * weightRow.increment;
	weightRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[planSection addRow:weightRow animated:NO];
	[weightRow release];
}


- (void)addClearSection {
	BRTableSection *section = [self addNewSection];
	
	BRTableButtonRow *clearRow = [BRTableButtonRow rowWithTitle:@"Clear Goal" target:self action:@selector(clearGoal:)];
	clearRow.titleAlignment = UITextAlignmentCenter;
	[section addRow:clearRow animated:NO];
}


- (id)init {
	if ([super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"GOAL_VIEW_TITLE", nil);
		self.tabBarItem.image = [UIImage imageNamed:@"TabIconGoal.png"];
		[self addWarningSection];
		
		[[EWGoal sharedGoal] addObserver:self forKeyPath:@"startDate" options:NSKeyValueObservingOptionNew context:NULL];
	}
	return self;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"startDate"]) {
		if ([self numberOfSections] == 4) {
			NSDate *newStartDate = [change objectForKey:NSKeyValueChangeNewKey];
			BRTableDatePickerRow *endRow = (id)[[self sectionAtIndex:1] rowAtIndex:0];
			endRow.minimumDate = [newStartDate addTimeInterval:SecondsPerDay];
		} else if ([self numberOfSections] == 2) {
			BRTableSection *section = [self sectionAtIndex:1];
			if ([section numberOfRows] > 0) {
				BRTableNumberPickerRow *weightRow = (id)[section rowAtIndex:0];
				weightRow.defaultValue = [NSNumber numberWithFloat:[object startWeight]];
			}
		}
	}
}


#pragma mark View Crap


- (void)viewWillAppear:(BOOL)animated {
	Database *db = [Database sharedDatabase];
	
	// not enough data: 1 section (message)
	// no goal set: 2 sections (start and goal)
	// goal set: 3 sections (start, goal, plan)
	
	if ([db weightCount] == 0) {
		if ([self numberOfSections] != 1) {
			[self removeAllSections];
			[self addWarningSection];
			[self.tableView reloadData];
		}
	} else {
		BOOL needsUpdate = (([[EWGoal sharedGoal] isDefined] != isSetupForGoal) || 
							([EWGoal isBMIEnabled] != isSetupForBMI) ||
							[self numberOfSections] < 2);
		
		if (needsUpdate) {
			if ([[EWGoal sharedGoal] isDefined]) {
				[self removeAllSections];
				[[EWGoal sharedGoal] startDate]; // set default if needed before adding observers
				[self addStartSection];
				[self addGoalSection];
				[self addPlanSection];
				[self addClearSection];
				[self.tableView reloadData];
			} else {
				[self removeAllSections];
				[[EWGoal sharedGoal] startDate]; // set default if needed before adding observers
				[self addStartSection];
				[self addNoGoalSection];
				[self.tableView reloadData];
			}
			isSetupForGoal = [[EWGoal sharedGoal] isDefined];
			isSetupForBMI = [EWGoal isBMIEnabled];
		}
		BRTableDatePickerRow *startDateRow = (BRTableDatePickerRow *)[[self sectionAtIndex:0] rowAtIndex:0];
		EWMonth earliestMonth = [db earliestMonth];
		EWDay earliestDay = [[db dataForMonth:earliestMonth] firstDayWithWeight];
		startDateRow.minimumDate = EWDateFromMonthAndDay(earliestMonth, MAX(1, earliestDay));
		startDateRow.maximumDate = [NSDate date];
	}
}


- (void)viewDidAppear:(BOOL)animated {
	[self.tableView beginUpdates];
	for (UITableViewCell *cell in [self.tableView visibleCells]) {
		[cell setSelected:NO animated:animated];
	}
	[self.tableView endUpdates];
}


#pragma mark Clearing


- (void)clearGoal:(BRTableButtonRow *)sender {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear Goal" otherButtonTitles:nil];
	[sheet showInView:self.view.window];
	[sheet release];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[EWGoal deleteGoal];
		[self removeSectionsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] animated:NO];
		[self addNoGoalSection];
		[self.tableView reloadData];
	}
}


@end
