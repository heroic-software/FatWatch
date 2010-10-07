//
//  EWFlagButton.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/15/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


extern NSString * const EWFlagButtonIconDidChangeNotification;


@interface EWFlagButton : UIButton {
}
+ (NSArray *)allIconNames;
+ (UIImage *)imageForIconName:(NSString *)name;
+ (void)updateIconName:(NSString *)name forFlagIndex:(int)flagIndex;
+ (NSString *)iconNameForFlagIndex:(int)flagIndex;
- (void)configureForFlagIndex:(int)flagIndex;
@end
