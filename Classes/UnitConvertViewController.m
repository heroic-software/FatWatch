//
//  UnitConvertViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/24/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "UnitConvertViewController.h"
#import "Database.h"

@implementation UnitConvertViewController

- (id)init
{
	if ([super initWithNibName:nil bundle:nil]) {
		self.title = NSLocalizedString(@"New Database", @"NewDatabaseViewController title");
	}
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadView 
{
	UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22+4*(44+22))];
	mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	mainView.autoresizesSubviews = YES;
	mainView.backgroundColor = [UIColor lightGrayColor];
	
	CGRect viewFrame = CGRectMake(22, 22, 320-44, 44);
	
	NSString *message = 
	@"You have changed your preferred weight units from %1$@ to %2$@. "
	@"You can convert existing values from %1$@ to %2$@, "
	@"reinterpret the existing values as %2$@, "
	@"or cancel the change to stay with %1$@ and leave your data untouched.";
	
	NSString *dataUnit = EWStringFromWeightUnit([[Database sharedDatabase] weightUnit]);
	NSString *prefUnit = EWStringFromWeightUnit([[NSUserDefaults standardUserDefaults] integerForKey:@"WeightUnit"]);
	
	UILabel *helpLabel = [[UILabel alloc] initWithFrame:viewFrame];
	helpLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	helpLabel.text = [NSString stringWithFormat:message, dataUnit, prefUnit];
	helpLabel.numberOfLines = 0;
	helpLabel.backgroundColor = mainView.backgroundColor;
	[mainView addSubview:helpLabel];
	[helpLabel release];

	NSString *titles[] = { @"Convert", @"Reinterpret", @"Cancel" };
	SEL actions[] = { @selector(convertAction), @selector(reinterpretAction), @selector(cancelAction) };
	int i;
	for (i = 0; i < 3; i++) {
		viewFrame.origin.y += viewFrame.size.height + 22;
		UIButton *button = [UIButton buttonWithType:UIButtonTypeGlass];
		[button setTitle:titles[i] forState:UIControlStateNormal];
		[button addTarget:self action:actions[i] forControlEvents:UIControlEventTouchUpInside];
		button.frame = viewFrame;
		button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		[mainView addSubview:button];
	}
	
	self.view = mainView;
	[mainView release];
}

- (void)convertAction
{
	// ought to do some math here
	EWWeightUnit newUnit = [[NSUserDefaults standardUserDefaults] integerForKey:@"WeightUnit"];
	double factor;
	if (newUnit == kWeightUnitPounds) {
		factor = 1 / kPoundsPerKilogram;
	} else {
		factor = kPoundsPerKilogram;
	}
	Database *database = [Database sharedDatabase];
	sqlite3_stmt *statement = [database statementFromSQL:"UPDATE weight SET measuredValue = measuredValue * ?, trendValue = trendValue * ?"];
	sqlite3_bind_double(statement, 1, factor);
	sqlite3_bind_double(statement, 2, factor);
	int code = sqlite3_step(statement);
	NSAssert1(code == SQLITE_DONE, @"UPDATE failed: %d", code);
	sqlite3_finalize(statement);
	[database setWeightUnit:newUnit];
	[database flushCache];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)reinterpretAction
{
	EWWeightUnit defaultsWeightUnit = [[NSUserDefaults standardUserDefaults] integerForKey:@"WeightUnit"];
	[[Database sharedDatabase] setWeightUnit:defaultsWeightUnit];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)cancelAction
{
	EWWeightUnit databaseWeightUnit = [[Database sharedDatabase] weightUnit];
	[[NSUserDefaults standardUserDefaults] setInteger:databaseWeightUnit forKey:@"WeightUnit"];
	[self dismissModalViewControllerAnimated:YES];
}

@end
