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
#import "MonthData.h"
#import "LogEntryViewController.h"

#import "NewDatabaseViewController.h"
#import "PasscodeEntryViewController.h"
#import "RootViewController.h"

#import "LogViewController.h"
#import "TrendViewController.h"
#import "GoalViewController.h"
#import "MoreViewController.h"

#import "GraphViewController.h"


NSString *kSelectedTabIndex = @"SelectedTabIndex";


@implementation EatWatchAppDelegate

- (void)registerDefaults {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
	NSAssert(path != nil, @"registration domain defaults plist is missing");
	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
	[[NSUserDefaults standardUserDefaults] registerDefaults:dict];
	[dict release];
}


- (void)autoWeighInIfEnabled {
	if (! [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoWeighIn"]) return;
	
	EWMonthDay today = EWMonthDayFromDate([NSDate date]);
	MonthData *data = [[Database sharedDatabase] dataForMonth:EWMonthDayGetMonth(today)];
	EWDay day = EWMonthDayGetDay(today);
	if ([data measuredWeightOnDay:day] == 0) {
		LogEntryViewController *controller = [LogEntryViewController sharedController];
		controller.monthData = data;
		controller.day = day;
		controller.weighIn = YES;
		[rootViewController.portraitViewController presentModalViewController:controller animated:NO];
	}
}


- (void)setupRootView {
	UIViewController *logController = [[[LogViewController alloc] init] autorelease];
	UIViewController *trendController = [[[TrendViewController alloc] init] autorelease];
	UIViewController *moreController = [[[MoreViewController alloc] init] autorelease];
	UIViewController *goalController = [[[GoalViewController alloc] init] autorelease];
	UIViewController *graphController = [[[GraphViewController alloc] init] autorelease];

	UINavigationController *logNavController = [[[UINavigationController alloc] initWithRootViewController:logController] autorelease];
	
	UINavigationController *goalNavController = [[[UINavigationController alloc] initWithRootViewController:goalController] autorelease];
	
	UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
	tabBarController.viewControllers = [NSArray arrayWithObjects:logNavController, trendController, goalNavController, moreController, nil];

	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	tabBarController.selectedIndex = [defs integerForKey:kSelectedTabIndex];
	
	rootViewController = [[RootViewController alloc] init];
	rootViewController.portraitViewController = tabBarController;
	rootViewController.landscapeViewController = graphController;
	
	[window addSubview:rootViewController.view];
	
	[self autoWeighInIfEnabled];
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[self registerDefaults];
	
	[[Database sharedDatabase] open];
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	if ([PasscodeEntryViewController authorizationRequired]) {
		UIViewController *passcodeController = [PasscodeEntryViewController controllerForAuthorization];
		passcodeController.view.frame = [[UIScreen mainScreen] applicationFrame];
		[window addSubview:passcodeController.view];
	} else if ([[Database sharedDatabase] weightCount] == 0) {
		// This is a new data file.
		// Prompt user to choose weight unit.
		UIViewController *newDbController = [[NewDatabaseViewController alloc] init];
		[window addSubview:newDbController.view];
	} else {
		[self setupRootView];
	}
    [window makeKeyAndVisible];
}


- (void)removeLaunchView:(UIView *)launchView transitionType:(NSString *)type subType:(NSString *)subType {
	CATransition *animation = [CATransition animation];
	[animation setType:type];
	[animation setSubtype:subType];
	[animation setDuration:0.3];
	
	[launchView removeFromSuperview];
	[self setupRootView];
	
	[[window layer] addAnimation:animation forKey:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	[[Database sharedDatabase] close];
	
	UITabBarController *tabBarController = (id)rootViewController.portraitViewController;
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs setInteger:tabBarController.selectedIndex forKey:kSelectedTabIndex];
}


- (void)dealloc {
    [window release];
    [rootViewController release];
    [super dealloc];
}

@end
