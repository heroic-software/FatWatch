/*
 * EWEnergyFormatter.m
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

#import "EWEnergyFormatter.h"
#import "NSUserDefaults+EWAdditions.h"


static NSString * const kShortSpace = @"\xe2\x80\x88";


@implementation EWEnergyFormatter


- (id)init {
	if ((self = [super init])) {
		switch ([[NSUserDefaults standardUserDefaults] energyUnit]) {
			case EWEnergyUnitKilojoules:
				[self setPositiveSuffix:[kShortSpace stringByAppendingString:NSLocalizedString(@"kJ", @"kilojoule suffix")]];
				[self setMultiplier:@(kKilojoulesPerCalorie)];
				break;
			case EWEnergyUnitCalories:
				[self setPositiveSuffix:[kShortSpace stringByAppendingString:NSLocalizedString(@"cal", @"calorie suffix")]];
				break;
			default:
				break;
		}
		[self setMaximumFractionDigits:0]; // Whole numbers only, please.
	}
	return self;
}


- (NSString *)stringFromFloat:(float)value {
	return [self stringFromNumber:@(value)];
}


@end
