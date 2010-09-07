//
//  BRPopUpViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/13/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "BRPopUpViewController.h"


static BRPopUpViewController *gPoppedUpViewController = nil;


@interface BRPopUpViewController ()
- (void)animationDidStop:(NSString *)animID finished:(BOOL)flag context:(void *)context;
@end



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
	if (gPoppedUpViewController != nil) {
		if ([gPoppedUpViewController canHide]) {
			[gPoppedUpViewController hideAnimated:YES];
		} else {
			return;
		}
	}
	[self showAnimated:YES];
	showButton = [sender retain];
	[showButton setEnabled:NO];
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


- (void)showAnimated:(BOOL)animated {
	if (self.visible) return;
	if (animated) {
		CGRect startFrame = view.frame;
		startFrame.origin.y = CGRectGetMaxY(superview.bounds);
		view.frame = startFrame;
		[UIView beginAnimations:@"BRPopUpShow" context:nil];
		[self showAnimated:NO];
		[UIView commitAnimations];
	} else {
		[self willShow];
		gPoppedUpViewController = self;
		[superview addSubview:view];
		CGRect newFrame = view.frame;
		newFrame.origin.y = CGRectGetMaxY(superview.bounds) - CGRectGetHeight(newFrame);
		view.frame = newFrame;
	}
}


- (void)hideAnimated:(BOOL)animated {
	if (!self.visible) return;
	if (animated) {
		[UIView beginAnimations:@"BRPopUpHide" context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		CGRect newFrame = view.frame;
		newFrame.origin.y = CGRectGetMaxY(superview.bounds);
		view.frame = newFrame;
		[UIView commitAnimations];
	} else {
		[view removeFromSuperview];
		if (gPoppedUpViewController == self) gPoppedUpViewController = nil;
		[showButton setEnabled:YES];
		[showButton release];
		showButton = nil;
		[self didHide];
	}
}


- (void)animationDidStop:(NSString *)animID finished:(BOOL)flag context:(void *)context {
	if ([animID isEqualToString:@"BRPopUpHide"]) {
		[self hideAnimated:NO];
	}
}


@end
