//
//  EWWeightChangeFormatter.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/20/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "EWWeightChangeFormatter.h"
#import "NSUserDefaults+EWAdditions.h"


static NSString * const kShortSpace = @"\xe2\x80\x88";
static NSString * const kMinusSign = @"\xe2\x88\x92";


@implementation EWWeightChangeFormatter


+ (float)energyChangePerDayIncrement {
	switch ([[NSUserDefaults standardUserDefaults] energyUnit]) {
		case EWEnergyUnitCalories:
			return 10.0 / kCaloriesPerPound; // 10 cal/day
		case EWEnergyUnitKilojoules:
			return 50.0 / kKilojoulesPerPound; // 40 kJ/day
		default:
			return 0;
	}
}


+ (float)weightChangePerWeekIncrement {
	switch ([[NSUserDefaults standardUserDefaults] weightUnit]) {
		case EWWeightUnitPounds:
		case EWWeightUnitStones:
			return 0.05 / 7.0; // 0.05 lbs/week / 7 days/week
		case EWWeightUnitKilograms:
			return 0.01 / kKilogramsPerPound / 7.0; // 0.01 kgs/week / 7 day/week / X kg/lb
		default:
			return 0;
	}
}


- (void)initStyleEnergyPerDay {
	switch ([[NSUserDefaults standardUserDefaults] energyUnit]) {
		case EWEnergyUnitCalories:
			[self setPositiveSuffix:[kShortSpace stringByAppendingString:NSLocalizedString(@"cal/day", @"calories per day")]];
			[self setMultiplier:[NSNumber numberWithFloat:kCaloriesPerPound]];
			break;
		case EWEnergyUnitKilojoules:
			[self setPositiveSuffix:[kShortSpace stringByAppendingString:NSLocalizedString(@"kJ/day", @"kilojoules per day")]];
			[self setMultiplier:[NSNumber numberWithFloat:kKilojoulesPerPound]];
			break;
	}
	[self setNegativeSuffix:[self positiveSuffix]];
	[self setMaximumFractionDigits:0];
}


- (void)initStyleWeightPerWeek {
	switch ([[NSUserDefaults standardUserDefaults] weightUnit]) {
		case EWWeightUnitKilograms:
			[self setPositiveSuffix:[kShortSpace stringByAppendingString:NSLocalizedString(@"kgs/week", @"kilograms per week")]];
			[self setMultiplier:[NSNumber numberWithFloat:7.0f * kKilogramsPerPound]];
			break;
		case EWWeightUnitPounds:
		case EWWeightUnitStones:
			[self setPositiveSuffix:[kShortSpace stringByAppendingString:NSLocalizedString(@"lbs/week", @"pounds per week")]];
			[self setMultiplier:[NSNumber numberWithFloat:7.0f]];
			break;
	}
	[self setNegativeSuffix:[self positiveSuffix]];
	[self setMinimumFractionDigits:2];
	[self setMaximumFractionDigits:2];
}


- (id)initWithStyle:(EWWeightChangeFormatterStyle)style {
	if (self = [super init]) {
		[self setNumberStyle:NSNumberFormatterDecimalStyle];
		switch (style) {
			case EWWeightChangeFormatterStyleEnergyPerDay:
				[self initStyleEnergyPerDay];
				break;
			case EWWeightChangeFormatterStyleWeightPerWeek:
				[self initStyleWeightPerWeek];
				break;
		}
		[self setPositivePrefix:@"+"];
		[self setNegativePrefix:kMinusSign];
	}
	return self;
}


@end
