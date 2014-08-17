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
#import "EWImporter.h"
#import "ImportViewController.h"
#import "EWDateFormatter.h"


static NSString *kWeightDatabaseName = @"WeightData.db";
static NSString *kSelectedTabIndex = @"SelectedTabIndex";


@implementation EatWatchAppDelegate
{
    UIWindow *window;
	UIViewController *launchViewController;
	NSUInteger lastTapTabIndex;
	NSTimeInterval lastTapTime;
	EWDatabase *db;
	EWLaunchSequenceStage launchStage;
    NSData *dataToImport;
}

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
    NSString *documentsDirectory = paths[0];
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
		[_rootTabBarController presentViewController:controller animated:NO completion:nil];
	}
}


- (void)launchStageDebug {
#if DEBUG_LAUNCH_STAGE_ENABLED
	launchViewController = [[DebugViewController alloc] init];
#endif
}


- (void)launchStageAuthorize {
	if ([PasscodeEntryViewController authorizationRequired]) {
		launchViewController = [PasscodeEntryViewController controllerForAuthorization];
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
	NSDictionary *externals = @{@"Database": db};
	NSDictionary *options = @{UINibExternalObjects: externals};
	[[NSBundle mainBundle] loadNibNamed:@"RootView" owner:self options:options];
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	lastTapTabIndex = [defs integerForKey:kSelectedTabIndex];
    _rootTabBarController.selectedIndex = lastTapTabIndex;
	
	launchViewController = _rootTabBarController;
    
    if (dataToImport) {
        dispatch_async(dispatch_get_main_queue(), ^{
            EWImporter *importer = [[EWImporter alloc] initWithData:dataToImport encoding:NSUTF8StringEncoding];
            [importer autodetectFields];
            ImportViewController *importView = [[ImportViewController alloc] initWithImporter:importer database:db];
            importView.promptBeforeImport = YES;
            [window.rootViewController presentViewController:importView animated:YES completion:nil];
            dataToImport = nil;
        });
    }
}


- (void)continueLaunchSequence {
	CATransition *animation = [CATransition animation];

	if (launchViewController != nil) {
		[launchViewController.view removeFromSuperview];
		launchViewController = nil;
		switch (launchStage) {
			case EWLaunchSequenceStageDebug:
			case EWLaunchSequenceStageAuthorize:
			case EWLaunchSequenceStageUpgrade:
                [animation setType:kCATransitionReveal];
                [animation setSubtype:kCATransitionFromTop];
				break;
			case EWLaunchSequenceStageNewDatabase:
                [animation setType:kCATransitionPush];
                [animation setSubtype:kCATransitionFromRight];
				break;
			case EWLaunchSequenceStageComplete:
				break;
		}
	}
	
    while (launchViewController == nil) {
        launchStage += 1;
		switch (launchStage) {
			case EWLaunchSequenceStageDebug:       [self launchStageDebug];       break;
			case EWLaunchSequenceStageAuthorize:   [self launchStageAuthorize];   break;
			case EWLaunchSequenceStageUpgrade:     [self launchStageUpgrade];     break;
			case EWLaunchSequenceStageNewDatabase: [self launchStageNewDatabase]; break;
			case EWLaunchSequenceStageComplete:    [self launchStageComplete];    break;
		}
	}

    window.rootViewController = launchViewController;
    if (launchStage == EWLaunchSequenceStageComplete) {
        [self autoWeighInIfEnabled];
    }

    [animation setDuration:0.3];
    [[window layer] addAnimation:animation forKey:nil];
}


#pragma mark UIApplicationDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self registerDefaults];
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if ([window respondsToSelector:@selector(setTintColor:)]) {
//        [window setTintColor:[UIColor colorWithRed:0.88 green:0 blue:0 alpha:1]];
    }
	[self continueLaunchSequence];
    [window makeKeyAndVisible];
	return YES;
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    dataToImport = [[NSData alloc] initWithContentsOfURL:url];
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[db close];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[db reopen];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
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


@end
