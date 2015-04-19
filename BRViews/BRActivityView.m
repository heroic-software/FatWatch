/*
 * BRActivityView.m
 * Created by Benjamin Ragheb on 7/23/09.
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

#import "BRActivityView.h"


#define kLabelTag 701
#define kActivityIndicatorTag 702


@implementation BRActivityView


- (id)init {
    if ((self = [super initWithFrame:CGRectMake(0, 0, 100, 100)])) {
		self.autoresizesSubviews = YES;
		self.opaque = NO;
		
		UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 100-16, 30)];
		messageLabel.tag = kLabelTag;
		messageLabel.textColor = [UIColor whiteColor];
		messageLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | 
										 UIViewAutoresizingFlexibleBottomMargin);
		messageLabel.font = [UIFont boldSystemFontOfSize:20];
		messageLabel.textAlignment = NSTextAlignmentCenter;
		messageLabel.backgroundColor = nil;
		messageLabel.opaque = NO;
		[self addSubview:messageLabel];
		
		UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityIndicator.tag = kActivityIndicatorTag;
		activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
											  UIViewAutoresizingFlexibleRightMargin |
											  UIViewAutoresizingFlexibleBottomMargin |
											  UIViewAutoresizingFlexibleLeftMargin);
		activityIndicator.center = self.center;
		[self addSubview:activityIndicator];
    }
    return self;
}




- (NSString *)message {
	UILabel *messageLabel = (UILabel *)[self viewWithTag:kLabelTag];
	return messageLabel.text;
}


- (void)setMessage:(NSString *)message {
	UILabel *messageLabel = (UILabel *)[self viewWithTag:kLabelTag];
	messageLabel.text = message;
}


- (void)showInView:(UIView *)view {
	CGRect b = [view bounds];
	CGFloat w = CGRectGetWidth(b);
	CGFloat side = 0.6f * w;
	self.bounds = CGRectMake(0, 0, side, side);
	self.center = view.center;

	self.transform = CGAffineTransformMakeScale(2, 2);
	self.alpha = 0;
	
	[view addSubview:self];
    [UIView animateWithDuration:0.2 animations:^(void) {
        self.transform = CGAffineTransformIdentity;
        self.alpha = 1;
    }];

	UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self viewWithTag:kActivityIndicatorTag];
	[activityIndicator startAnimating];
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}


- (void)dismiss {
	UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self viewWithTag:kActivityIndicatorTag];
	[activityIndicator stopAnimating];
	[self removeFromSuperview];
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
}


- (void)drawRect:(CGRect)rect {
	CGRect b = self.bounds;
	const CGFloat R = 16;
	const CGFloat W = CGRectGetWidth(b);
	const CGFloat H = CGRectGetHeight(b);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	// Top Left
	CGContextMoveToPoint(context, 0, R);
	CGContextAddArcToPoint(context, 0, 0, R, 0, R);
	// Top Right
	CGContextAddLineToPoint(context, W-R, 0);
	CGContextAddArcToPoint(context, W, 0, W, R, R);
	// Bottom Right
	CGContextAddLineToPoint(context, W, H-R);
	CGContextAddArcToPoint(context, W, H, W-R, H, R);
	// Bottom Left
	CGContextAddLineToPoint(context, R, H);
	CGContextAddArcToPoint(context, 0, H, 0, H-R, R);
	
	CGContextSetRGBFillColor(context, 0, 0, 0, 0.7f);
	CGContextFillPath(context);
}


@end
