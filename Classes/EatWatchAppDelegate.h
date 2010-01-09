//
//  EatWatchAppDelegate.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/15/08.
//  Copyright Benjamin Ragheb 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface EatWatchAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
	RootViewController *rootViewController;
	UIViewController *launchViewController;
	BOOL readyToGo;
}
- (void)removeLaunchViewWithTransitionType:(NSString *)type subType:(NSString *)subType;
@end
