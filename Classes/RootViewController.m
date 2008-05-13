//
//  RootViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/12/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "RootViewController.h"


@implementation RootViewController

@synthesize portraitViewController;
@synthesize landscapeViewController;


- (id)init {
	return [super initWithNibName:nil bundle:nil];
}


- (void)loadView {
	UIView *rootView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	rootView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	rootView.autoresizesSubviews = YES;

	currentViewController = portraitViewController;
	
	[rootView addSubview:currentViewController.view];
	
	self.view = [rootView autorelease];
}


- (void)viewWillAppear:(BOOL)animated {
	[currentViewController viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
	[currentViewController viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
	[currentViewController viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated {
	[currentViewController viewDidDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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


- (void)replaceView:(UIViewController *)oldViewController 
		   withView:(UIViewController *)newViewController duration:(NSTimeInterval)duration {
	if ([oldViewController.view superview]) {
		[oldViewController viewWillDisappear:YES];
		[newViewController viewWillAppear:YES];
		
		[oldViewController.view removeFromSuperview];
		newViewController.view.frame = self.view.bounds;
		[self.view addSubview:newViewController.view];

		currentViewController = newViewController;

		CATransition *animation = [CATransition animation];
		[animation setType:kCATransitionFade];
		[animation setDuration:duration];
		[[self.view layer] addAnimation:animation forKey:@"RotationAnimation"];
	}
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	switch (toInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			[self replaceView:landscapeViewController withView:portraitViewController duration:duration];
			return;
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			[self replaceView:portraitViewController withView:landscapeViewController duration:duration];
			return;
	}
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		[portraitViewController viewDidDisappear:YES];
		[landscapeViewController viewDidAppear:YES];
	} else {
		[landscapeViewController viewDidDisappear:YES];
		[portraitViewController viewDidAppear:YES];
	}
}


- (void)dealloc {
	[portraitViewController release];
	[landscapeViewController release];
	[super dealloc];
}


@end
