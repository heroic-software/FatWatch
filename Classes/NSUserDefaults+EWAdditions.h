/*
 * NSUserDefaults+EWAdditions.h
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
