/*
 * BRMixedNumberFormatter.m
 * Created by Benjamin Ragheb on 12/10/08.
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

#import "BRMixedNumberFormatter.h"


@implementation BRMixedNumberFormatter
{
	float multiple;
	float divisor;
	NSNumberFormatter *quotientFormatter;
	NSNumberFormatter *remainderFormatter;
	NSString *formatString;
}

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
