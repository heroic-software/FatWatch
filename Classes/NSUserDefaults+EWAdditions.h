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


extern NSString * const EWBMIStatusDidChangeNotification;


typedef NS_ENUM(NSInteger, EWWeightUnit) {
	EWWeightUnitPounds = 1,
	EWWeightUnitKilograms = 2,
	EWWeightUnitStones = 3,
	EWWeightUnitGrams = 4,
};


typedef NS_ENUM(NSInteger, EWEnergyUnit) {
	EWEnergyUnitCalories = 1,
	EWEnergyUnitKilojoules = 2
};


@interface NSUserDefaults (EWAdditions)
- (void)registerDefaultsNamed:(NSString *)name;
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
- (NSDate *)firstLaunchDate;
- (void)setFirstLaunchDate;
@property (nonatomic,readonly) BOOL highlightWeekends;
@property (nonatomic,readonly) BOOL highlightBMIZones;
@property (nonatomic,readonly) BOOL fitGoalOnChart;
@property (nonatomic,getter=isLadderEnabled) BOOL ladderEnabled;
@property (nonatomic,copy) NSDictionary *registration;
@property (nonatomic) BOOL showRegistrationReminder;
@end
