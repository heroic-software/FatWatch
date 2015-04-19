/*
 * EWWeightChangeFormatter.m
 * Created by Benjamin Ragheb on 12/20/09.
 * Copyright 2015 Heroic Software Inc
 *
 * This file is part of FatWatch.
 *
 * FatWatch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FatWatch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "EWWeightChangeFormatter.h"
#import "NSUserDefaults+EWAdditions.h"


static NSString * const kShortSpace = @"\xe2\x80\x88";
static NSString * const kMinusSign = @"\xe2\x88\x92";


@implementation EWWeightChangeFormatter


+ (float)energyChangePerDayIncrement {
	switch ([[NSUserDefaults standardUserDefaults] energyUnit]) {
		case EWEnergyUnitCalories:
			return 10 / kCaloriesPerPound; // 10 cal/day
		case EWEnergyUnitKilojoules:
			return 50 / kKilojoulesPerPound; // 40 kJ/day
		default:
			return 0;
	}
}


+ (float)weightChangePerWeekIncrement {
	switch ([[NSUserDefaults standardUserDefaults] weightUnit]) {
		case EWWeightUnitPounds:
		case EWWeightUnitStones:
			return 0.05f / 7; // 0.05 lbs/week / 7 days/week
		case EWWeightUnitKilograms:
			return 0.01f / kKilogramsPerPound / 7; // 0.01 kgs/week / 7 day/week / X kg/lb
		default:
			return 0;
	}
}


- (void)initStyleEnergyPerDay {
	switch ([[NSUserDefaults standardUserDefaults] energyUnit]) {
		case EWEnergyUnitCalories:
			[self setPositiveSuffix:[kShortSpace stringByAppendingString:NSLocalizedString(@"cal/day", @"calories per day")]];
			[self setMultiplier:@(kCaloriesPerPound)];
			break;
		case EWEnergyUnitKilojoules:
			[self setPositiveSuffix:[kShortSpace stringByAppendingString:NSLocalizedString(@"kJ/day", @"kilojoules per day")]];
			[self setMultiplier:@(kKilojoulesPerPound)];
			break;
	}
	[self setNegativeSuffix:[self positiveSuffix]];
	[self setMaximumFractionDigits:0];
}


- (void)initStyleWeightPerWeek {
	switch ([[NSUserDefaults standardUserDefaults] weightUnit]) {
		case EWWeightUnitKilograms:
			[self setPositiveSuffix:[kShortSpace stringByAppendingString:NSLocalizedString(@"kgs/week", @"kilograms per week")]];
			[self setMultiplier:@(7.0f * kKilogramsPerPound)];
			break;
		case EWWeightUnitPounds:
		case EWWeightUnitStones:
			[self setPositiveSuffix:[kShortSpace stringByAppendingString:NSLocalizedString(@"lbs/week", @"pounds per week")]];
			[self setMultiplier:@7.0f];
			break;
		default:
			NSAssert(NO, @"unexpected weight unit");
	}
	[self setNegativeSuffix:[self positiveSuffix]];
	[self setMinimumFractionDigits:2];
	[self setMaximumFractionDigits:2];
}


- (id)initWithStyle:(EWWeightChangeFormatterStyle)style {
	if ((self = [super init])) {
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
