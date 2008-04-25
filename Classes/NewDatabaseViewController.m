//
//  NewDatabaseViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/24/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "NewDatabaseViewController.h"
#import "Database.h"

@implementation NewDatabaseViewController

- (id)initWithDatabase:(Database *)db
{
	if ([super initWithNibName:nil bundle:nil]) {
		self.title = NSLocalizedString(@"New Database", @"NewDatabaseViewController title");
		database = db;
	}
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadView 
{
	UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22+3*(44+22))];
	mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	mainView.backgroundColor = [UIColor lightGrayColor];
	
	CGRect viewFrame = CGRectMake(22, 22, 320-44, 44);

	UILabel *helpLabel = [[UILabel alloc] initWithFrame:viewFrame];
	helpLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	helpLabel.contentMode = UIViewContentModeTop;
	helpLabel.text = @"This is a new database.  Choose a weight unit.  You can change your mind in the Settings app.";
	helpLabel.numberOfLines = 0;
	[mainView addSubview:helpLabel];
	[helpLabel release];
	
	EWWeightUnit units[] = { kWeightUnitPounds, kWeightUnitKilograms };
	int i;
	for (i = 0; i < 2; i++) {
		viewFrame.origin.y += viewFrame.size.height + 22;
		UIButton *button = [UIButton buttonWithType:UIButtonTypeGlass];
		[button setTitle:EWStringFromWeightUnit(units[i]) forState:UIControlStateNormal];
		[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		button.tag = units[i];
		button.frame = viewFrame;
		button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		[mainView addSubview:button];
	}

	self.view = mainView;
	[mainView release];
}

- (void)buttonAction:(UIButton *)button
{
	EWWeightUnit newWeightUnit = [button tag];
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];

	[database setWeightUnit:newWeightUnit];
	[defs setInteger:newWeightUnit forKey:@"WeightUnit"];

	if ([defs integerForKey:@"EnergyUnit"] == 0) {
		switch (newWeightUnit) {
			case kWeightUnitPounds: [defs setInteger:kEnergyUnitCalories forKey:@"EnergyUnit"]; break;
			case kWeightUnitKilograms: [defs setInteger:kEnergyUnitKilojoules forKey:@"EnergyUnit"]; break;
		}
	}
	[self dismissModalViewControllerAnimated:YES];
}

@end
