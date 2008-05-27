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
	return [NSArray arrayWithObjects:@"Pounds", @"Kilograms", @"Stones", nil];
}


+ (void)setWeightUnit:(int)index {
	EWWeightUnit weightUnit = index + 1;
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	
	[defs setInteger:weightUnit forKey:kWeightUnitKey];
	if ([defs integerForKey:kEnergyUnitKey] == 0) {
		switch (weightUnit) {
			case kWeightUnitStones:
			case kWeightUnitPounds:
				[defs setInteger:kEnergyUnitCalories forKey:kEnergyUnitKey]; 
				break;
			case kWeightUnitKilograms:
				[defs setInteger:kEnergyUnitKilojoules forKey:kEnergyUnitKey]; 
				break;
		}
	}
}


+ (WeightFormatter *)sharedFormatter {
	static WeightFormatter *formatter = nil;
	
	if (formatter == nil) {
		formatter = [[WeightFormatter alloc] init];
	}
	
	return formatter;
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
				stoneFormat = [@"%d st %0.1f" retain];
			} else {
				stoneFormat = [@"%d st %0.0f" retain];
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
		
		switch (weightUnit) {
			case kWeightUnitPounds:
			case kWeightUnitStones:
				[weightChangeFormatter setPositiveSuffix:@" lbs/week"];
				break;
			case kWeightUnitKilograms:
				[weightChangeFormatter setPositiveSuffix:@" kgs/week"];
				NSNumber *n = [NSNumber numberWithFloat:kKilogramsPerPound];
				[measuredFormatter setMultiplier:n];
				[trendFormatter setMultiplier:n];
				[weightChangeFormatter setMultiplier:n];
				break;
		}
		[weightChangeFormatter setNegativeSuffix:[weightChangeFormatter positiveSuffix]];

		energyFormatter = [self newChangeFormatter];
		[energyFormatter setMinimumFractionDigits:2];
		[energyFormatter setMaximumFractionDigits:2];
		switch (energyUnit) {
			case kEnergyUnitCalories:
				[energyFormatter setPositiveSuffix:@" cal/day"];
				[energyFormatter setMultiplier:[NSNumber numberWithFloat:kCaloriesPerPound]];
				break;
			case kEnergyUnitKilojoules:
				[energyFormatter setPositiveSuffix:@" kJ/day"];
				[energyFormatter setMultiplier:[NSNumber numberWithFloat:kKilojoulesPerPound]];
				break;
		}
		[energyFormatter setNegativeSuffix:[energyFormatter positiveSuffix]];
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
