//
//  BRPopUpViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/13/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "BRPopUpViewController.h"


@implementation BRPopUpViewController


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
