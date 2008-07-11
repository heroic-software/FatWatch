//
//  WeightFormatter.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "WeightFormatter.h"
#import "Database.h"


typedef enum {
	kWeightUnitPounds = 1,
	kWeightUnitKilograms = 2,
	kWeightUnitStones = 3,
} EWWeightUnit;

typedef enum {
	kEnergyUnitCalories = 1,
	kEnergyUnitKilojoules = 2
} EWEnergyUnit;


static const float kKilogramsPerPound = 0.45359237f;
static const float kCaloriesPerPound = 3500;
static const float kKilojoulesPerPound = 7716 / 0.45359237f;

static NSString *kWeightUnitKey = @"WeightUnit";
static NSString *kEnergyUnitKey = @"EnergyUnit";
static NSString *kScaleIncrementKey = @"ScaleIncrement";

@implementation WeightFormatter

+ (float)scaleIncrement {
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	float scaleIncrement = [defs floatForKey:kScaleIncrementKey];
	EWWeightUnit weightUnit = [defs integerForKey:kWeightUnitKey];
	
	if (weightUnit == kWeightUnitKilograms) {
		return scaleIncrement / kKilogramsPerPound;
	} else {
		return scaleIncrement;
	}
}


+ (NSArray *)weightUnitNames {
	NSString *pounds = NSLocalizedString(@"POUNDS", nil);
	NSString *kilograms = NSLocalizedString(@"KILOGRAMS", nil);
	NSString *stones = NSLocalizedString(@"STONES", nil);
	return [NSArray arrayWithObjects:pounds, kilograms, stones, nil];
}


+ (int)indexOfSelectedWeightUnit {
	EWWeightUnit weightUnit = [[NSUserDefaults standardUserDefaults] integerForKey:kWeightUnitKey];
	return weightUnit - 1;
}


+ (void)selectWeightUnitAtIndex:(int)index {
	EWWeightUnit weightUnit = index + 1;
	[[NSUserDefaults standardUserDefaults] setInteger:weightUnit forKey:kWeightUnitKey];
}


+ (NSArray *)energyUnitNames {
	NSString *calories = NSLocalizedString(@"CALORIES", nil);
	NSString *kilojoules = NSLocalizedString(@"KILOJOULES", nil);
	return [NSArray arrayWithObjects:calories, kilojoules, nil];
}


+ (int)indexOfSelectedEnergyUnit {
	EWEnergyUnit energyUnit = [[NSUserDefaults standardUserDefaults] integerForKey:kEnergyUnitKey];
	return energyUnit - 1;
}


+ (void)selectEnergyUnitAtIndex:(int)index {
	EWEnergyUnit energyUnit = index + 1;
	[[NSUserDefaults standardUserDefaults] setInteger:energyUnit forKey:kEnergyUnitKey];
}


+ (WeightFormatter *)sharedFormatter {
	static WeightFormatter *formatter = nil;
	
	if (formatter == nil) {
		formatter = [[WeightFormatter alloc] init];
	}
	
	return formatter;
}


+ (NSNumberFormatter *)exportNumberFormatter {
	EWWeightUnit weightUnit = [[NSUserDefaults standardUserDefaults] integerForKey:kWeightUnitKey];

	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	switch (weightUnit) {
		case kWeightUnitKilograms:
			[formatter setMultiplier:[NSNumber numberWithFloat:kKilogramsPerPound]];
			break;
	}
	return [formatter autorelease];
}


- (NSNumberFormatter *)newChangeFormatter {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[formatter setPositivePrefix:@"+"];
	[formatter setNegativePrefix:@"−"];
	[formatter setMinimumIntegerDigits:1];
	return formatter;
}


- (id)init {
	if ([super init]) {
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		EWWeightUnit weightUnit = [defs integerForKey:kWeightUnitKey];
		EWEnergyUnit energyUnit = [defs integerForKey:kEnergyUnitKey];
		float scaleIncrement = [defs floatForKey:kScaleIncrementKey];
		
		if (weightUnit == kWeightUnitStones) {
			if (scaleIncrement < 1) {
				stoneFormat = [NSLocalizedString(@"STONE_FORMAT_1", nil) retain];
			} else {
				stoneFormat = [NSLocalizedString(@"STONE_FORMAT_0", nil) retain];
			}
		} else {
			measuredFormatter = [[NSNumberFormatter alloc] init];
			if (scaleIncrement < 1) {
				[measuredFormatter setMinimumFractionDigits:1];
			} else {
				[measuredFormatter setMinimumFractionDigits:0];
			}
		}

		trendFormatter = [self newChangeFormatter];
		[trendFormatter setMinimumFractionDigits:1];
		[trendFormatter setMaximumFractionDigits:2];
		
		weightChangeFormatter = [self newChangeFormatter];
		[weightChangeFormatter setMinimumFractionDigits:2];
		[weightChangeFormatter setMaximumFractionDigits:2];

		NSString *changeSuffix = nil;
		NSString *weightSuffix = nil;
		
		switch (weightUnit) {
			case kWeightUnitPounds:
				weightSuffix = NSLocalizedString(@"POUNDS_UNIT_SUFFIX", nil);
				// fall
			case kWeightUnitStones:
				changeSuffix = NSLocalizedString(@"POUNDS_PER_WEEK_SUFFIX", nil);
				break;
			case kWeightUnitKilograms:
				weightSuffix = NSLocalizedString(@"KILOGRAMS_UNIT_SUFFIX", nil);
				changeSuffix = NSLocalizedString(@"KILOGRAMS_PER_WEEK_SUFFIX", nil);
				NSNumber *n = [NSNumber numberWithFloat:kKilogramsPerPound];
				[measuredFormatter setMultiplier:n];
				[trendFormatter setMultiplier:n];
				[weightChangeFormatter setMultiplier:n];
				break;
		}
		[measuredFormatter setPositiveSuffix:weightSuffix];
		[weightChangeFormatter setPositiveSuffix:changeSuffix];
		[weightChangeFormatter setNegativeSuffix:changeSuffix];

		energyFormatter = [self newChangeFormatter];
		[energyFormatter setMinimumFractionDigits:0];
		[energyFormatter setMaximumFractionDigits:0];
		switch (energyUnit) {
			case kEnergyUnitCalories:
				changeSuffix = NSLocalizedString(@"CALORIES_PER_DAY_SUFFIX", nil);
				[energyFormatter setMultiplier:[NSNumber numberWithFloat:kCaloriesPerPound]];
				break;
			case kEnergyUnitKilojoules:
				changeSuffix = NSLocalizedString(@"KILOJOULES_PER_DAY_SUFFIX", nil);
				[energyFormatter setMultiplier:[NSNumber numberWithFloat:kKilojoulesPerPound]];
				break;
		}
		[energyFormatter setPositiveSuffix:changeSuffix];
		[energyFormatter setNegativeSuffix:changeSuffix];
	}
	return self;
}


- (void)dealloc {
	[weightChangeFormatter release];
	[measuredFormatter release];
	[trendFormatter release];
	[stoneFormat release];
	[super dealloc];
}


- (NSString *)stringFromMeasuredWeight:(float)measuredWeight {
	if (measuredFormatter) {
		return [measuredFormatter stringFromNumber:[NSNumber numberWithFloat:measuredWeight]];
	} else {
		int stones = (measuredWeight / 14);
		float pounds = measuredWeight - (stones * 14.0f);
		return [NSString stringWithFormat:stoneFormat, stones, pounds];
	} 
}


- (NSString *)stringFromTrendDifference:(float)difference {
	return [trendFormatter stringFromNumber:[NSNumber numberWithFloat:difference]];
}


- (NSString *)weightPerWeekStringFromWeightChange:(float)weightPerWeek {
	return [weightChangeFormatter stringFromNumber:[NSNumber numberWithFloat:weightPerWeek]];
}


- (NSString *)energyPerDayStringFromWeightChange:(float)weightPerDay {
	return [energyFormatter stringFromNumber:[NSNumber numberWithFloat:weightPerDay]];
}

@end
