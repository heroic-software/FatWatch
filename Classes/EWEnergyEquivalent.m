//
//  EWEnergyEquivalent.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/5/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "EWEnergyEquivalent.h"
#import "NSUserDefaults+EWAdditions.h"


static float gCurrentWeightInKilograms = 0;
static NSString * const kShortSpace = @"\xe2\x80\x88";


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
	float x = energy / energyPerUnit;
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterDecimalStyle];
	[nf setMaximumFractionDigits:0];
	[nf setPositiveSuffix:[kShortSpace stringByAppendingString:@"min"]];
	NSString *string = [nf stringFromNumber:[NSNumber numberWithFloat:x]];
	[nf release];
	return string;
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
	float x = energy / energyPerUnit;
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterDecimalStyle];
	[nf setMaximumFractionDigits:1];
	[nf setPositiveSuffix:[kShortSpace stringByAppendingString:unitName]];
	NSString *string = [nf stringFromNumber:[NSNumber numberWithFloat:x]];
	[nf release];
	return string;
}

- (void)dealloc {
	[name release];
	[unitName release];
	[super dealloc];
}

@end
