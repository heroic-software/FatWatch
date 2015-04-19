/*
 * EatWatchAppDelegate.h
 * Created by Benjamin Ragheb on 3/15/08.
 * Copyright 2015 Heroic Software Inc
 *
 * This file is part of FatWatch.
 *
 * FatWatch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FatWatch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <UIKit/UIKit.h>

@class EWDatabase;


typedef enum {
	EWLaunchSequenceStageDebug = 1,
	EWLaunchSequenceStageAuthorize,
	EWLaunchSequenceStageUpgrade,
	EWLaunchSequenceStageNewDatabase,
	EWLaunchSequenceStageComplete
} EWLaunchSequenceStage;


@interface EatWatchAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate>
@property (nonatomic,strong) IBOutlet UITabBarController *rootTabBarController;
- (NSString *)databasePath;
- (void)continueLaunchSequence;
@end


@interface UIViewController (DoubleTapDetection)
- (void)tabBarItemDoubleTapped;
@end
