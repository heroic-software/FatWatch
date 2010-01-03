//
//  NewDatabaseViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/24/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "BRTableButtonRow.h"
#import "EatWatchAppDelegate.h"
#import "NSUserDefaults+EWAdditions.h"
#import "NewDatabaseViewController.h"


@implementation NewDatabaseViewController


- (id)init {
	if ([super initWithStyle:UITableViewStyleGrouped]) {

		NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
		BRTableRadioSection *section;
		
		EWWeightUnit selectedWeightUnit = [ud weightUnit];
		section = [[BRTableRadioSection alloc] init];
		section.headerTitle = NSLocalizedString(@"Weight Unit", nil);
		for (id weightUnit in [NSUserDefaults weightUnitsForDisplay]) {
			BRTableRow *row = [[BRTableRow alloc] init];
			row.title = [NSUserDefaults nameForWeightUnit:weightUnit];
			row.object = weightUnit;
			[section addRow:row animated:NO];
			[row release];
			if ([weightUnit intValue] == selectedWeightUnit) {
				section.selectedIndex = [section numberOfRows] - 1;
			}
		}
		[self addSection:section animated:NO];
		[section release];
		
		EWEnergyUnit selectedEnergyUnit = [ud energyUnit];
		section = [[BRTableRadioSection alloc] init];
		section.headerTitle = NSLocalizedString(@"Energy Unit", nil);
		for (id energyUnit in [NSUserDefaults energyUnits]) {
			BRTableRow *row = [[BRTableRow alloc] init];
			row.title = [NSUserDefaults nameForEnergyUnit:energyUnit];
			row.object = energyUnit;
			[section addRow:row animated:NO];
			[row release];
			if ([energyUnit intValue] == selectedEnergyUnit) {
				section.selectedIndex = [section numberOfRows] - 1;
			}
		}
		[self addSection:section animated:NO];
		[section release];
		
		float selectedIncrement = [ud scaleIncrement];
		section = [[BRTableRadioSection alloc] init];
		section.headerTitle = NSLocalizedString(@"Scale Precision", nil);
		for (id increment in [NSUserDefaults scaleIncrements]) {
			BRTableRow *row = [[BRTableRow alloc] init];
			row.title = [NSUserDefaults nameForScaleIncrement:increment];
			row.object = increment;
			[section addRow:row animated:NO];
			[row release];
			if (fabsf([increment floatValue] - selectedIncrement) < 0.01f) {
				section.selectedIndex = [section numberOfRows] - 1;
			}
		}
		[self addSection:section animated:NO];
		[section release];
		
		BRTableSection *buttonSection = [[BRTableSection alloc] init];
		buttonSection.footerTitle = NSLocalizedString(@"You can change units at any time using the Settings app.", @"New Database view footer");
		
		BRTableButtonRow *dismissRow = [[BRTableButtonRow alloc] init];
		dismissRow.title = NSLocalizedString(@"Weigh-in Now", nil);
		dismissRow.target = self;
		dismissRow.action = @selector(dismissView:);
		[buttonSection addRow:dismissRow animated:NO];
		[dismissRow release];
		
		[self addSection:buttonSection animated:NO];
		[buttonSection release];
	}
	return self;
}


- (void)dismissView:(BRTableButtonRow *)sender {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	BRTableRadioSection *section;
	
	section = (id)[self sectionAtIndex:0];
	[ud setWeightUnit:[[section selectedRow] object]];
	
	section = (id)[self sectionAtIndex:1];
	[ud setEnergyUnit:[[section selectedRow] object]];

	section = (id)[self sectionAtIndex:2];
	[ud setScaleIncrement:[[section selectedRow] object]];

	id appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate removeLaunchViewWithTransitionType:kCATransitionPush 
											subType:kCATransitionFromRight];
}


@end
