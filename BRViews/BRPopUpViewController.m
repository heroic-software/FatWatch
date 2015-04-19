/*
 * BRPopUpViewController.m
 * Created by Benjamin Ragheb on 12/13/09.
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

#import "BRPopUpViewController.h"


@implementation BRPopUpViewController
{
	UIView *view;
	UIView *superview;
    UIButton *screenButton;
}

@synthesize view;
@synthesize superview;


- (BOOL)isVisible {
	return [self.view superview] != nil;
}


- (BOOL)canHide {
	return YES;
}


- (void)willShow {
}


- (void)didHide {
}


- (IBAction)show:(UIButton *)sender {
	[self showAnimated:YES];
}


- (IBAction)hide:(UIButton *)sender {
	[self hideAnimated:YES];
}


- (IBAction)toggle:(UIButton *)sender {
	if (self.visible) {
		[self hide:nil];
	} else {
		[self show:nil];
	}
}


- (void)showImmediately {
    [self willShow];
    [superview addSubview:screenButton];
    screenButton.alpha = 0.4f;
    [superview addSubview:view];
    CGRect newFrame = view.frame;
    newFrame.origin.y = CGRectGetMaxY(superview.bounds) - CGRectGetHeight(newFrame);
    view.frame = newFrame;
}


- (void)moveOffstage {
    CGRect newFrame = view.frame;
    newFrame.origin.y = CGRectGetMaxY(superview.bounds);
    view.frame = newFrame;
    screenButton.alpha = 0;
}


- (void)hideImmediately {
    [view removeFromSuperview];
    [screenButton removeFromSuperview];
    [self didHide];
}


- (void)showAnimated:(BOOL)animated {
	if (self.visible) return;
    if (screenButton == nil) {
        screenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        screenButton.backgroundColor = [UIColor blackColor];
        [screenButton addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
    }
    screenButton.frame = superview.bounds;
	if (animated) {
        [self moveOffstage];
        [UIView animateWithDuration:0.2 animations:^(void) {
            [self showImmediately];
        }];
	} else {
        [self showImmediately];
	}
}


- (void)hideAnimated:(BOOL)animated {
	if (!self.visible) return;
	if (animated) {
        [UIView animateWithDuration:0.2 animations:^(void) {
            [self moveOffstage];
        } completion:^(BOOL finished) {
            [self hideImmediately];
        }];
	} else {
        [self hideImmediately];
	}
}




@end
