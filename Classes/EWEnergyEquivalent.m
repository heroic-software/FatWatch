//
//  EWEnergyEquivalent.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/5/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

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
	NSString *string = [nf stringFromNumber:[NSNumber numberWithFloat:n]];
	[nf release];
	return string;
}



@implementation EWActivityEquivalent

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

- (void)dealloc {
	[name release];
	[super dealloc];
}

@end


@implementation EWFoodEquivalent

@synthesize dbID;
@synthesize name;
@synthesize unitName;
@synthesize value = energyPerUnit;

- (NSString *)stringForEnergy:(float)energy {
	return EWEquivalentFormatNumber(energy / energyPerUnit, unitName, 1);
}

- (NSString *)description {
	EWEnergyFormatter *ef = [[[EWEnergyFormatter alloc] init] autorelease];
	return [NSString stringWithFormat:@"%@/%@", [ef stringFromFloat:energyPerUnit], unitName];
}

- (void)dealloc {
	[name release];
	[unitName release];
	[super dealloc];
}

@end
