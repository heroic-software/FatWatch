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
#import "MicroWebServer.h"
#import "WebServerDelegate.h"

@implementation EatWatchAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	EWDateInit();
	[[Database sharedDatabase] open];
	
	LogViewController *logView = [[[LogViewController alloc] init] autorelease];
	TrendViewController *trendView = [[[TrendViewController alloc] init] autorelease];
	GraphViewController *graphView = [[[GraphViewController alloc] init] autorelease];

	UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
	tabBarController.viewControllers = [NSArray arrayWithObjects:logView, trendView, nil];

	rootViewController = [[RootViewController alloc] init];
	rootViewController.portraitViewController = tabBarController;
	rootViewController.landscapeViewController = graphView;
	
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window addSubview:rootViewController.view];
    [window makeKeyAndVisible];
	
	MicroWebServer *webServer = [MicroWebServer sharedServer];
	webServer.name = @"EatWatch";
	webServer.delegate = [[WebServerDelegate alloc] init];
	[webServer start];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	[[MicroWebServer sharedServer] stop];
	[[[MicroWebServer sharedServer] delegate] release];
	[[Database sharedDatabase] close];
}


- (void)dealloc {
    [window release];
    [rootViewController release];
    [super dealloc];
}

@end
