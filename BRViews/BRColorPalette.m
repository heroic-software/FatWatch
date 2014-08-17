//
//  BRColorPalette.m
//
//  Created by Benjamin Ragheb on 7/28/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

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
