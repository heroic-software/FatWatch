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
	return [formatter autorelease];
}


+ (NSFormatter *)poundsAsStonesFormatterWithFractionDigits:(NSUInteger)digits {
	BRMixedNumberFormatter *formatter = [[BRMixedNumberFormatter alloc] init];
	formatter.multiple = 1;
	formatter.divisor = 14; // pounds per stone
	formatter.quotientFormatter = [self numberFormatterWithFractionDigits:0];
	formatter.remainderFormatter = [self numberFormatterWithFractionDigits:digits];
	formatter.formatString = NSLocalizedString(@"STONE_FORMAT", nil);
	return [formatter autorelease];
}


+ (NSFormatter *)metersAsFeetFormatter {
	BRMixedNumberFormatter *formatter = [[BRMixedNumberFormatter alloc] init];
	formatter.multiple = 39.370079f; // meters to inches
	formatter.divisor = 12; // inches per foot
	NSNumberFormatter *nf = [self numberFormatterWithFractionDigits:0];
	formatter.quotientFormatter = nf;
	formatter.remainderFormatter = nf;
	formatter.formatString = @"%@\'%@\"";
	return [formatter autorelease];
}


@synthesize multiple;
@synthesize divisor;
@synthesize quotientFormatter;
@synthesize remainderFormatter;
@synthesize formatString;


- (NSString *)stringForObjectValue:(id)anObject {
	float value = multiple * [anObject floatValue];
	
	int quo = floorf(value / divisor);
	float rem = fmodf(value, divisor);
	
	NSString *quotient = [self.quotientFormatter stringFromNumber:[NSNumber numberWithInt:quo]];
	NSString *remainder = [self.remainderFormatter stringFromNumber:[NSNumber numberWithFloat:rem]];
	return [NSString stringWithFormat:formatString, quotient, remainder];
}

@end
