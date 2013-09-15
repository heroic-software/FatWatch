//
//  EWEnergyFormatter.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/5/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

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
