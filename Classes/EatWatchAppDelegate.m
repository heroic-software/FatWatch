//
//  EatWatchAppDelegate.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/15/08.
//  Copyright Benjamin Ragheb 2008. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EatWatchAppDelegate.h"

#import "EWDate.h"
#import "Database.h"
#import "LogViewController.h"
#import "TrendViewController.h"
#import "GraphViewController.h"

@implementation EatWatchAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	EWDateInit();
	
	graphView = [[GraphViewController alloc] init];

	LogViewController *logView = [[[LogViewController alloc] init] autorelease];
	TrendViewController *trendView = [[[TrendViewController alloc] init] autorelease];

	tabBarController = [[UITabBarController alloc] init];
	tabBarController.viewControllers = [NSArray arrayWithObjects:logView, trendView, nil];

	// Create window
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceOrientationDidChange:)
												 name:UIDeviceOrientationDidChangeNotification 
											   object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[Database sharedDatabase] close];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
	UIDeviceOrientation devOrientation = [[UIDevice currentDevice] orientation];
	
	if ([tabBarController modalViewController] != nil) return;
	
	UIApplication *app = [UIApplication sharedApplication];
	UIInterfaceOrientation intOrientation = [app statusBarOrientation];
	
	if (devOrientation == UIDeviceOrientationPortrait) {
		if (intOrientation == UIInterfaceOrientationPortrait) return;
		[app setStatusBarHidden:YES];
		[graphView.view removeFromSuperview];
		[window addSubview:tabBarController.view];
	} else if (UIDeviceOrientationIsLandscape(devOrientation)) {
		UIView *view = graphView.view;
		if (devOrientation == UIDeviceOrientationLandscapeLeft) {
			if (intOrientation == UIInterfaceOrientationLandscapeRight) return;
			view.frame = CGRectMake(0, 0, 300, 480);
			view.transform = CGAffineTransformMakeRotation(+M_PI_2);
		} else {
			if (intOrientation == UIInterfaceOrientationLandscapeLeft) return;
			view.frame = CGRectMake(20, 0, 300, 480);
			view.transform = CGAffineTransformMakeRotation(-M_PI_2);
		}
		view.bounds = CGRectMake(0, 0, 480, 300);
		[app setStatusBarHidden:YES];
		[tabBarController.view removeFromSuperview];
		[window addSubview:view];
	} else {
		return;
	}
		
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setType:kCATransitionFade];
	[animation setDuration:0.5];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	[[window layer] addAnimation:animation forKey:@"Switcheroo"];

	UIInterfaceOrientation newIntOrientation;

	switch (devOrientation) {
		case UIDeviceOrientationPortrait:
			newIntOrientation = UIInterfaceOrientationPortrait;
			break;
		case UIDeviceOrientationLandscapeLeft:
			newIntOrientation = UIInterfaceOrientationLandscapeRight;
			break;
		case UIDeviceOrientationLandscapeRight:
			newIntOrientation = UIInterfaceOrientationLandscapeLeft;
			break;
	}
	[app setStatusBarOrientation:newIntOrientation]; 
	[app setStatusBarHidden:NO];
}


@end
