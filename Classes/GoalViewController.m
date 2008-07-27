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


- (void)initWarningSection {
	BRTableSection *section = [[BRTableSection alloc] init];
	section.footerTitle = NSLocalizedString(@"GOAL_NO_WEIGHT_WARNING", nil);
	[self addSection:section animated:NO];
	[section release];
}


- (void)initStartSection {
	BRTableSection *section = [[BRTableSection alloc] init];
	section.headerTitle = NSLocalizedString(@"START_SECTION_TITLE", nil);
	
	BRTableDatePickerRow *dateRow = [[BRTableDatePickerRow alloc] init];
	dateRow.title = NSLocalizedString(@"START_DATE", nil);
	dateRow.object = self;
	dateRow.key = @"startDate";
	dateRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[section addRow:dateRow animated:NO];
	[dateRow release];
	
	BRTableValueRow *weightRow = [[BRTableValueRow alloc] init];
	weightRow.title = NSLocalizedString(@"START_WEIGHT", nil);
	weightRow.object = self;
	weightRow.key = @"startWeight";
	weightRow.formatter = [WeightFormatters weightFormatter];
	[section addRow:weightRow animated:NO];
	[weightRow release];
	
	[self addSection:section animated:NO];
	[section release];
}


- (void)initGoalSection {
	BRTableSection *goalSection = [[BRTableSection alloc] init];
	goalSection.headerTitle = NSLocalizedString(@"GOAL_SECTION_TITLE", nil);
	
	BRTableDatePickerRow *dateRow = [[BRTableDatePickerRow alloc] init];
	dateRow.title = NSLocalizedString(@"GOAL_DATE", nil);
	dateRow.object = self;
	dateRow.key = @"endDate";
	dateRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[goalSection addRow:dateRow animated:NO];
	[dateRow release];
	
	BRTableNumberPickerRow *weightRow = [[BRTableNumberPickerRow alloc] init];
	weightRow.title = NSLocalizedString(@"GOAL_WEIGHT", nil);
	weightRow.object = self;
	weightRow.key = @"goalWeight";
	weightRow.formatter = [WeightFormatters weightFormatter];
	weightRow.increment = [WeightFormatters scaleIncrement];
	weightRow.minimumValue = 0;
	weightRow.maximumValue = 500;
	weightRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[goalSection addRow:weightRow animated:NO];
	[weightRow release];
	
	[self addSection:goalSection animated:NO];
	[goalSection release];
}


- (void)initPlanSection {
	BRTableSection *planSection = [[BRTableSection alloc] init];
	planSection.headerTitle = NSLocalizedString(@"PLAN_SECTION_TITLE", nil);
	
	BRTableNumberPickerRow *energyRow = [[BRTableNumberPickerRow alloc] init];
	energyRow.title = NSLocalizedString(@"ENERGY_CHANGE_TITLE", nil);
	energyRow.object = self;
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
	weightRow.object = self;
	weightRow.key = @"weightChangePerDay";
	weightRow.formatter = [WeightFormatters weightChangePerWeekFormatter];
	weightRow.increment = [WeightFormatters weightChangePerWeekIncrement];
	weightRow.minimumValue = -1000 * weightRow.increment;
	weightRow.maximumValue = 1000 * weightRow.increment;
	weightRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[planSection addRow:weightRow animated:NO];
	[weightRow release];
	
	[self addSection:planSection animated:NO];
	[planSection release];
}


- (id)init {
	if ([super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"GOAL_VIEW_TITLE", nil);
		self.tabBarItem.image = [UIImage imageNamed:@"TabIconGoal.png"];
		[self initWarningSection];
	}
	return self;
}


- (void)computeEndDate {
	if (isComputing) return;
	isComputing = YES;
	
	float weightChange = (self.goalWeight - self.startWeight);
	
	// make sure sign of weightChange and weightChangePerDay match
	if (weightChange > 0 && weightChangePerDay < 0) {
		self.weightChangePerDay = -self.weightChangePerDay;
	} else if (weightChange < 0 && weightChangePerDay > 0) {
		self.weightChangePerDay = -self.weightChangePerDay;
	}
	
	NSTimeInterval seconds = weightChange / weightChangePerDay * 86400;
	self.endDate = [self.startDate addTimeInterval:seconds];
	isComputing = NO;
}


- (void)computeWeightChangePerDay {
	if (isComputing) return;
	isComputing = YES;
	float weight = self.goalWeight - self.startWeight;
	NSTimeInterval seconds = [self.endDate timeIntervalSinceDate:self.startDate];
	self.weightChangePerDay = (weight / (seconds / 86400.0));
	isComputing = NO;
}


- (void)loadGoals {
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	
	isComputing = YES;
	id start = [defs objectForKey:@"GoalStartDate"];
	if (start) {
		self.startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[start doubleValue]];
		self.goalWeight = [defs floatForKey:@"GoalWeight"];
		self.weightChangePerDay = [defs floatForKey:@"GoalWeightChangePerDay"];
	} else {
		self.startDate = [NSDate date];
		self.goalWeight = self.startWeight - [WeightFormatters scaleIncrement];
		self.weightChangePerDay = [WeightFormatters defaultWeightChange];
	}
	isComputing = NO;
	[self computeEndDate];
}


#pragma mark Properties


- (NSDate *)startDate {
	return EWDateFromMonthDay(startMonthDay);
}


- (void)setStartDate:(NSDate *)date {
	[self willChangeValueForKey:@"startDate"];
	startMonthDay = EWMonthDayFromDate(date);
	[[NSUserDefaults standardUserDefaults] setDouble:[date timeIntervalSinceReferenceDate] forKey:@"GoalStartDate"];
	[self didChangeValueForKey:@"startDate"];

	if ([self numberOfSections] > 1) {
		BRTableDatePickerRow *endRow = (BRTableDatePickerRow *)[[self sectionAtIndex:1] rowAtIndex:0];
		endRow.minimumDate = [date addTimeInterval:86400];
	}
	
	MonthData *md = [[Database sharedDatabase] dataForMonth:EWMonthDayGetMonth(startMonthDay)];
	float w = [md trendWeightOnDay:EWMonthDayGetDay(startMonthDay)];
	if (w == 0) {
		w = [md inputTrendOnDay:EWMonthDayGetDay(startMonthDay)];
	}
	
	self.startWeight = w;
	
	if (w > 0) {
		[self computeEndDate];
	}
}


@synthesize startWeight;


- (NSDate *)endDate {
	return EWDateFromMonthDay(endMonthDay);
}


- (void)setEndDate:(NSDate *)date {
	[self willChangeValueForKey:@"endDate"];
	endMonthDay = EWMonthDayFromDate(date);
	[self didChangeValueForKey:@"endDate"];
	[self computeWeightChangePerDay];
}


@synthesize goalWeight;


- (void)setGoalWeight:(float)weight {
	[self willChangeValueForKey:@"goalWeight"];
	goalWeight = weight;
	[[NSUserDefaults standardUserDefaults] setFloat:goalWeight forKey:@"GoalWeight"];
	[self didChangeValueForKey:@"goalWeight"];
	[self computeEndDate];
}


@synthesize weightChangePerDay;


- (void)setWeightChangePerDay:(float)weightChange {
	[self willChangeValueForKey:@"weightChangePerDay"];
	weightChangePerDay = weightChange;
	[[NSUserDefaults standardUserDefaults] setFloat:weightChangePerDay forKey:@"GoalWeightChangePerDay"];
	[self didChangeValueForKey:@"weightChangePerDay"];
	[self computeEndDate];
}


#pragma mark View Crap


- (void)viewWillAppear:(BOOL)animated {
	Database *db = [Database sharedDatabase];
	
	if ([db weightCount] == 0) {
		if ([self numberOfSections] > 1) {
			[self removeAllSections];
			[self initWarningSection];
			[self.tableView reloadData];
		}
	} else {
		if ([self numberOfSections] < 3) {
			[self removeAllSections];
			[self initStartSection];
			[self initGoalSection];
			[self initPlanSection];
			[self.tableView reloadData];
			[self loadGoals];
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


- (void)presentViewController:(UIViewController *)controller forRow:(BRTableRow *)row {
	controller.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:controller animated:YES];
}


- (void)dismissViewController:(UIViewController *)controller forRow:(BRTableRow *)row {
	[self.navigationController popViewControllerAnimated:YES];
}


@end
