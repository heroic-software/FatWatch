/*
 * EWEnergyEquivalent.m
 * Created by Benjamin Ragheb on 1/5/10.
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

#import "EWEnergyEquivalent.h"
#import "NSUserDefaults+EWAdditions.h"
#import "EWEnergyFormatter.h"


static float gCurrentWeightInKilograms = 0;
static NSString * const kShortSpace = @"\xe2\x80\x85"; // four-per-em space


NSString *EWEquivalentFormatNumber(float n, NSString *unitName, int digits) {
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterDecimalStyle];
	[nf setMaximumFractionDigits:digits];
	[nf setPositiveSuffix:[kShortSpace stringByAppendingString:unitName]];
	[nf setPositiveInfinitySymbol:
	 [[nf positiveInfinitySymbol] stringByAppendingString:[nf positiveSuffix]]];
	NSString *string = [nf stringFromNumber:@(n)];
	return string;
}



@implementation EWActivityEquivalent
{
	sqlite_int64 dbID;
	NSString *name;
	float mets;
}

@synthesize dbID;
@synthesize name;
@dynamic unitName;
@synthesize value = mets;

+ (void)setCurrentWeight:(float)weight {
	gCurrentWeightInKilograms = weight * kKilogramsPerPound;
}

- (NSString *)unitName {
	return nil;
}

- (void)setUnitName:(NSString *)newName {
	if (newName) NSLog(@"Warning: attempt to set unit name '%@' on an activity", newName);
}

- (NSString *)stringForEnergy:(float)energy {
	// 1 MET = 1 kcal/kg/hr
	// 1 kcal/hr = 1 MET * 1 kg
	// 1 kcal/min = 1 MET * 1 kg * 60min/hr
	static const float kMinutesPerHour = 60.0f;
	float energyPerUnit = (mets - 1) * gCurrentWeightInKilograms / kMinutesPerHour;
	float minutes = energy / energyPerUnit;
	if (minutes < 100) {
		return EWEquivalentFormatNumber(minutes, @"min", 0);
	} else {
		return EWEquivalentFormatNumber(minutes / 60.0f, @"hrs", 1);
	}
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%.1f MET", mets];
}


@end


@implementation EWFoodEquivalent
{
	sqlite_int64 dbID;
	NSString *name;
	float energyPerUnit;
	NSString *unitName;
}

@synthesize dbID;
@synthesize name;
@synthesize unitName;
@synthesize value = energyPerUnit;

- (NSString *)stringForEnergy:(float)energy {
	return EWEquivalentFormatNumber(energy / energyPerUnit, unitName, 1);
}

- (NSString *)description {
	EWEnergyFormatter *ef = [[EWEnergyFormatter alloc] init];
	return [NSString stringWithFormat:@"%@/%@", [ef stringFromFloat:energyPerUnit], unitName];
}


@end
