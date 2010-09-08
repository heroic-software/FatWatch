//
//  EatWatchAppDelegate.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/15/08.
//  Copyright Benjamin Ragheb 2008. All rights reserved.
//

#import "BRColorPalette.h"
#import "DebugViewController.h"
#import "EWDBMonth.h"
#import "EWDatabase.h"
#import "EWDate.h"
#import "EatWatchAppDelegate.h"
#import "GoalViewController.h"
#import "GraphViewController.h"
#import "LogEntryViewController.h"
#import "LogViewController.h"
#import "MoreViewController.h"
#import "NSUserDefaults+EWAdditions.h"
#import "NewDatabaseViewController.h"
#import "PasscodeEntryViewController.h"
#import "RootViewController.h"
#import "TrendViewController.h"
#import "UpgradeViewController.h"


static NSString *kWeightDatabaseName = @"WeightData.db";
static NSString *kSelectedTabIndex = @"SelectedTabIndex";


@implementation EatWatchAppDelegate


@synthesize rootViewController;


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


- (void)launchStageDebug {
#if DEBUG_LAUNCH_STAGE_ENABLED
	launchViewController = [[DebugViewController alloc] init];
#endif
}


- (void)launchStageAuthorize {
	if ([PasscodeEntryViewController authorizationRequired]) {
		launchViewController = [[PasscodeEntryViewController controllerForAuthorization] retain];
	}
}


- (void)launchStageUpgrade {
	NSAssert(db == nil, @"DB already loaded before upgrade stage");
	db = [[EWDatabase alloc] initWithFile:[self ensureDatabasePath]];
	if ([db needsUpgrade]) {
		launchViewController = [[UpgradeViewController alloc] initWithDatabase:db];
	}
}


- (void)launchStageNewDatabase {
	if ([db isEmpty]) {
		// Consider a new data file, prompt user for new units.
		launchViewController = [[NewDatabaseViewController alloc] init];
	}
}


- (void)launchStageComplete {
	NSDictionary *externals = [NSDictionary dictionaryWithObject:db forKey:@"Database"];
	NSDictionary *options = [NSDictionary dictionaryWithObject:externals forKey:UINibExternalObjects];
	[[NSBundle mainBundle] loadNibNamed:@"RootView" owner:self options:options];
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	lastTapTabIndex = [defs integerForKey:kSelectedTabIndex];
	UITabBarController *tabBarController = (id)rootViewController.portraitViewController;
	tabBarController.selectedIndex = lastTapTabIndex;
	
	launchViewController = [rootViewController retain];
}


- (void)continueLaunchSequence {
	NSString *transitionType = nil;
	NSString *transitionSubtype = nil;
	
	if (launchViewController != nil) {
		[launchViewController.view removeFromSuperview];
		[launchViewController autorelease];
		launchViewController = nil;
		switch (launchStage) {
			case EWLaunchSequenceStageDebug:
			case EWLaunchSequenceStageAuthorize:
			case EWLaunchSequenceStageUpgrade:
				transitionType = kCATransitionReveal;
				transitionSubtype = kCATransitionFromTop;
				break;
			case EWLaunchSequenceStageNewDatabase:
				transitionType = kCATransitionPush;
				transitionSubtype = kCATransitionFromRight;
				break;
			case EWLaunchSequenceStageComplete:
				break;
		}
	}
	
	do {
		launchStage += 1;
		switch (launchStage) {
			case EWLaunchSequenceStageDebug: [self launchStageDebug]; break;
			case EWLaunchSequenceStageAuthorize: [self launchStageAuthorize]; break;
			case EWLaunchSequenceStageUpgrade: [self launchStageUpgrade]; break;
			case EWLaunchSequenceStageNewDatabase: [self launchStageNewDatabase]; break;
			case EWLaunchSequenceStageComplete: [self launchStageComplete]; break;
		}
	} while (launchViewController == nil);
	
	UIView *view = launchViewController.view;
	view.frame = [[UIScreen mainScreen] applicationFrame];
	[window addSubview:view];
	
	if (launchStage == EWLaunchSequenceStageComplete) [self autoWeighInIfEnabled];

	CATransition *animation = [CATransition animation];
	[animation setType:transitionType];
	[animation setSubtype:transitionSubtype];
	[animation setDuration:0.250];
	[[window layer] addAnimation:animation forKey:nil];
}




#pragma mark UIApplicationDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self registerDefaults];
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[self continueLaunchSequence];
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
