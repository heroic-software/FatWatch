//
//  EatWatchAppDelegate.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/15/08.
//  Copyright Benjamin Ragheb 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;
@class EWDatabase;

@interface EatWatchAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
	RootViewController *rootViewController;
	UIViewController *launchViewController;
	BOOL readyToGo;
	NSUInteger lastTapTabIndex;
	NSTimeInterval lastTapTime;
	EWDatabase *db;
}
- (void)removeLaunchViewWithTransitionType:(NSString *)type subType:(NSString *)subType;
@end


@interface UIViewController (DoubleTapDetection)
- (void)tabBarItemDoubleTapped;
@end
