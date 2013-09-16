//
//  EatWatchAppDelegate.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/15/08.
//  Copyright Benjamin Ragheb 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EWDatabase;


typedef enum {
	EWLaunchSequenceStageDebug = 1,
	EWLaunchSequenceStageAuthorize,
	EWLaunchSequenceStageUpgrade,
	EWLaunchSequenceStageNewDatabase,
	EWLaunchSequenceStageComplete
} EWLaunchSequenceStage;


@interface EatWatchAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
	UIViewController *launchViewController;
	NSUInteger lastTapTabIndex;
	NSTimeInterval lastTapTime;
	EWDatabase *db;
	EWLaunchSequenceStage launchStage;
    NSData *dataToImport;
}
@property (nonatomic,strong) IBOutlet UITabBarController *rootTabBarController;
- (NSString *)databasePath;
- (void)continueLaunchSequence;
@end


@interface UIViewController (DoubleTapDetection)
- (void)tabBarItemDoubleTapped;
@end
