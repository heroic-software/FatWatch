//
//  EatWatchAppDelegate.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/15/08.
//  Copyright Benjamin Ragheb 2008. All rights reserved.
//

#import "BRColorPalette.h"
#import "EWDBMonth.h"
#import "EWDatabase.h"
#import "EWDate.h"
#import "EatWatchAppDelegate.h"
#import "GoalViewController.h"
#import "GraphViewController.h"
#import "LogEntryViewController.h"
#import "LogViewController.h"
#import "MoreViewController.h"
#import "NewDatabaseViewController.h"
#import "PasscodeEntryViewController.h"
#import "RootViewController.h"
#import "TrendViewController.h"
#import "UpgradeViewController.h"


static NSString *kWeightDatabaseName = @"WeightData.db";
static NSString *kSelectedTabIndex = @"SelectedTabIndex";


@interface EatWatchAppDelegate ()
- (NSString *)databasePath;
@end




@implementation EatWatchAppDelegate


- (void)performDebugLaunchActions {
	static NSString * const kResetDatabaseKey = @"OnLaunchResetDatabase";
	static NSString * const kResetDefaultsKey = @"OnLaunchResetDefaults";
	
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	
	BOOL resetDatabase = [ud boolForKey:kResetDatabaseKey];
	BOOL resetDefaults = [ud boolForKey:kResetDefaultsKey];

	if (resetDatabase) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error;

		if ([fileManager removeItemAtPath:[self databasePath] error:&error]) {
			NSLog(@"Database deleted by request.");
		} else {
			NSLog(@"Unable to delete database per request: %@", 
				  [error localizedDescription]);
		}

		[ud removeObjectForKey:kResetDatabaseKey];
	}

	if (resetDefaults) {
		NSArray *keys = [[[ud dictionaryRepresentation] allKeys] copy];
		for (NSString *key in keys) {
			[ud removeObjectForKey:key];
		}
		NSLog(@"%d defaults deleted by request.", [keys	count]);
		[keys release];
	}
}


- (void)registerDefaultsNamed:(NSString *)name {
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
	NSAssert1(path != nil, @"registration domain defaults plist '%@' is missing", name);
	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
	[[NSUserDefaults standardUserDefaults] registerDefaults:dict];
	[dict release];
}


- (void)registerDefaults {
	[self registerDefaultsNamed:@"Defaults"];
	[self registerDefaultsNamed:@"MoreDefaults"];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ColorPalette" ofType:@"plist"];
	[[BRColorPalette sharedPalette] addColorsFromFile:path];
}


- (NSString *)databasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSAssert([paths count], @"Failed to find Documents directory.");
    NSString *documentsDirectory = [paths objectAtIndex:0];

	// Workaround for Beta issue where Documents directory is not created during install.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (! [fileManager fileExistsAtPath:documentsDirectory]) {
        BOOL success = [fileManager createDirectoryAtPath:documentsDirectory attributes:nil];
		NSAssert(success, @"Failed to create Documents directory.");
    }
    
	return [documentsDirectory stringByAppendingPathComponent:kWeightDatabaseName];
}



- (NSString *)ensureDatabasePath {
	NSString *databasePath = [self databasePath];
    
	BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;

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
	EWDBMonth *dbm = [[EWDatabase sharedDatabase] getDBMonth:EWMonthDayGetMonth(today)];
	EWDay day = EWMonthDayGetDay(today);
	if (![dbm hasDataOnDay:day]) {
		LogEntryViewController *controller = [LogEntryViewController sharedController];
		[controller configureForDay:day dbMonth:dbm];
		[rootViewController.portraitViewController presentModalViewController:controller animated:NO];
	}
}


- (void)addViewToWindow:(UIView *)view {
	view.frame = [[UIScreen mainScreen] applicationFrame];
	[window addSubview:view];
}


- (void)setupRootView {
	UIViewController *logController = [[[LogViewController alloc] init] autorelease];
	UIViewController *trendController = [[[TrendViewController alloc] init] autorelease];
	UIViewController *moreController = [[[MoreViewController alloc] init] autorelease];
	UIViewController *goalController = [[[GoalViewController alloc] init] autorelease];
	UIViewController *graphController = [[[GraphViewController alloc] init] autorelease];
	
	UINavigationController *trendNavController = [[[UINavigationController alloc] initWithRootViewController:trendController] autorelease];
	
	UINavigationController *goalNavController = [[[UINavigationController alloc] initWithRootViewController:goalController] autorelease];
	
	UINavigationController *moreNavController = [[[UINavigationController alloc] initWithRootViewController:moreController] autorelease];
	
	UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
	tabBarController.delegate = self;
	tabBarController.viewControllers = [NSArray arrayWithObjects:logController, trendNavController, goalNavController, moreNavController, nil];

	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	tabBarController.selectedIndex = [defs integerForKey:kSelectedTabIndex];
	
	rootViewController = [[RootViewController alloc] init];
	rootViewController.portraitViewController = tabBarController;
	rootViewController.landscapeViewController = graphController;
	
	[self addViewToWindow:rootViewController.view];
	
	[self autoWeighInIfEnabled];
}


- (void)continuePostLaunch {
	// Won't get here until passcode authorized.

	EWDatabase *db = [EWDatabase sharedDatabase];
	
	// Haven't loaded the DB yet.
	if (db == nil) {
		db = [[EWDatabase alloc] initWithFile:[self ensureDatabasePath]];
		if ([db needsUpgrade]) {
			launchViewController = [[UpgradeViewController alloc] initWithDatabase:db];
			[self addViewToWindow:launchViewController.view];
		} else {
			[EWDatabase setSharedDatabase:db];
		}
		[db release];
		if (launchViewController) return;
	}
	
	if (([db weightCount] == 0) && !readyToGo) {
		// Consider a new data file, prompt user for new units.
		launchViewController = [[NewDatabaseViewController alloc] init];
		[self addViewToWindow:launchViewController.view];
		readyToGo = YES;
	} else {
		[self setupRootView];
	}
}


- (void)removeLaunchViewWithTransitionType:(NSString *)type subType:(NSString *)subType {
	CATransition *animation = [CATransition animation];
	[animation setType:type];
	[animation setSubtype:subType];
	[animation setDuration:0.3];
	
	[launchViewController.view removeFromSuperview];
	[launchViewController autorelease];
	launchViewController = nil;

	[self continuePostLaunch];
	
	[[window layer] addAnimation:animation forKey:nil];
}



#pragma mark UIApplicationDelegate


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[self performDebugLaunchActions];

	[self registerDefaults];
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	if ([PasscodeEntryViewController authorizationRequired]) {
		launchViewController = [[PasscodeEntryViewController controllerForAuthorization] retain];
		[self addViewToWindow:launchViewController.view];
	} else {
		[self continuePostLaunch];
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


#pragma mark Cleanup


- (void)dealloc {
    [window release];
    [rootViewController release];
	[launchViewController release];
    [super dealloc];
}


@end
