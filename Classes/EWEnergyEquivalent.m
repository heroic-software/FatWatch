//
//  EWEnergyEquivalent.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/5/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "EWEnergyEquivalent.h"
#import "NSUserDefaults+EWAdditions.h"


@implementation EWEnergyEquivalent


@synthesize name;
@synthesize energyPerUnit;
@synthesize unitName;


- (void)setEnergyPerMinuteByMets:(float)mets forWeight:(float)weight {
	// 1 MET = 1 kcal/kg/hr
	// 1 kcal/hr = 1 MET * 1 kg
	// 1 kcal/min = 1 MET * 1 kg * 60min/hr
	static const float kMinutesPerHour = 60.0f;
	self.energyPerUnit = (mets - 1) * (weight * kKilogramsPerPound) / kMinutesPerHour;
	self.unitName = @"min";
}


- (NSString *)stringForEnergy:(float)energy {
	float x = energy / energyPerUnit;
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterDecimalStyle];
	NSString *string = [NSString stringWithFormat:@"%@\xe2\x80\x88%@", 
						[nf stringFromNumber:[NSNumber numberWithFloat:x]],
						unitName];
	[nf release];
	return string;
}


@end
