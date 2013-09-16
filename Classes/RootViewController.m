//
//  RootViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/12/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "RootViewController.h"


@implementation RootViewController
{
    BOOL _isShowingLandscapeView;
}

- (void)awakeFromNib {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(deviceOrientationDidChange:)
     name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)deviceOrientationDidChange:(NSNotification *)note {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !_isShowingLandscapeView) {
        if ([self presentedViewController] == nil) {
            [self presentViewController:[self landscapeViewController] animated:YES completion:NULL];
            _isShowingLandscapeView = YES;
        }
    } else if (UIDeviceOrientationIsPortrait(deviceOrientation) && _isShowingLandscapeView) {
        [self dismissViewControllerAnimated:YES completion:NULL];
        _isShowingLandscapeView = NO;
    }
}

@end
