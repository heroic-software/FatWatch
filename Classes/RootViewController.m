/*
 * RootViewController.m
 * Created by Benjamin Ragheb on 5/12/08.
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
