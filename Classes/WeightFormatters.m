//
//  WeightFormatters.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "WeightFormatters.h"


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


@interface StoneWeightFormatter : NSFormatter {
	NSString *formatString;
}
@end


@implementation WeightFormatters


#pragma mark Setting Defaults


+ (NSArray *)weightUnitNames {
	NSString *pounds = NSLocalizedString(@"POUNDS", nil);
	NSString *kilograms = NSLocalizedString(@"KILOGRAMS", nil);
	NSString *stones = NSLocalizedString(@"STONES", nil);
	return [NSArray arrayWithObjects:pounds, kilograms, stones, nil];
}


+ (void)selectWeightUnitAtIndex:(NSUInteger)index {
	EWWeightUnit weightUnit = index + 1;
	[[NSUserDefaults standardUserDefaults] setInteger:weightUnit forKey:kWeightUnitKey];
}


+ (NSArray *)energyUnitNames {
	NSString *calories = NSLocalizedString(@"CALORIES", nil);
	NSString *kilojoules = NSLocalizedString(@"KILOJOULES", nil);
	return [NSArray arrayWithObjects:calories, kilojoules, nil];
}


+ (void)selectEnergyUnitAtIndex:(NSUInteger)index {
	EWEnergyUnit energyUnit = index + 1;
	[[NSUserDefaults standardUserDefaults] setInteger:energyUnit forKey:kEnergyUnitKey];
}


+ (NSArray *)scaleIncrementNames {
	return [NSArray arrayWithObjects:@"0.1", @"0.5", @"1.0", nil];
}


+ (void)selectScaleIncrementAtIndex:(NSUInteger)index {
	float increment = [[[self scaleIncrementNames] objectAtIndex:index] floatValue];
	[[NSUserDefaults standardUserDefaults] setFloat:increment forKey:kScaleIncrementKey];
}


#pragma mark Retrieving Defaults


+ (float)rawScaleIncrement {
	return [[NSUserDefaults standardUserDefaults] floatForKey:kScaleIncrementKey];
}


+ (float)scaleIncrement {
	static float increment = 0;
	
	if (increment == 0) {
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		float incrementLbs = [defs floatForKey:kScaleIncrementKey];
		EWWeightUnit unit = [defs integerForKey:kWeightUnitKey];
		if (unit == kWeightUnitKilograms) {
			increment = incrementLbs / kKilogramsPerPound;
		} else {
			increment = incrementLbs;
		}
	}
	
	return increment;
}


+ (float)defaultWeightChange {
	EWWeightUnit unit = [[NSUserDefaults standardUserDefaults] integerForKey:kWeightUnitKey];
	if (unit == kWeightUnitKilograms) {
		return -(0.5 / 7.0) / kKilogramsPerPound; // 0.5 kg/wk
	} else {
		return -1.0 / 7.0; // 1 lb a week
	}
}


+ (NSFormatter *)weightFormatter {
	static NSFormatter *formatter = nil;
	
	if (formatter == nil) {
		EWWeightUnit unit = [[NSUserDefaults standardUserDefaults] integerForKey:kWeightUnitKey];
		if (unit == kWeightUnitStones) {
			formatter = [[StoneWeightFormatter alloc] init];
		} else {
			NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
			[nf setMinimumFractionDigits:([WeightFormatters rawScaleIncrement] < 1.0) ? 1 : 0];
			if (unit == kWeightUnitPounds) {
				[nf setPositiveSuffix:NSLocalizedString(@"POUNDS_UNIT_SUFFIX", nil)];
			} else {
				[nf setPositiveSuffix:NSLocalizedString(@"KILOGRAMS_UNIT_SUFFIX", nil)];
				[nf setMultiplier:[NSNumber numberWithFloat:kKilogramsPerPound]];
			}
			formatter = nf;
		}
	}
	
	return formatter;
}


+ (NSString *)stringForWeight:(float)weightLbs {
	return [[self weightFormatter] stringForObjectValue:[NSNumber numberWithFloat:weightLbs]];
}


+ (NSFormatter *)weightChangeFormatter {
	static NSNumberFormatter *formatter;
	
	if (formatter == nil) {
		formatter = [[NSNumberFormatter alloc] init];
		[formatter setPositiveFormat:NSLocalizedString(@"TREND_FORMAT", nil)];
		EWWeightUnit unit = [[NSUserDefaults standardUserDefaults] integerForKey:kWeightUnitKey];
		if (unit == kWeightUnitKilograms) {
			[formatter setMultiplier:[NSNumber numberWithFloat:kKilogramsPerPound]];
		}
	}
	
	return formatter;
}


+ (NSString *)stringForWeightChange:(float)deltaLbs {
	return [[self weightChangeFormatter] stringForObjectValue:[NSNumber numberWithFloat:deltaLbs]];
}


+ (NSFormatter *)energyChangePerDayFormatter {
	static NSNumberFormatter *formatter;
	
	if (formatter == nil) {
		formatter = [[NSNumberFormatter alloc] init];
		EWEnergyUnit unit = [[NSUserDefaults standardUserDefaults] integerForKey:kEnergyUnitKey];
		if (unit == kEnergyUnitCalories) {
			[formatter setPositiveFormat:NSLocalizedString(@"CALORIES_PER_DAY_FORMAT", nil)];
			[formatter setMultiplier:[NSNumber numberWithFloat:kCaloriesPerPound]];
		} else {
			[formatter setPositiveFormat:NSLocalizedString(@"KILOJOULES_PER_DAY_FORMAT", nil)];
			[formatter setMultiplier:[NSNumber numberWithFloat:kKilojoulesPerPound]];
		}
	}
	
	return formatter;
}


+ (NSString *)energyStringForWeightPerDay:(float)lbsPerDay {
	return [[self energyChangePerDayFormatter] stringForObjectValue:[NSNumber numberWithFloat:lbsPerDay]];
}


+ (float)energyChangePerDayIncrement {
	EWEnergyUnit unit = [[NSUserDefaults standardUserDefaults] integerForKey:kEnergyUnitKey];
	if (unit == kEnergyUnitCalories) {
		return 10.0 / kCaloriesPerPound; // 10 cal/day
	} else {
		return 50.0 / kKilojoulesPerPound; // 40 kJ/day
	}
}


+ (NSFormatter *)weightChangePerWeekFormatter {
	static NSNumberFormatter *formatter;
	
	if (formatter == nil) {
		formatter = [[NSNumberFormatter alloc] init];
		EWWeightUnit unit = [[NSUserDefaults standardUserDefaults] integerForKey:kWeightUnitKey];
		if (unit == kWeightUnitKilograms) {
			[formatter setPositiveFormat:NSLocalizedString(@"KILOGRAMS_PER_WEEK_FORMAT", nil)];
			[formatter setMultiplier:[NSNumber numberWithFloat:7.0f * kKilogramsPerPound]];
		} else {
			[formatter setPositiveFormat:NSLocalizedString(@"POUNDS_PER_WEEK_FORMAT", nil)];
			[formatter setMultiplier:[NSNumber numberWithFloat:7.0f]];
		}
	}
	
	return formatter;
}


+ (NSString *)weightStringForWeightPerDay:(float)lbsPerDay {
	return [[self weightChangePerWeekFormatter] stringForObjectValue:[NSNumber numberWithFloat:lbsPerDay]];
}


+ (float)weightChangePerWeekIncrement {
	EWWeightUnit unit = [[NSUserDefaults standardUserDefaults] integerForKey:kWeightUnitKey];
	if (unit == kWeightUnitKilograms) {
		return 0.01 / kKilogramsPerPound / 7.0; // 0.01 kgs/week / 7 day/week / X kg/lb
	} else {
		return 0.05 / 7.0; // 0.05 lbs/week / 7 days/week
	}
}


+ (NSNumberFormatter *)exportWeightFormatter {
	EWWeightUnit weightUnit = [[NSUserDefaults standardUserDefaults] integerForKey:kWeightUnitKey];
	
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	switch (weightUnit) {
		case kWeightUnitKilograms:
			[formatter setMultiplier:[NSNumber numberWithFloat:kKilogramsPerPound]];
			break;
	}
	return [formatter autorelease];
}


@end


@implementation StoneWeightFormatter

- (id)init {
	if ([super init]) {
		if ([WeightFormatters rawScaleIncrement] < 1.0) {
			formatString = [NSLocalizedString(@"STONE_FORMAT_1", nil) retain];
		} else {
			formatString = [NSLocalizedString(@"STONE_FORMAT_0", nil) retain];
		}
	}
	return self;
}


- (NSString *)stringForObjectValue:(id)anObject {
	float weightLbs = [anObject floatValue];
	int stones = weightLbs / 14;
	float pounds = weightLbs - (14.0f * stones);
	return [NSString stringWithFormat:formatString, stones, pounds];
}
	

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
	NSNumberFormatter *nf = [[[NSNumberFormatter alloc] init] autorelease];
	return [nf getObjectValue:anObject forString:string errorDescription:error];
}

@end
