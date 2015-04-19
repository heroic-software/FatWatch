/*
 * BRColorPalette.m
 * Created by Benjamin Ragheb on 7/28/09.
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


@implementation BRColorPalette
{
	NSDictionary *colorDictionary;
}

+ (UIColor *)colorNamed:(NSString *)colorName {
	return [[BRColorPalette sharedPalette] colorNamed:colorName];
}


+ (BRColorPalette *)sharedPalette {
	static BRColorPalette *palette = nil;
	
	if (palette == nil) {
		palette = [[BRColorPalette alloc] init];
	}
	
	return palette;
}

#if CGFLOAT_IS_DOUBLE
#define scanCGFloat scanDouble
#else
#define scanCGFloat scanFloat
#endif

- (void)addColorsFromFile:(NSString *)path {
	NSDictionary *info = [[NSDictionary alloc] initWithContentsOfFile:path];
	NSMutableDictionary *palette;

	palette = [[NSMutableDictionary alloc] initWithCapacity:[info count]];
	
	NSCharacterSet *skipSet = [[NSCharacterSet characterSetWithCharactersInString:@"123456789.0"] invertedSet];

	for (NSString *name in info) {
		NSString *value = info[name];
		NSScanner *scanner = [[NSScanner alloc] initWithString:value];
		[scanner setCharactersToBeSkipped:skipSet];
		CGFloat red, green, blue;
		if ([scanner scanCGFloat:&red] &&
			[scanner scanCGFloat:&green] &&
			[scanner scanCGFloat:&blue])
		{
			UIColor *color = [[UIColor alloc] initWithRed:red 
													green:green
													 blue:blue
													alpha:1];
			palette[name] = color;
		} else {
			NSLog(@"Warning: can't parse color \"%@\"", value);
		}
	}
	
	if (colorDictionary) {
		[palette addEntriesFromDictionary:colorDictionary];
	}
	
	colorDictionary = [palette copy];
	
}


- (void)removeAllColors {
	colorDictionary = nil;
}


- (UIColor *)colorNamed:(NSString *)colorName {
	UIColor *color = colorDictionary[colorName];
	if (color == nil) NSLog(@"Warning: no color named \"%@\"", colorName);
	return color;
}




@end
