//
//  EWFlagButton.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/15/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EWFlagButton : UIButton {
}
+ (void)updateIconName:(NSString *)name forFlagIndex:(int)flagIndex;
- (void)configureForFlagIndex:(int)flagIndex;
@end
