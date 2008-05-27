//
//  NewDatabaseViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/24/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NewDatabaseViewController.h"
#import "Database.h"
#import "WeightFormatter.h"
#import "EatWatchAppDelegate.h"

@implementation NewDatabaseViewController

- (id)init {
	if ([super initWithNibName:nil bundle:nil]) {
		self.title = NSLocalizedString(@"NEW_DATABASE_VIEW_TITLE", nil);
	}
	return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}


- (void)loadView {
	UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	mainView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	NSArray *weightUnitNames = [WeightFormatter weightUnitNames];
	int i;
	
	CGFloat y = CGRectGetMaxY(mainView.bounds) - 22;

	for (i = [weightUnitNames count] - 1; i >= 0; i--) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[button setTitle:[weightUnitNames objectAtIndex:i] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		button.tag = i;
		button.frame = CGRectMake(22, y-44, 320-44, 44);
		[mainView addSubview:button];
		y -= 66;
	}
	
	UILabel *helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 22, 320-44, y-22)];
	helpLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	helpLabel.contentMode = UIViewContentModeTop;
	helpLabel.text = NSLocalizedString(@"NEW_DATABASE_TEXT", nil);
	helpLabel.numberOfLines = 0;
	[mainView addSubview:helpLabel];
	[helpLabel release];

	self.view = mainView;
	[mainView release];
}


- (void)buttonAction:(UIButton *)button {
	[WeightFormatter setWeightUnit:[button tag]];
	EatWatchAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	UIView *window = self.view.superview;
	
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[animation setDuration:0.3];
	
	[self.view removeFromSuperview];
	[appDelegate setupRootView];

	[[window layer] addAnimation:animation forKey:nil];
	
	[self autorelease];
}

@end
