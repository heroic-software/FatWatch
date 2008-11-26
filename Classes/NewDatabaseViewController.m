//
//  NewDatabaseViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/24/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NewDatabaseViewController.h"
#import "WeightFormatters.h"
#import "EatWatchAppDelegate.h"
#import "BRTableButtonRow.h"


@implementation NewDatabaseViewController


- (void)addSectionForStrings:(NSArray *)stringArray 
			   selectedIndex:(NSUInteger)index
					   title:(NSString *)title {
	BRTableRadioSection *section = [[BRTableRadioSection alloc] init];
	section.headerTitle = title;
	for (NSString *name in stringArray) {
		[section addRow:[BRTableRow rowWithTitle:name] animated:NO];
	}
	section.selectedIndex = index;
	[self addSection:section animated:NO];
}


- (id)init {
	if ([super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"NEW_DATABASE_VIEW_TITLE", nil);
		
		[self addSectionForStrings:[WeightFormatters weightUnitNames] 
					 selectedIndex:[WeightFormatters selectedWeightUnitIndex]
							 title:NSLocalizedString(@"WEIGHT_UNIT", nil)];
		[self addSectionForStrings:[WeightFormatters energyUnitNames] 
					 selectedIndex:[WeightFormatters selectedEnergyUnitIndex]
							 title:NSLocalizedString(@"ENERGY_UNIT", nil)];
		[self addSectionForStrings:[WeightFormatters scaleIncrementNames]
					 selectedIndex:[WeightFormatters selectedScaleIncrementIndex]
							 title:NSLocalizedString(@"SCALE_INCREMENT", nil)];
		
		BRTableSection *buttonSection = [[BRTableSection alloc] init];
		buttonSection.footerTitle = NSLocalizedString(@"NEW_DATABASE_DISMISS_FOOTER", nil);
		
		BRTableButtonRow *dismissRow = [[BRTableButtonRow alloc] init];
		dismissRow.title = NSLocalizedString(@"NEW_DATABASE_DISMISS", nil);
		dismissRow.target = self;
		dismissRow.action = @selector(dismissView:);
		[buttonSection addRow:dismissRow animated:NO];
		
		[self addSection:buttonSection animated:NO];
		[buttonSection release];
	}
	return self;
}


- (void)dismissView:(BRTableButtonRow *)sender {
	BRTableRadioSection *weightSection = (BRTableRadioSection *)[self sectionAtIndex:0];
	[WeightFormatters setSelectedWeightUnitIndex:weightSection.selectedIndex];
	
	BRTableRadioSection *energySection = (BRTableRadioSection *)[self sectionAtIndex:1];
	[WeightFormatters setSelectedEnergyUnitIndex:energySection.selectedIndex];
	
	BRTableRadioSection *incrementSection = (BRTableRadioSection *)[self sectionAtIndex:2];
	[WeightFormatters setSelectedScaleIncrementIndex:incrementSection.selectedIndex];

	EatWatchAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate removeLaunchView:self.view transitionType:kCATransitionPush subType:kCATransitionFromRight];
	[self autorelease];
}

@end
