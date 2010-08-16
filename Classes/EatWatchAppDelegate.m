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
#import "NSUserDefaults+EWAdditions.h"


#define DEBUG_LAUNCH_ACTIONS_ENABLED 0


static NSString *kWeightDatabaseName = @"WeightData.db";
static NSString *kSelectedTabIndex = @"SelectedTabIndex";


@interface EatWatchAppDelegate ()
- (NSString *)databasePath;
@end




@implementation EatWatchAppDelegate


@synthesize rootViewController;


#if DEBUG_LAUNCH_ACTIONS_ENABLED
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
			NSLog(@"Unable to delete database: %@", [error localizedDescription]);
		}
		[ud removeObjectForKey:kResetDatabaseKey];

		NSString *fakeDatabasePath = [[NSBundle mainBundle] pathForResource:@"FakeUpgrade" ofType:@"db"];
		if (fakeDatabasePath) {
			if ([fileManager copyItemAtPath:fakeDatabasePath toPath:[self databasePath] error:&error]) {
				NSLog(@"Using fake database: %@", fakeDatabasePath);
			} else {
				NSLog(@"Unable to copy database: %@", [error localizedDescription]);
			}
		}
	}

	if (resetDefaults) {
		NSArray *keys = [[[ud dictionaryRepresentation] allKeys] copy];
		for (NSString *key in keys) {
			[ud removeObjectForKey:key];
		}
		NSLog(@"%d defaults deleted by request.", [keys	count]);
		[keys release];
		
		NSString *fakeDefaultsPath = [[NSBundle mainBundle] pathForResource:@"FakeUpgrade" ofType:@"plist"];
		if (fakeDefaultsPath) {
			NSDictionary *fakeDefaults = [[NSDictionary alloc] initWithContentsOfFile:fakeDefaultsPath];
			for (NSString *key in fakeDefaults) {
				id value = [fakeDefaults objectForKey:key];
				[ud setObject:value forKey:key];
				NSLog(@"Fake Preference: %@: %@", key, value);
			}
			[fakeDefaults release];
		}
	}
}
#endif


- (void)registerDefaults {
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	if ([defs firstLaunchDate] == nil) [defs setFirstLaunchDate];
	[defs registerDefaultsNamed:@"Defaults"];
	[defs registerDefaultsNamed:@"MoreDefaults"];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ColorPalette" ofType:@"plist"];
	[[BRColorPalette sharedPalette] addColorsFromFile:path];
}


- (NSString *)databasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSAssert([paths count], @"Failed to find Documents directory.");
    NSString *documentsDirectory = [paths objectAtIndex:0];
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
	EWDBMonth *dbm = [db getDBMonth:EWMonthDayGetMonth(today)];
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
	NSDictionary *externals = [NSDictionary dictionaryWithObject:db forKey:@"Database"];
	NSDictionary *options = [NSDictionary dictionaryWithObject:externals forKey:UINibExternalObjects];
	[[NSBundle mainBundle] loadNibNamed:@"RootView" owner:self options:options];

	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	lastTapTabIndex = [defs integerForKey:kSelectedTabIndex];
	UITabBarController *tabBarController = (id)rootViewController.portraitViewController;
	tabBarController.selectedIndex = lastTapTabIndex;

	[self addViewToWindow:rootViewController.view];
	[self autoWeighInIfEnabled];
}


- (void)continuePostLaunch {
	// Won't get here until passcode authorized.
	
	// Haven't loaded the DB yet.
	if (db == nil) {
		db = [[EWDatabase alloc] initWithFile:[self ensureDatabasePath]];
		if ([db needsUpgrade]) {
			launchViewController = [[UpgradeViewController alloc] initWithDatabase:db];
			[self addViewToWindow:launchViewController.view];
		}
		if (launchViewController) return;
	}
	
	if ([db isEmpty] && !readyToGo) {
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


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

#if DEBUG_LAUNCH_ACTIONS_ENABLED
	[self performDebugLaunchActions];
#endif

	[self registerDefaults];
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	if ([PasscodeEntryViewController authorizationRequired]) {
		launchViewController = [[PasscodeEntryViewController controllerForAuthorization] retain];
		[self addViewToWindow:launchViewController.view];
	} else {
		[self continuePostLaunch];
	}
	
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	[db close];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	[db reopen];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	[db close];
}


#pragma mark UITabBarControllerDelegate


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	NSUInteger thisTapTabIndex = tabBarController.selectedIndex;
	
	if (lastTapTabIndex != thisTapTabIndex) {
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		[defs setInteger:tabBarController.selectedIndex forKey:kSelectedTabIndex];
		lastTapTabIndex = thisTapTabIndex;
		lastTapTime = [NSDate timeIntervalSinceReferenceDate];
	} else {
		NSTimeInterval thisTapTime = [NSDate timeIntervalSinceReferenceDate];
		if (thisTapTime - lastTapTime < 0.3) {
			if ([viewController respondsToSelector:@selector(tabBarItemDoubleTapped)]) {
				[viewController tabBarItemDoubleTapped];
			}
		}
		lastTapTime = thisTapTime;
	}
}


#pragma mark Cleanup


- (void)dealloc {
	[db release];
    [window release];
    [rootViewController release];
	[launchViewController release];
    [super dealloc];
}


@end
