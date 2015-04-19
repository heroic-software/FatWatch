/*
 * NSUserDefaults+EWAdditions.m
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

#import "NSUserDefaults+EWAdditions.h"


const float kKilogramsPerPound = 0.45359237f;
const float kCaloriesPerPound = 3500;
const float kKilojoulesPerCalorie = 4.184f;
const float kKilojoulesPerPound = 4.184f * 3500;


NSString * const EWBMIStatusDidChangeNotification = @"BMIStatusDidChange";


static NSString * const kWeightUnitKey = @"WeightUnit";
static NSString * const kEnergyUnitKey = @"EnergyUnit";
static NSString * const kScaleIncrementKey = @"ScaleIncrement";
static NSString * const kBMIEnabledKey = @"BMIEnabled";
static NSString * const kBMIHeightKey = @"BMIHeight";


@implementation NSUserDefaults (EWAdditions)


- (void)registerDefaultsNamed:(NSString *)name {
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
	NSAssert1(path != nil, @"registration domain defaults plist '%@' is missing", name);
	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
	[self registerDefaults:dict];
}


#pragma mark Weight Unit


+ (NSArray *)weightUnitsForDisplay {
	return @[@(EWWeightUnitPounds),
			@(EWWeightUnitKilograms),
			@(EWWeightUnitStones)];
}


+ (NSArray *)weightUnitsForExport {
	return @[@(EWWeightUnitPounds),
			@(EWWeightUnitKilograms),
			@(EWWeightUnitGrams)];
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
	return @[@(EWEnergyUnitCalories),
			@(EWEnergyUnitKilojoules)];
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
	return @[@"1.00", @"0.50", @"0.20", @"0.10", @"0.05"];
}


+ (NSString *)nameForScaleIncrement:(id)number {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[formatter setMinimumFractionDigits:1];
	return [formatter stringFromNumber:@([number floatValue])];
}


- (void)setScaleIncrement:(id)number {
	[self setObject:number forKey:kScaleIncrementKey];
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
	[[NSNotificationCenter defaultCenter] postNotificationName:EWBMIStatusDidChangeNotification object:self];
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
			return -(1.0f / 7.0f); // 1 lb/wk
		case EWWeightUnitKilograms:
			return -(0.5f / 7.0f) / kKilogramsPerPound; // 0.5 kg/wk
		default:
			return 0;
	}
}


- (float)heightIncrement {
	switch ([self weightUnit]) {
		case EWWeightUnitPounds:
		case EWWeightUnitStones:
			return 0.0254f;
		case EWWeightUnitKilograms:
			return 0.01f;
		default:
			return 0;
	}
}


- (BOOL)isNumericFlag:(int)which {
	return [self boolForKey:@"EnableLadder"] ? (which == 3) : NO;
}


- (BOOL)highlightWeekends {
	return [self boolForKey:@"HighlightWeekends"];
}


- (BOOL)highlightBMIZones {
	return [self boolForKey:@"HighlightBMIZones"];
}


- (BOOL)fitGoalOnChart {
	return [self boolForKey:@"ChartFitGoal"];
}


- (BOOL)isLadderEnabled {
	return [self boolForKey:@"EnableLadder"];
}


- (void)setLadderEnabled:(BOOL)doit {
	[self setBool:doit forKey:@"EnableLadder"];
}


- (NSDate *)firstLaunchDate {
	return [self objectForKey:@"FirstLaunchDate"];
}


- (void)setFirstLaunchDate {
	[self setObject:[NSDate date] forKey:@"FirstLaunchDate"];
}


- (NSDictionary *)registration {
	return [self dictionaryForKey:@"RegistrationInfo"];
}


- (void)setRegistration:(NSDictionary *)info {
	[self setObject:info forKey:@"RegistrationInfo"];
}


- (BOOL)showRegistrationReminder {
	return [self boolForKey:@"RegistrationReminder"];
}


- (void)setShowRegistrationReminder:(BOOL)flag {
	[self setBool:flag forKey:@"RegistrationReminder"];
}


@end
