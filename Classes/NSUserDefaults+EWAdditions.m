//
//  NSUserDefaults+EWAdditions.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/20/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "NSUserDefaults+EWAdditions.h"


const float kKilogramsPerPound = 0.45359237f;
const float kCaloriesPerPound = 3500;
const float kKilojoulesPerPound = 7716 / 0.45359237f;


static NSString * const kWeightUnitKey = @"WeightUnit";
static NSString * const kEnergyUnitKey = @"EnergyUnit";
static NSString * const kScaleIncrementKey = @"ScaleIncrement";
static NSString * const kBMIEnabledKey = @"BMIEnabled";
static NSString * const kBMIHeightKey = @"BMIHeight";


@implementation NSUserDefaults (EWAdditions)


#pragma mark Weight Unit


+ (NSArray *)weightUnitsForDisplay {
	return [NSArray arrayWithObjects:
			[NSNumber numberWithInt:EWWeightUnitPounds],
			[NSNumber numberWithInt:EWWeightUnitKilograms],
			[NSNumber numberWithInt:EWWeightUnitStones],
			nil];
}


+ (NSArray *)weightUnitsForExport {
	return [NSArray arrayWithObjects:
			[NSNumber numberWithInt:EWWeightUnitPounds],
			[NSNumber numberWithInt:EWWeightUnitKilograms],
			[NSNumber numberWithInt:EWWeightUnitGrams],
			nil];
}


+ (NSString *)nameForWeightUnit:(NSNumber *)weightUnitID {
	switch ([weightUnitID intValue]) {
		case EWWeightUnitPounds: 
			return NSLocalizedString(@"Pounds (lb)", @"pound unit name");
		case EWWeightUnitKilograms:
			return NSLocalizedString(@"Kilograms (kg)", @"kilogram unit name");
		case EWWeightUnitStones:
			return NSLocalizedString(@"Stones (st lb)", @"stone unit name");
		case EWWeightUnitGrams:
			return NSLocalizedString(@"Grams (g)", @"gram unit name");
		default:
			return nil;
	}
}


- (void)setWeightUnit:(NSNumber *)weightUnit {
	[self setInteger:[weightUnit intValue] forKey:kWeightUnitKey];
}


- (EWWeightUnit)weightUnit {
	return [self integerForKey:kWeightUnitKey];
}


#pragma mark Energy Unit


+ (NSArray *)energyUnits {
	return [NSArray arrayWithObjects:
			[NSNumber numberWithInt:EWEnergyUnitCalories],
			[NSNumber numberWithInt:EWEnergyUnitKilojoules],
			nil];
}


+ (NSString *)nameForEnergyUnit:(NSNumber *)energyUnit {
	switch ([energyUnit intValue]) {
		case EWEnergyUnitCalories:
			return NSLocalizedString(@"Calories (cal)", @"Calorie unit name");
		case EWEnergyUnitKilojoules:
			return NSLocalizedString(@"Kilojoules (kJ)", @"Kilojoule unit name");
		default:
			return nil;
	}
}


- (void)setEnergyUnit:(NSNumber *)energyUnit {
	[self setInteger:[energyUnit intValue] forKey:kEnergyUnitKey];
}


- (EWEnergyUnit)energyUnit {
	return [self integerForKey:kEnergyUnitKey];
}


#pragma mark Scale Increment


+ (NSArray *)scaleIncrements {
	return [NSArray arrayWithObjects:
			[NSNumber numberWithFloat:0.1f],
			[NSNumber numberWithFloat:0.2f],
			[NSNumber numberWithFloat:0.5f],
			[NSNumber numberWithFloat:1.0f],
			nil];
}


+ (NSString *)nameForScaleIncrement:(NSNumber *)number {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[formatter setMinimumFractionDigits:1];
	NSString *name = [formatter stringFromNumber:number];
	[formatter release];
	return name;
}


- (void)setScaleIncrement:(NSNumber *)number {
	[self setFloat:[number floatValue] forKey:kScaleIncrementKey];
}


- (float)scaleIncrement {
	return [self floatForKey:kScaleIncrementKey];
}


#pragma mark BMI & Goal


- (BOOL)isBMIEnabled {
	return [self boolForKey:kBMIEnabledKey];
}


- (void)setBMIEnabled:(BOOL)flag {
	[self setBool:flag forKey:kBMIEnabledKey];
}


- (void)setHeight:(float)meters {
	[self setFloat:meters forKey:kBMIHeightKey];
}


- (float)height {
	return [self floatForKey:kBMIHeightKey];
}


#pragma mark Other Stuff


- (NSUInteger)scaleIncrementFractionDigits {
	return ceilf(-log10f([self scaleIncrement]));
}


- (float)convertIncrement:(float)incrementLbs {
	switch ([self weightUnit]) {
		case EWWeightUnitPounds:
		case EWWeightUnitStones:
			return incrementLbs;
		case EWWeightUnitKilograms:
			return incrementLbs / kKilogramsPerPound;
		default:
			return 0;
	}
}


- (float)weightIncrement {
	return [self convertIncrement:[self scaleIncrement]];
}


- (float)weightWholeIncrement {
	return [self convertIncrement:1.0f];
}


- (float)defaultWeightChange {
	switch ([self weightUnit]) {
		case EWWeightUnitPounds:
		case EWWeightUnitStones:
			return -(1.0 / 7.0); // 1 lb/wk
		case EWWeightUnitKilograms:
			return -(0.5 / 7.0) / kKilogramsPerPound; // 0.5 kg/wk
		default:
			return 0;
	}
}


- (float)heightIncrement {
	switch ([self weightUnit]) {
		case EWWeightUnitPounds:
		case EWWeightUnitStones:
			return 0.0254;
		case EWWeightUnitKilograms:
			return 0.01;
		default:
			return 0;
	}
}


- (BOOL)isNumericFlag:(int)which {
	return [self boolForKey:@"EnableLadder"] ? (which == 3) : NO;
}


@end
