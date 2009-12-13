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
		[self addSectionForStrings:[WeightFormatters weightUnitNames] 
					 selectedIndex:[WeightFormatters selectedWeightUnitIndex]
							 title:NSLocalizedString(@"Weight Unit", nil)];
		[self addSectionForStrings:[WeightFormatters energyUnitNames] 
					 selectedIndex:[WeightFormatters selectedEnergyUnitIndex]
							 title:NSLocalizedString(@"Energy Unit", nil)];
		[self addSectionForStrings:[WeightFormatters scaleIncrementNames]
					 selectedIndex:[WeightFormatters selectedScaleIncrementIndex]
							 title:NSLocalizedString(@"Scale Precision", nil)];
		
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
	BRTableRadioSection *weightSection = (BRTableRadioSection *)[self sectionAtIndex:0];
	[WeightFormatters setSelectedWeightUnitIndex:weightSection.selectedIndex];
	
	BRTableRadioSection *energySection = (BRTableRadioSection *)[self sectionAtIndex:1];
	[WeightFormatters setSelectedEnergyUnitIndex:energySection.selectedIndex];
	
	BRTableRadioSection *incrementSection = (BRTableRadioSection *)[self sectionAtIndex:2];
	[WeightFormatters setSelectedScaleIncrementIndex:incrementSection.selectedIndex];

	id appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate removeLaunchView:self.view transitionType:kCATransitionPush subType:kCATransitionFromRight];
	[self autorelease]; // TODO handle this a better way
}

@end
