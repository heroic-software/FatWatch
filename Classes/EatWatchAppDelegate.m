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
#import "EWDatabase.h"
#import "EWDBMonth.h"
#import "LogEntryViewController.h"

#import "NewDatabaseViewController.h"
#import "PasscodeEntryViewController.h"
#import "RootViewController.h"

#import "LogViewController.h"
#import "TrendViewController.h"
#import "GoalViewController.h"
#import "MoreViewController.h"

#import "GraphViewController.h"


static NSString *kWeightDatabaseName = @"WeightData.db";
static NSString *kSelectedTabIndex = @"SelectedTabIndex";


@implementation EatWatchAppDelegate


- (void)registerDefaults {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
	NSAssert(path != nil, @"registration domain defaults plist is missing");
	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
	[[NSUserDefaults standardUserDefaults] registerDefaults:dict];
	[dict release];
}


- (NSString *)pathOfDatabase {
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSAssert([paths count], @"Failed to find Documents directory.");
    NSString *documentsDirectory = [paths objectAtIndex:0];

	// Workaround for Beta issue where Documents directory is not created during install.
    if (! [fileManager fileExistsAtPath:documentsDirectory]) {
        BOOL success = [fileManager createDirectoryAtPath:documentsDirectory attributes:nil];
		NSAssert(success, @"Failed to create Documents directory.");
    }
    
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:kWeightDatabaseName];
	
	if (! [fileManager fileExistsAtPath:databasePath]) {
		NSLog(@"Database file not found, creating a new database.");
		// The writable database does not exist, so copy the template to the appropriate location.
		NSString *templatePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kWeightDatabaseName];
		success = [fileManager copyItemAtPath:templatePath toPath:databasePath error:&error];
		NSAssert1(success, @"Failed to create database: %@", [error localizedDescription]);
	}

	return databasePath;
}


- (void)autoWeighInIfEnabled {
	if (! [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoWeighIn"]) return;
	
	EWMonthDay today = EWMonthDayToday();
	EWDBMonth *data = [[EWDatabase sharedDatabase] getDBMonth:EWMonthDayGetMonth(today)];
	EWDay day = EWMonthDayGetDay(today);
	if (![data hasDataOnDay:day]) {
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
	
	UINavigationController *goalNavController = [[[UINavigationController alloc] initWithRootViewController:goalController] autorelease];
	
	UINavigationController *moreNavController = [[[UINavigationController alloc] initWithRootViewController:moreController] autorelease];
	
	UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
	tabBarController.delegate = self;
	tabBarController.viewControllers = [NSArray arrayWithObjects:logController, trendController, goalNavController, moreNavController, nil];

	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	tabBarController.selectedIndex = [defs integerForKey:kSelectedTabIndex];
	
	rootViewController = [[RootViewController alloc] init];
	rootViewController.portraitViewController = tabBarController;
	rootViewController.landscapeViewController = graphController;
	
	[window addSubview:rootViewController.view];
	
	[self autoWeighInIfEnabled];
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



- (void)dealloc {
    [window release];
    [rootViewController release];
    [super dealloc];
}


#pragma mark UIApplicationDelegate


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[self registerDefaults];
	EWDatabase *db = [EWDatabase sharedDatabase];
	[db openFile:[self pathOfDatabase]];
	// TODO: open modal view to show upgrade progress
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	if ([PasscodeEntryViewController authorizationRequired]) {
		UIViewController *passcodeController = [PasscodeEntryViewController controllerForAuthorization];
		passcodeController.view.frame = [[UIScreen mainScreen] applicationFrame];
		[window addSubview:passcodeController.view];
	} else if ([[EWDatabase sharedDatabase] weightCount] == 0) {
		// This is a new data file.
		// Prompt user to choose weight unit.
		UIViewController *newDbController = [[NewDatabaseViewController alloc] init];
		[window addSubview:newDbController.view];
		// TODO: newDbController autoreleases itself in dismissView; should do better
	} else {
		[self setupRootView];
	}
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	[[EWDatabase sharedDatabase] close];
}


#pragma mark UITabBarControllerDelegate


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs setInteger:tabBarController.selectedIndex forKey:kSelectedTabIndex];
}


@end
