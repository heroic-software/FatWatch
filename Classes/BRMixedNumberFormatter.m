//
//  BRMixedNumberFormatter.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/10/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRMixedNumberFormatter.h"


@implementation BRMixedNumberFormatter


+ (NSNumberFormatter *)numberFormatterWithFractionDigits:(NSUInteger)digits {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[formatter setMinimumFractionDigits:digits];
	[formatter setMaximumFractionDigits:digits];
	return formatter;
}


+ (BRMixedNumberFormatter *)poundsAsStonesFormatterWithFractionDigits:(NSUInteger)digits {
	// Unicode PUNCTUATION SPACE: E2 80 88
	BRMixedNumberFormatter *formatter = [[BRMixedNumberFormatter alloc] init];
	formatter.multiple = 1;
	formatter.divisor = 14; // pounds per stone
	formatter.quotientFormatter = [self numberFormatterWithFractionDigits:0];
	formatter.remainderFormatter = [self numberFormatterWithFractionDigits:digits];
	formatter.formatString = NSLocalizedString(@"%@\xe2\x80\x88st %@\xe2\x80\x88lb", @"Stone Format");
	return formatter;
}


+ (BRMixedNumberFormatter *)metersAsFeetFormatter {
	BRMixedNumberFormatter *formatter = [[BRMixedNumberFormatter alloc] init];
	formatter.multiple = 39.370079f; // meters to inches
	formatter.divisor = 12; // inches per foot
	NSNumberFormatter *nf = [self numberFormatterWithFractionDigits:0];
	formatter.quotientFormatter = nf;
	formatter.remainderFormatter = nf;
	formatter.formatString = NSLocalizedString(@"%@\'\xe2\x80\x88%@\"", @"Feet Format");
	return formatter;
}


@synthesize multiple;
@synthesize divisor;
@synthesize quotientFormatter;
@synthesize remainderFormatter;
@synthesize formatString;


- (NSString *)stringForObjectValue:(id)anObject {
	float value = multiple * [anObject floatValue];

	// We round the quantity ourselves, in order to avoid a problem where 
	// rounding late results in a remainder equal to the divisor (e.g., 5'12").
	float m = powf(10.0f, [self.remainderFormatter minimumFractionDigits]);
	if (m > 1) {
		value = roundf(value * m) / m;
	} else {
		value = roundf(value);
	}

	int quo = floorf(value / divisor);
	float rem = fmodf(value, divisor);
	
	NSString *quostr = [self.quotientFormatter stringFromNumber:@(quo)];
	NSString *remstr = [self.remainderFormatter stringFromNumber:@(rem)];
	return [NSString stringWithFormat:formatString, quostr, remstr];
}


@end
