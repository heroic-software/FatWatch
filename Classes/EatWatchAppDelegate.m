//
//  EatWatchAppDelegate.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/15/08.
//  Copyright Benjamin Ragheb 2008. All rights reserved.
//

#import "EatWatchAppDelegate.h"
#import "LogViewController.h"
#import "TrendViewController.h"
#import "GraphViewController.h"

@implementation EatWatchAppDelegate

@synthesize window;
@synthesize tabBarController;

- init {
	if (self = [super init]) {
		// Your initialization code here
	}
	return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	self.tabBarController = [[UITabBarController alloc] init];
	id item1 = [[[LogViewController alloc] init] autorelease];
	id item2 = [[[GraphViewController alloc] init] autorelease];
	id item3 = [[[TrendViewController alloc] init] autorelease];
	tabBarController.viewControllers = [NSArray arrayWithObjects:item1, item2, item3, nil];

	// Create window
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	[window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
}

- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end
