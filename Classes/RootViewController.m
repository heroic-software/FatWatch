//
//  RootViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/12/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "RootViewController.h"


static BOOL autorotationDisabled = NO;


@implementation RootViewController

@synthesize portraitViewController;
@synthesize landscapeViewController;


+ (void)setAutorotationEnabled:(BOOL)flag {
	autorotationDisabled = !flag;
}


- (void)loadView {
	UIView *rootView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	rootView.autoresizingMask = (UIViewAutoresizingFlexibleHeight |
								 UIViewAutoresizingFlexibleWidth);
	rootView.autoresizesSubviews = YES;
	rootView.backgroundColor = [UIColor blackColor];

	currentViewController = portraitViewController;
	
	[rootView addSubview:currentViewController.view];
	
	self.view = [rootView autorelease];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[currentViewController viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[currentViewController viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[currentViewController viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[currentViewController viewDidDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (autorotationDisabled) return NO;
	// Never autorotate if a modal view controller is visible.
	if ([currentViewController modalViewController]) return NO;
	
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			return YES;
		default:
			return NO;
	}
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[currentViewController viewWillDisappear:YES];
	[currentViewController.view removeFromSuperview];
	UIStatusBarStyle style;
	if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
		style = UIStatusBarStyleDefault;
		currentViewController = portraitViewController;
	} else {
		style = UIStatusBarStyleBlackOpaque;
		currentViewController = landscapeViewController;
	}
	[[UIApplication sharedApplication] setStatusBarStyle:style animated:YES];
	[currentViewController viewWillAppear:YES];
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[animation setDuration:duration];
	[[self.view layer] addAnimation:animation forKey:kCATransition];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	currentViewController.view.frame = self.view.bounds;
	[self.view addSubview:currentViewController.view];
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[animation setDuration:0.2];
	[animation setDelegate:self];
	[[self.view layer] addAnimation:animation forKey:kCATransition];
}


- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		[landscapeViewController viewDidDisappear:YES];
		[portraitViewController viewDidAppear:YES];
	} else {
		[portraitViewController viewDidDisappear:YES];
		[landscapeViewController viewDidAppear:YES];
	}
}	


- (void)dealloc {
	[portraitViewController release];
	[landscapeViewController release];
	[super dealloc];
}


@end
