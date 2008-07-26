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


- (void)initStartSection {
	BRTableSection *section = [[BRTableSection alloc] init];
	section.headerTitle = @"Start";
	
	BRTableDatePickerRow *dateRow = [[BRTableDatePickerRow alloc] init];
	dateRow.object = self;
	dateRow.key = @"startDate";
	// min date
	[section addRow:dateRow animated:NO];
	[dateRow release];
	
	BRTableValueRow *weightRow = [[BRTableValueRow alloc] init];
	weightRow.object = self;
	weightRow.key = @"startWeight";
	[section addRow:weightRow animated:NO];
	[weightRow release];
	
	[self addSection:section animated:NO];
	[section release];
}


- (void)initGoalSection {
	BRTableSection *goalSection = [[BRTableSection alloc] init];
	goalSection.headerTitle = @"Goal";
	
	BRTableDatePickerRow *dateRow = [[BRTableDatePickerRow alloc] init];
	dateRow.object = self;
	dateRow.key = @"endDate";
	[goalSection addRow:dateRow animated:NO];
	[dateRow release];
	
	BRTableValueRow *weightRow = [[BRTableValueRow alloc] init];
	weightRow.object = self;
	weightRow.key = @"goalWeight";
	[goalSection addRow:weightRow animated:NO];
	[weightRow release];
	
	[self addSection:goalSection animated:NO];
	[goalSection release];
}


- (void)initPlanSection {
	BRTableSection *planSection = [[BRTableSection alloc] init];
	planSection.headerTitle = @"Plan";
	
	BRTableValueRow *energyRow = [[BRTableValueRow alloc] init];
	energyRow.object = self;
	energyRow.key = @"planEnergyPerDay";
	[planSection addRow:energyRow animated:NO];
	[energyRow release];
	
	BRTableValueRow *weightRow = [[BRTableValueRow alloc] init];
	weightRow.object = self;
	weightRow.key = @"planWeightPerWeek";
	[planSection addRow:weightRow animated:NO];
	[weightRow release];
	
	[self addSection:planSection animated:NO];
	[planSection release];
}


- (id)init {
	if ([super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"GOAL_VIEW_TITLE", nil);

		weightPerDay = -1.0 / 0.7;
		self.startDate = [NSDate date];
		
		[self initStartSection];
		[self initGoalSection];
		[self initPlanSection];
	}
	return self;
}


- (void)setWeightPerDay:(float)value {
	[self willChangeValueForKey:@"planEnergyPerDay"];
	[self willChangeValueForKey:@"planWeightPerWeek"];
	weightPerDay = value;
	[self didChangeValueForKey:@"planWeightPerWeek"];
	[self didChangeValueForKey:@"planEnergyPerDay"];
}


- (void)computeEndDate {
	if (isComputing) return;
	isComputing = YES;
	NSTimeInterval seconds = (self.goalWeight - self.startWeight) / weightPerDay * 86400;
	self.endDate = [self.startDate addTimeInterval:seconds];
	isComputing = NO;
}


- (void)computeWeightPerDay {
	if (isComputing) return;
	isComputing = YES;
	float weight = self.goalWeight - self.startWeight;
	NSTimeInterval seconds = [self.endDate timeIntervalSinceDate:self.startDate];
	[self setWeightPerDay:(weight / (seconds / 86400.0))];
	isComputing = NO;
}


#pragma mark Properties


- (NSDate *)startDate {
	return EWDateFromMonthDay(startMonthDay);
}


- (void)setStartDate:(NSDate *)date {
	[self willChangeValueForKey:@"startDate"];
	startMonthDay = EWMonthDayFromDate(date);
	[self didChangeValueForKey:@"startDate"];

	MonthData *md = [[Database sharedDatabase] dataForMonth:EWMonthDayGetMonth(startMonthDay)];
	float w = [md trendWeightOnDay:EWMonthDayGetDay(startMonthDay)];
	if (w == 0) {
		w = [md inputTrendOnDay:EWMonthDayGetDay(startMonthDay)];
	}
	self.startWeight = w;
	
	if (self.goalWeight == 0) {
		self.goalWeight = self.startWeight - 10;
	} else {
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
	[self computeWeightPerDay];
}


@synthesize goalWeight;


- (void)setGoalWeight:(float)weight {
	[self willChangeValueForKey:@"goalWeight"];
	goalWeight = weight;
	[self didChangeValueForKey:@"goalWeight"];
	[self computeEndDate];
}


- (float)planEnergyPerDay {
	return weightPerDay * 3500.0;
}


- (void)setPlanEnergyPerDay:(float)energyPerDay {
	[self setWeightPerDay:(energyPerDay / 3500.0)];
	[self computeEndDate];
}


- (float)planWeightPerWeek {
	return weightPerDay * 7.0;
}


- (void)setPlanWeightPerWeek:(float)weightPerWeek {
	[self setWeightPerDay:(weightPerWeek / 7.0)];
	[self computeEndDate];
}


#pragma mark others


@end
