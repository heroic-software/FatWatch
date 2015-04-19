/*
 * NewDatabaseViewController.m
 * Created by Benjamin Ragheb on 4/24/08.
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

#import "BRTableButtonRow.h"
#import "EatWatchAppDelegate.h"
#import "NSUserDefaults+EWAdditions.h"
#import "NewDatabaseViewController.h"


@interface NewDatabaseViewController ()
- (void)dismissView:(BRTableButtonRow *)sender;
@end


@implementation NewDatabaseViewController


- (id)init {
	if ((self = [super initWithStyle:UITableViewStyleGrouped])) {

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
			if ([weightUnit unsignedIntValue] == selectedWeightUnit) {
				section.selectedIndex = [section numberOfRows] - 1;
			}
		}
		[self addSection:section animated:NO];
		
		EWEnergyUnit selectedEnergyUnit = [ud energyUnit];
		section = [[BRTableRadioSection alloc] init];
		section.headerTitle = NSLocalizedString(@"Energy Unit", nil);
		for (id energyUnit in [NSUserDefaults energyUnits]) {
			BRTableRow *row = [[BRTableRow alloc] init];
			row.title = [NSUserDefaults nameForEnergyUnit:energyUnit];
			row.object = energyUnit;
			[section addRow:row animated:NO];
			if ([energyUnit unsignedIntValue] == selectedEnergyUnit) {
				section.selectedIndex = [section numberOfRows] - 1;
			}
		}
		[self addSection:section animated:NO];
		
		float selectedIncrement = [ud scaleIncrement];
		section = [[BRTableRadioSection alloc] init];
		section.headerTitle = NSLocalizedString(@"Scale Precision", nil);
		for (id increment in [NSUserDefaults scaleIncrements]) {
			BRTableRow *row = [[BRTableRow alloc] init];
			row.title = [NSUserDefaults nameForScaleIncrement:increment];
			row.object = increment;
			[section addRow:row animated:NO];
			if (fabsf([increment floatValue] - selectedIncrement) < 0.01f) {
				section.selectedIndex = [section numberOfRows] - 1;
			}
		}
		[self addSection:section animated:NO];
		
		BRTableSection *buttonSection = [[BRTableSection alloc] init];
		buttonSection.footerTitle = NSLocalizedString(@"You can change units at any time using the Settings app.", @"New Database view footer");
		
		BRTableButtonRow *dismissRow = [[BRTableButtonRow alloc] init];
		dismissRow.title = NSLocalizedString(@"Weigh-in Now", nil);
		dismissRow.target = self;
		dismissRow.action = @selector(dismissView:);
		dismissRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		[buttonSection addRow:dismissRow animated:NO];
		
		[self addSection:buttonSection animated:NO];
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

	[(id)[[UIApplication sharedApplication] delegate] continueLaunchSequence];
}


@end
