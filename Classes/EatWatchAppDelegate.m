//
//  EatWatchAppDelegate.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/15/08.
//  Copyright Benjamin Ragheb 2008. All rights reserved.
//

#import "EatWatchAppDelegate.h"

#import "Database.h"
#import "LogViewController.h"
#import "TrendViewController.h"
#import "GraphViewController.h"

@implementation EatWatchAppDelegate

@synthesize window;
@synthesize tabBarController;

- init {
	if ([super init]) {
		database = [[Database alloc] init];
	}
	return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	LogViewController *logView = [[[LogViewController alloc] initWithDatabase:database] autorelease];
	GraphViewController *graphView = [[[GraphViewController alloc] init] autorelease];
	TrendViewController *trendView = [[[TrendViewController alloc] init] autorelease];

	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:logView];
	
	self.tabBarController = [[UITabBarController alloc] init];
	tabBarController.viewControllers = [NSArray arrayWithObjects:navController, graphView, trendView, nil];

	[navController release];

	// Create window
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	[window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[database release];
}

- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end
