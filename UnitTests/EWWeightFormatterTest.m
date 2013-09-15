//
//  EWWeightFormatterTest.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/6/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "EWWeightFormatter.h"
#import "BRColorPalette.h"


#define SHORT_SPACE @"\xe2\x80\x88"
#define MINUS_SIGN @"\xe2\x88\x92"


@interface EWWeightFormatterTest : SenTestCase
@end

@implementation EWWeightFormatterTest


#define TestFormatStyleUnit(EWStyle, EWUnit, EWIncrement, weightNumber, weightString) \
{ \
	[[NSUserDefaults standardUserDefaults] setScaleIncrement:EWIncrement]; \
	NSFormatter *formatter = [EWWeightFormatter weightFormatterWithStyle:EWStyle unit:EWUnit]; \
	NSString *string; NSNumber *number; \
	number = [NSNumber numberWithFloat:weightNumber]; \
	string = [formatter stringForObjectValue:number]; \
	STAssertEqualObjects(string, weightString, @"stringForObjectValue:"); \
};


#define TestParseStyleUnit(EWStyle, EWUnit, weightNumber, weightString) \
{ \
	NSFormatter *formatter = [EWWeightFormatter weightFormatterWithStyle:EWStyle unit:EWUnit]; \
	NSString *string, *error; NSNumber *number; BOOL didParse; \
	didParse = [formatter getObjectValue:&number forString:string errorDescription:&error]; \
	STAssertTrue(didParse, @"return getObjectValue:forString:errorDescription"); \
	STAssertEqualObjects(number, weightNumber, @"value getObjectValue:forString:errorDescription:"); \
}; \


#pragma mark EWWeightFormatterStyleDisplay


- (void)testStyleDisplayUnitPounds {
	TestFormatStyleUnit(EWWeightFormatterStyleDisplay, EWWeightUnitPounds, @"1.0", 100, @"100" SHORT_SPACE @"lb");
	TestFormatStyleUnit(EWWeightFormatterStyleDisplay, EWWeightUnitPounds, @"0.1", 100, @"100.0" SHORT_SPACE @"lb");
	TestFormatStyleUnit(EWWeightFormatterStyleDisplay, EWWeightUnitPounds, @"0.01", 100, @"100.00" SHORT_SPACE @"lb");
}

- (void)testStyleDisplayUnitKilograms {
	TestFormatStyleUnit(EWWeightFormatterStyleDisplay, EWWeightUnitKilograms, @"1.0", 100, @"45" SHORT_SPACE @"kg");
	TestFormatStyleUnit(EWWeightFormatterStyleDisplay, EWWeightUnitKilograms, @"0.1", 100, @"45.4" SHORT_SPACE @"kg");
	TestFormatStyleUnit(EWWeightFormatterStyleDisplay, EWWeightUnitKilograms, @"0.01", 100, @"45.36" SHORT_SPACE @"kg");
}

- (void)testStyleDisplayUnitStones {
	TestFormatStyleUnit(EWWeightFormatterStyleDisplay, EWWeightUnitStones, @"1.0", 100.2f, @"7" SHORT_SPACE @"st 2" SHORT_SPACE @"lb");
	TestFormatStyleUnit(EWWeightFormatterStyleDisplay, EWWeightUnitStones, @"0.1", 100.2f, @"7" SHORT_SPACE @"st 2.2" SHORT_SPACE @"lb");
	TestFormatStyleUnit(EWWeightFormatterStyleDisplay, EWWeightUnitStones, @"0.01", 100.2f, @"7" SHORT_SPACE @"st 2.20" SHORT_SPACE @"lb");
}

- (void)testStyleDisplayUnitGrams {
	TestFormatStyleUnit(EWWeightFormatterStyleDisplay, EWWeightUnitGrams, @"1.0", 100, @"45359" SHORT_SPACE @"g");
	TestFormatStyleUnit(EWWeightFormatterStyleDisplay, EWWeightUnitGrams, @"0.1", 100, @"45359.2" SHORT_SPACE @"g");
	TestFormatStyleUnit(EWWeightFormatterStyleDisplay, EWWeightUnitGrams, @"0.01", 100, @"45359.23" SHORT_SPACE @"g");
}


#pragma mark EWWeightFormatterStyleVariance


- (void)testStyleVarianceUnitPounds {
	TestFormatStyleUnit(EWWeightFormatterStyleVariance, EWWeightUnitPounds, @"1", +10, @"+10.0");
	TestFormatStyleUnit(EWWeightFormatterStyleVariance, EWWeightUnitPounds, @"1", -10, MINUS_SIGN @"10.0");
}

- (void)testStyleVarianceUnitKilograms {
	TestFormatStyleUnit(EWWeightFormatterStyleVariance, EWWeightUnitKilograms, @"1", +10, @"+4.5");
	TestFormatStyleUnit(EWWeightFormatterStyleVariance, EWWeightUnitKilograms, @"1", -10, MINUS_SIGN @"4.5");
}

- (void)testStyleVarianceUnitStones {
	TestFormatStyleUnit(EWWeightFormatterStyleVariance, EWWeightUnitStones, @"1", +10, @"+10.0");
	TestFormatStyleUnit(EWWeightFormatterStyleVariance, EWWeightUnitStones, @"1", -10, MINUS_SIGN @"10.0");
}

- (void)testStyleVarianceUnitGrams {
	TestFormatStyleUnit(EWWeightFormatterStyleVariance, EWWeightUnitGrams, @"1", +10, @"+4535.9");
	TestFormatStyleUnit(EWWeightFormatterStyleVariance, EWWeightUnitGrams, @"1", -10, MINUS_SIGN @"4535.9");
}


#pragma mark EWWeightFormatterStyleWhole


- (void)testStyleWholeUnitPounds {
	TestFormatStyleUnit(EWWeightFormatterStyleWhole, EWWeightUnitPounds, @"1.0", 100, @"100" SHORT_SPACE @"lb");
	TestFormatStyleUnit(EWWeightFormatterStyleWhole, EWWeightUnitPounds, @"0.1", 100, @"100" SHORT_SPACE @"lb");
	TestFormatStyleUnit(EWWeightFormatterStyleWhole, EWWeightUnitPounds, @"0.01", 100, @"100" SHORT_SPACE @"lb");
}

- (void)testStyleWholeUnitKilograms {
	TestFormatStyleUnit(EWWeightFormatterStyleWhole, EWWeightUnitKilograms, @"1.0", 100, @"45" SHORT_SPACE @"kg");
	TestFormatStyleUnit(EWWeightFormatterStyleWhole, EWWeightUnitKilograms, @"0.1", 100, @"45" SHORT_SPACE @"kg");
	TestFormatStyleUnit(EWWeightFormatterStyleWhole, EWWeightUnitKilograms, @"0.01", 100, @"45" SHORT_SPACE @"kg");
}

- (void)testStyleWholeUnitStones {
	TestFormatStyleUnit(EWWeightFormatterStyleWhole, EWWeightUnitStones, @"1.0", 100.2f, @"7" SHORT_SPACE @"st 2" SHORT_SPACE @"lb");
	TestFormatStyleUnit(EWWeightFormatterStyleWhole, EWWeightUnitStones, @"0.1", 100.2f, @"7" SHORT_SPACE @"st 2" SHORT_SPACE @"lb");
	TestFormatStyleUnit(EWWeightFormatterStyleWhole, EWWeightUnitStones, @"0.01", 100.2f, @"7" SHORT_SPACE @"st 2" SHORT_SPACE @"lb");
}

- (void)testStyleWholeUnitGrams {
	TestFormatStyleUnit(EWWeightFormatterStyleWhole, EWWeightUnitGrams, @"1.0", 100, @"45359" SHORT_SPACE @"g");
	TestFormatStyleUnit(EWWeightFormatterStyleWhole, EWWeightUnitGrams, @"0.1", 100, @"45359" SHORT_SPACE @"g");
	TestFormatStyleUnit(EWWeightFormatterStyleWhole, EWWeightUnitGrams, @"0.01", 100, @"45359" SHORT_SPACE @"g");
}


#pragma mark EWWeightFormatterStyleGraph


- (void)testStyleGraphUnitPounds {
	TestFormatStyleUnit(EWWeightFormatterStyleGraph, EWWeightUnitPounds, @"1.0", 100, @"100");
	TestFormatStyleUnit(EWWeightFormatterStyleGraph, EWWeightUnitPounds, @"0.1", 100, @"100");
	TestFormatStyleUnit(EWWeightFormatterStyleGraph, EWWeightUnitPounds, @"0.01", 100, @"100");
}

- (void)testStyleGraphUnitKilograms {
	TestFormatStyleUnit(EWWeightFormatterStyleGraph, EWWeightUnitKilograms, @"1.0", 100, @"45");
	TestFormatStyleUnit(EWWeightFormatterStyleGraph, EWWeightUnitKilograms, @"0.1", 100, @"45");
	TestFormatStyleUnit(EWWeightFormatterStyleGraph, EWWeightUnitKilograms, @"0.01", 100, @"45");
}

- (void)testStyleGraphUnitStones {
	TestFormatStyleUnit(EWWeightFormatterStyleGraph, EWWeightUnitStones, @"1.0", 100.2f, @"7,2");
	TestFormatStyleUnit(EWWeightFormatterStyleGraph, EWWeightUnitStones, @"0.1", 100.2f, @"7,2");
	TestFormatStyleUnit(EWWeightFormatterStyleGraph, EWWeightUnitStones, @"0.01", 100.2f, @"7,2");
}

- (void)testStyleGraphUnitGrams {
	TestFormatStyleUnit(EWWeightFormatterStyleGraph, EWWeightUnitGrams, @"1.0", 100, @"45359");
	TestFormatStyleUnit(EWWeightFormatterStyleGraph, EWWeightUnitGrams, @"0.1", 100, @"45359");
	TestFormatStyleUnit(EWWeightFormatterStyleGraph, EWWeightUnitGrams, @"0.01", 100, @"45359");
}


#pragma mark EWWeightFormatterStyleExport


- (void)testStyleExportUnitPounds {
	TestFormatStyleUnit(EWWeightFormatterStyleExport, EWWeightUnitPounds, @"1.0", 123.432f, @"123");
	TestFormatStyleUnit(EWWeightFormatterStyleExport, EWWeightUnitPounds, @"0.1", 123.432f, @"123.4");
	TestFormatStyleUnit(EWWeightFormatterStyleExport, EWWeightUnitPounds, @"0.01", 123.432f, @"123.43");
}

- (void)testStyleExportUnitKilograms {
	TestFormatStyleUnit(EWWeightFormatterStyleExport, EWWeightUnitKilograms, @"1.0", 123.432f, @"56");
	TestFormatStyleUnit(EWWeightFormatterStyleExport, EWWeightUnitKilograms, @"0.1", 123.432f, @"56.0");
	TestFormatStyleUnit(EWWeightFormatterStyleExport, EWWeightUnitKilograms, @"0.01", 123.432f, @"55.99");
}

- (void)testStyleExportUnitStones {
	TestFormatStyleUnit(EWWeightFormatterStyleExport, EWWeightUnitStones, @"1.0", 123.432f, @"123");
	TestFormatStyleUnit(EWWeightFormatterStyleExport, EWWeightUnitStones, @"0.1", 123.432f, @"123.4");
	TestFormatStyleUnit(EWWeightFormatterStyleExport, EWWeightUnitStones, @"0.01", 123.432f, @"123.43");
}

- (void)testStyleExportUnitGrams {
	TestFormatStyleUnit(EWWeightFormatterStyleExport, EWWeightUnitGrams, @"1.0", 123.432f, @"55988");
	TestFormatStyleUnit(EWWeightFormatterStyleExport, EWWeightUnitGrams, @"0.1", 123.432f, @"55987.8");
	TestFormatStyleUnit(EWWeightFormatterStyleExport, EWWeightUnitGrams, @"0.01", 123.432f, @"55987.81");
}


#pragma mark EWWeightFormatterStyleBMI


- (void)testStyleBMIUnitPounds {
	[[NSUserDefaults standardUserDefaults] setHeight:2];
	TestFormatStyleUnit(EWWeightFormatterStyleBMI, EWWeightUnitPounds, @"1.0", 123.432f, @"14.0");
	TestFormatStyleUnit(EWWeightFormatterStyleBMI, EWWeightUnitPounds, @"0.1", 123.432f, @"14.0");
	TestFormatStyleUnit(EWWeightFormatterStyleBMI, EWWeightUnitPounds, @"0.01", 123.432f, @"14.0");
}

- (void)testStyleBMIUnitKilograms {
	[[NSUserDefaults standardUserDefaults] setHeight:2];
	TestFormatStyleUnit(EWWeightFormatterStyleBMI, EWWeightUnitKilograms, @"1.0", 123.432f, @"14.0");
	TestFormatStyleUnit(EWWeightFormatterStyleBMI, EWWeightUnitKilograms, @"0.1", 123.432f, @"14.0");
	TestFormatStyleUnit(EWWeightFormatterStyleBMI, EWWeightUnitKilograms, @"0.01", 123.432f, @"14.0");
}

- (void)testStyleBMIUnitStones {
	[[NSUserDefaults standardUserDefaults] setHeight:2];
	TestFormatStyleUnit(EWWeightFormatterStyleBMI, EWWeightUnitStones, @"1.0", 123.432f, @"14.0");
	TestFormatStyleUnit(EWWeightFormatterStyleBMI, EWWeightUnitStones, @"0.1", 123.432f, @"14.0");
	TestFormatStyleUnit(EWWeightFormatterStyleBMI, EWWeightUnitStones, @"0.01", 123.432f, @"14.0");
}

- (void)testStyleBMIUnitGrams {
	[[NSUserDefaults standardUserDefaults] setHeight:2];
	TestFormatStyleUnit(EWWeightFormatterStyleBMI, EWWeightUnitGrams, @"1.0", 123.432f, @"14.0");
	TestFormatStyleUnit(EWWeightFormatterStyleBMI, EWWeightUnitGrams, @"0.1", 123.432f, @"14.0");
	TestFormatStyleUnit(EWWeightFormatterStyleBMI, EWWeightUnitGrams, @"0.01", 123.432f, @"14.0");
}


#pragma mark EWWeightFormatterStyleBMILabeledLabeled


- (void)testStyleBMILabeledUnitPounds {
	[[NSUserDefaults standardUserDefaults] setHeight:2];
	TestFormatStyleUnit(EWWeightFormatterStyleBMILabeled, EWWeightUnitPounds, @"1.0", 123.432f, @"BMI 14.0");
	TestFormatStyleUnit(EWWeightFormatterStyleBMILabeled, EWWeightUnitPounds, @"0.1", 123.432f, @"BMI 14.0");
	TestFormatStyleUnit(EWWeightFormatterStyleBMILabeled, EWWeightUnitPounds, @"0.01", 123.432f, @"BMI 14.0");
}

- (void)testStyleBMILabeledUnitKilograms {
	[[NSUserDefaults standardUserDefaults] setHeight:2];
	TestFormatStyleUnit(EWWeightFormatterStyleBMILabeled, EWWeightUnitKilograms, @"1.0", 123.432f, @"BMI 14.0");
	TestFormatStyleUnit(EWWeightFormatterStyleBMILabeled, EWWeightUnitKilograms, @"0.1", 123.432f, @"BMI 14.0");
	TestFormatStyleUnit(EWWeightFormatterStyleBMILabeled, EWWeightUnitKilograms, @"0.01", 123.432f, @"BMI 14.0");
}

- (void)testStyleBMILabeledUnitStones {
	[[NSUserDefaults standardUserDefaults] setHeight:2];
	TestFormatStyleUnit(EWWeightFormatterStyleBMILabeled, EWWeightUnitStones, @"1.0", 123.432f, @"BMI 14.0");
	TestFormatStyleUnit(EWWeightFormatterStyleBMILabeled, EWWeightUnitStones, @"0.1", 123.432f, @"BMI 14.0");
	TestFormatStyleUnit(EWWeightFormatterStyleBMILabeled, EWWeightUnitStones, @"0.01", 123.432f, @"BMI 14.0");
}

- (void)testStyleBMILabeledUnitGrams {
	[[NSUserDefaults standardUserDefaults] setHeight:2];
	TestFormatStyleUnit(EWWeightFormatterStyleBMILabeled, EWWeightUnitGrams, @"1.0", 123.432f, @"BMI 14.0");
	TestFormatStyleUnit(EWWeightFormatterStyleBMILabeled, EWWeightUnitGrams, @"0.1", 123.432f, @"BMI 14.0");
	TestFormatStyleUnit(EWWeightFormatterStyleBMILabeled, EWWeightUnitGrams, @"0.01", 123.432f, @"BMI 14.0");
}


#pragma mark Colors


- (void)testColors {
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"ColorPalette" ofType:@"plist"];
	[[BRColorPalette sharedPalette] addColorsFromFile:path];
	
	UIColor *color;
	
	[[NSUserDefaults standardUserDefaults] setBMIEnabled:NO];
	
	color = [EWWeightFormatter colorForWeight:100];
	STAssertEqualObjects(color, [UIColor clearColor], @"foreground color when BMI disabled");
	color = [EWWeightFormatter colorForWeight:100 alpha:0.2f];
	STAssertEqualObjects(color, [UIColor clearColor], @"background color when BMI disabled");
	
	[[NSUserDefaults standardUserDefaults] setBMIEnabled:YES];
	[[NSUserDefaults standardUserDefaults] setHeight:2];

	// BMI * height^2 / kKilogramsPerPound = weight

	color = [EWWeightFormatter colorForWeight:(16.0f * 4 / kKilogramsPerPound)];
	STAssertEqualObjects(color, [BRColorPalette colorNamed:@"BMIUnderweight"], @"underweight");
	color = [EWWeightFormatter colorForWeight:(20.0f * 4 / kKilogramsPerPound)];
	STAssertEqualObjects(color, [BRColorPalette colorNamed:@"BMINormal"], @"normal");
	color = [EWWeightFormatter colorForWeight:(27.0f * 4 / kKilogramsPerPound)];
	STAssertEqualObjects(color, [BRColorPalette colorNamed:@"BMIOverweight"], @"overweight");
	color = [EWWeightFormatter colorForWeight:(32.0f * 4 / kKilogramsPerPound)];
	STAssertEqualObjects(color, [BRColorPalette colorNamed:@"BMIObese"], @"obese");
}

@end
