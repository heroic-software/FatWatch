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


- (void)addWarningSection {
	BRTableSection *section = [self addNewSection];
	section.footerTitle = NSLocalizedString(@"You must weigh-in before you can set a goal.", @"No data in goal view.");
}


- (NSNumberFormatter *)makeBMIFormatter {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setPositiveFormat:NSLocalizedString(@"BMI 0.0", @"BMI format")];
	return [formatter autorelease];
}


- (void)addStartSection {
	BRTableSection *section = [self addNewSection];
	section.headerTitle = NSLocalizedString(@"Start", @"Goal start section title");
	
	BRTableDatePickerRow *dateRow = [[BRTableDatePickerRow alloc] init];
	dateRow.title = NSLocalizedString(@"Start Date", @"Goal start date");
	dateRow.object = [EWGoal sharedGoal];
	dateRow.key = @"startDate";
	dateRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[section addRow:dateRow animated:NO];
	[dateRow release];
	
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
	[infoButton addTarget:self 
				   action:@selector(showStartWeightInfo) 
		 forControlEvents:UIControlEventTouchUpInside];
	
	BRTableValueRow *weightRow = [[BRTableValueRow alloc] init];
	weightRow.title = NSLocalizedString(@"Start Weight", @"Goal start weight");
	weightRow.object = [EWGoal sharedGoal];
	weightRow.key = @"startWeight";
	weightRow.formatter = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleWhole];
	weightRow.accessoryView = infoButton;
	[section addRow:weightRow animated:NO];
	[weightRow release];
	
	if ([[NSUserDefaults standardUserDefaults] isBMIEnabled]) {
		BRTableValueRow *bmiRow = [[BRTableValueRow alloc] init];
		bmiRow.title = NSLocalizedString(@"Start BMI", @"Goal start BMI");
		bmiRow.object = weightRow.object;
		bmiRow.key = weightRow.key;
		bmiRow.formatter = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleBMILabeled];
		[section addRow:bmiRow animated:NO];
		[bmiRow release];
	}
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
	weightRow.defaultValue = [NSNumber numberWithFloat:[[EWGoal sharedGoal] startWeight]];
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


- (void)addGoalSection {
	BRTableSection *goalSection = [self addNewSection];
	goalSection.headerTitle = NSLocalizedString(@"Goal", @"Goal end section title");
	
	BRTableDatePickerRow *dateRow = [[BRTableDatePickerRow alloc] init];
	dateRow.title = NSLocalizedString(@"Goal Date", @"Goal end date");
	dateRow.object = [EWGoal sharedGoal];
	dateRow.key = @"endDate";
	dateRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	// TODO: bind minimumDate to goalStartDate
	[goalSection addRow:dateRow animated:NO];
	[dateRow release];
	
	[self addWeightRowsToSection:goalSection];
}


- (void)addNoGoalSection {
	BRTableSection *goalSection = [self addNewSection];
	goalSection.headerTitle = NSLocalizedString(@"Goal", @"Goal end section title");
	
	[self addWeightRowsToSection:goalSection];
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


- (void)addClearSection {
	BRTableSection *section = [self addNewSection];
	
	BRTableButtonRow *clearRow = [BRTableButtonRow rowWithTitle:NSLocalizedString(@"Clear Goal", @"Clear goal button") target:self action:@selector(clearGoal:)];
	clearRow.titleAlignment = UITextAlignmentCenter;
	[section addRow:clearRow animated:NO];
}


- (id)init {
	if ([super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"Goal", @"Goal view title");
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
	EWDatabase *db = [EWDatabase sharedDatabase];
	
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
							([[NSUserDefaults standardUserDefaults] isBMIEnabled] != isSetupForBMI) ||
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
			isSetupForBMI = [[NSUserDefaults standardUserDefaults] isBMIEnabled];
		}
		BRTableDatePickerRow *startDateRow = (BRTableDatePickerRow *)[[self sectionAtIndex:0] rowAtIndex:0];
		EWMonth earliestMonth = [db earliestMonth];
		EWDay earliestDay = [[db getDBMonth:earliestMonth] firstDayWithWeight];
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


#pragma mark Info


- (void)showStartWeightInfo {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"About Start Weight", @"Start Weight alert title")
													message:NSLocalizedString(@"This is the value of your weight's moving average (not the scale reading) on your selected start date.", @"Start Weight explanation")
												   delegate:nil
										  cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Start weight alert button")
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}


#pragma mark Clearing


- (void)clearGoal:(BRTableButtonRow *)sender {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button") 
										 destructiveButtonTitle:NSLocalizedString(@"Clear Goal", @"Clear goal button") 
											  otherButtonTitles:nil];
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
