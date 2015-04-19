/*
 * EWWeightFormatter.m
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

#import "BRColorPalette.h"
#import "BRMixedNumberFormatter.h"
#import "EWWeightFormatter.h"
#import "NSUserDefaults+EWAdditions.h"


static NSString * const kShortSpace = @"\xe2\x80\x88";
static NSString * const kMinusSign = @"\xe2\x88\x92";


@implementation NSFormatter (EWAdditions)
- (NSString *)stringForFloat:(float)value {
	return [self stringForObjectValue:@(value)];
}
@end


@implementation EWWeightFormatter


+ (void)getBMIWeights:(float *)weightArray {
	float height = [[NSUserDefaults standardUserDefaults] height];
	float factor = (height * height) / kKilogramsPerPound;
	weightArray[0] = 18.5f * factor;
	weightArray[1] = 25.0f * factor;
	weightArray[2] = 30.0f * factor;
}


+ (UIColor *)colorForWeight:(float)weight {
	if ([[NSUserDefaults standardUserDefaults] isBMIEnabled] == NO) {
		return [UIColor clearColor];
	}
	float height = [[NSUserDefaults standardUserDefaults] height];
	float BMI = (weight * kKilogramsPerPound) / (height * height);
	if (BMI < 18.5f) return [BRColorPalette colorNamed:@"BMIUnderweight"];
	if (BMI < 25.0f) return [BRColorPalette colorNamed:@"BMINormal"];
	if (BMI < 30.0f) return [BRColorPalette colorNamed:@"BMIOverweight"];
	return [BRColorPalette colorNamed:@"BMIObese"];
}


+ (UIColor *)colorForWeight:(float)weight alpha:(float)alpha {
	if ([[NSUserDefaults standardUserDefaults] isBMIEnabled] == NO) {
		return [UIColor clearColor];
	}
	return [[self colorForWeight:weight] colorWithAlphaComponent:alpha];
}


+ (NSUInteger)fractionDigitsForStyle:(EWWeightFormatterStyle)style {
	switch (style) {
		case EWWeightFormatterStyleDisplay:
		case EWWeightFormatterStyleExport:
			return [[NSUserDefaults standardUserDefaults] scaleIncrementFractionDigits];
		case EWWeightFormatterStyleWhole:
		case EWWeightFormatterStyleGraph:
			return 0;
		case EWWeightFormatterStyleVariance:
			return 1;
		default:
			NSAssert1(NO, @"fractionDigitsForStyle:%d unexpected", style);
	}
	return -1;
}


+ (NSNumber *)multiplierForUnit:(EWWeightUnit)unit {
	switch (unit) {
		case EWWeightUnitKilograms:
			return @(kKilogramsPerPound);
		case EWWeightUnitGrams:
			return @(kKilogramsPerPound * 1000);
		case EWWeightUnitPounds:
		case EWWeightUnitStones:
			return @1;
		default:
			return nil;
	}
}


+ (NSString *)suffixForUnit:(EWWeightUnit)unit {
	// Unicode PUNCTUATION SPACE: E2 80 88
	switch (unit) {
		case EWWeightUnitPounds:
			return NSLocalizedString(@"lb", @"pound unit suffix");
		case EWWeightUnitKilograms:
			return NSLocalizedString(@"kg", @"kilogram unit suffix");
		case EWWeightUnitGrams:
			return NSLocalizedString(@"g", @"gram unit suffix");
		default:
			return nil;
	}
}


+ (id)weightFormatterWithStyle:(EWWeightFormatterStyle)style unit:(EWWeightUnit)unit {
	if (style == EWWeightFormatterStyleBMI || style == EWWeightFormatterStyleBMILabeled) {
		float height = [[NSUserDefaults standardUserDefaults] height];
		NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
		[nf setMinimumFractionDigits:1];
		[nf setMaximumFractionDigits:1];
		[nf setMultiplier:@(kKilogramsPerPound / (height * height))];
		if (style == EWWeightFormatterStyleBMILabeled) {
			[nf setPositivePrefix:@"BMI "];
		}
		return nf;
	}
	
	NSUInteger fd = [self fractionDigitsForStyle:style];
	
	if (unit == EWWeightUnitStones && 
		style != EWWeightFormatterStyleVariance &&
		style != EWWeightFormatterStyleExport) {
		BRMixedNumberFormatter *fmtr = 
		[BRMixedNumberFormatter poundsAsStonesFormatterWithFractionDigits:fd];
		if (style == EWWeightFormatterStyleGraph) {
			fmtr.formatString = @"%@,%@";
		}
		return fmtr;
	}
	
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	
	if (style == EWWeightFormatterStyleVariance) {
		[nf setPositivePrefix:@"+"];
		[nf setNegativePrefix:kMinusSign];
	}

	[nf setMinimumIntegerDigits:1];
	[nf setMinimumFractionDigits:fd];
	[nf setMaximumFractionDigits:fd];
	
	[nf setMultiplier:[self multiplierForUnit:unit]];
		
	if (style == EWWeightFormatterStyleDisplay || style == EWWeightFormatterStyleWhole) {
		[nf setPositiveSuffix:[kShortSpace stringByAppendingString:[self suffixForUnit:unit]]];
	}
	
	if (style == EWWeightFormatterStyleExport) {
		NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[nf setLocale:locale];
	}
	
	return nf;
}


+ (id)weightFormatterWithStyle:(EWWeightFormatterStyle)style {
	return [self weightFormatterWithStyle:style unit:[[NSUserDefaults standardUserDefaults] weightUnit]];
}


@end
