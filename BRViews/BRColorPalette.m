//
//  BRColorPalette.m
//
//  Created by Benjamin Ragheb on 7/28/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "BRColorPalette.h"


@implementation BRColorPalette


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
		if ([scanner scanFloat:&red] &&
			[scanner scanFloat:&green] &&
			[scanner scanFloat:&blue])
		{
			UIColor *color = [[UIColor alloc] initWithRed:red 
													green:green
													 blue:blue
													alpha:1];
			palette[name] = color;
			[color release];
		} else {
			NSLog(@"Warning: can't parse color \"%@\"", value);
		}
		[scanner release];
	}
	
	if (colorDictionary) {
		[palette addEntriesFromDictionary:colorDictionary];
		[colorDictionary release];
	}
	
	colorDictionary = [palette copy];
	
	[palette release];
	[info release];
}


- (void)removeAllColors {
	[colorDictionary release];
	colorDictionary = nil;
}


- (UIColor *)colorNamed:(NSString *)colorName {
	UIColor *color = colorDictionary[colorName];
	if (color == nil) NSLog(@"Warning: no color named \"%@\"", colorName);
	return color;
}


- (void)dealloc {
	[colorDictionary release];
	[super dealloc];
}


@end
