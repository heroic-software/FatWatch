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
#import "RootViewController.h"
#import "NewDatabaseViewController.h"
#import "MoreViewController.h"
#import "PasscodeEntryViewController.h"


@implementation EatWatchAppDelegate

- (void)registerDefaults {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
	NSAssert(path != nil, @"registration domain defaults plist is missing");
	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
	[[NSUserDefaults standardUserDefaults] registerDefaults:dict];
	[dict release];
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[self registerDefaults];
	
	EWDateInit();
	[[Database sharedDatabase] open];
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	if ([[Database sharedDatabase] weightCount] == 0) {
		// This is a new data file.
		// Prompt user to choose weight unit.
		NewDatabaseViewController *newDbController = [[NewDatabaseViewController alloc] init];
		[window addSubview:newDbController.view];
	} else if ([PasscodeEntryViewController authorizationRequired]) {
		PasscodeEntryViewController *passcodeController = [[PasscodeEntryViewController alloc] init];
		passcodeController.view.frame = [[UIScreen mainScreen] applicationFrame];
		[window addSubview:passcodeController.view];
	} else {
		[self setupRootView];
	}
    [window makeKeyAndVisible];
}


- (void)setupRootView {
	LogViewController *logController = [[[LogViewController alloc] init] autorelease];
	TrendViewController *trendController = [[[TrendViewController alloc] init] autorelease];
	GraphViewController *graphController = [[[GraphViewController alloc] init] autorelease];
	MoreViewController *moreController = [[[MoreViewController alloc] init] autorelease];
	
	UINavigationController *logNavController = [[[UINavigationController alloc] initWithRootViewController:logController] autorelease];
	
	UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
	tabBarController.viewControllers = [NSArray arrayWithObjects:logNavController, trendController, moreController, nil];
	
	rootViewController = [[RootViewController alloc] init];
	rootViewController.portraitViewController = tabBarController;
	rootViewController.landscapeViewController = graphController;
	
	[window addSubview:rootViewController.view];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	[[Database sharedDatabase] close];
}


- (void)dealloc {
    [window release];
    [rootViewController release];
    [super dealloc];
}

@end
