//
//  NSUserDefaults+EWAdditions.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/20/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>


extern const float kKilogramsPerPound;
extern const float kCaloriesPerPound;
extern const float kKilojoulesPerPound;
extern const float kKilojoulesPerCalorie;


extern NSString * const EWBMIStatusDidChange;


typedef enum {
	EWWeightUnitPounds = 1,
	EWWeightUnitKilograms = 2,
	EWWeightUnitStones = 3,
	EWWeightUnitGrams = 4,
} EWWeightUnit;


typedef enum {
	EWEnergyUnitCalories = 1,
	EWEnergyUnitKilojoules = 2
} EWEnergyUnit;


@interface NSUserDefaults (EWAdditions)
+ (NSArray *)weightUnitsForDisplay;
+ (NSArray *)weightUnitsForExport;
+ (NSString *)nameForWeightUnit:(NSNumber *)weightUnitID;
- (void)setWeightUnit:(NSNumber *)weightUnit;
- (EWWeightUnit)weightUnit;
+ (NSArray *)energyUnits;
+ (NSString *)nameForEnergyUnit:(NSNumber *)energyUnit;
- (void)setEnergyUnit:(NSNumber *)energyUnit;
- (EWEnergyUnit)energyUnit;
+ (NSArray *)scaleIncrements;
+ (NSString *)nameForScaleIncrement:(id)number;
- (void)setScaleIncrement:(id)number;
- (float)scaleIncrement;
- (BOOL)isBMIEnabled;
- (void)setBMIEnabled:(BOOL)flag;
- (void)setHeight:(float)meters;
- (float)height;
- (NSUInteger)scaleIncrementFractionDigits;
- (float)weightIncrement;
- (float)weightWholeIncrement;
- (float)defaultWeightChange;
- (float)heightIncrement;
- (BOOL)isNumericFlag:(int)which;
@end
