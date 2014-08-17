//
//  BRTextView.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 11/27/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTextView.h"


@implementation BRTextView
{
	CALayer *placeholderLayer;
}

- (void)updatePlaceholderLayer {
	if (placeholderLayer == nil) {
		placeholderLayer = [CALayer layer];
	
		UIFont *font = self.font;
		NSString *placeholderText = @"Note";
		CGSize size = [placeholderText sizeWithFont:font];
		if (UIGraphicsBeginImageContextWithOptions) {
			UIGraphicsBeginImageContextWithOptions(size, YES, 0);
		} else {
			UIGraphicsBeginImageContext(size);
		}
		[self.backgroundColor setFill];
		UIRectFill(CGRectMake(0, 0, size.width, size.height));
		[[UIColor grayColor] setFill];
		[placeholderText drawAtPoint:CGPointZero withFont:font];
		UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		placeholderLayer.frame = CGRectMake(8, 8, size.width, size.height);
		placeholderLayer.contents = (id)[image CGImage];
		
		[self.layer addSublayer:placeholderLayer];
	}
	placeholderLayer.hidden = ([self.text length] > 0);
}


- (void)setText:(NSString *)text {
	[super setText:text];
	[self updatePlaceholderLayer];
}


- (void)setFont:(UIFont *)font {
	[super setFont:font];
	[placeholderLayer removeFromSuperlayer];
	placeholderLayer = nil;
	[self updatePlaceholderLayer];
}


- (BOOL)becomeFirstResponder {
	BOOL shouldBecome = [super becomeFirstResponder];
	
	if (shouldBecome) {
		placeholderLayer.hidden = YES;
	}
	
	return shouldBecome;
}


- (BOOL)resignFirstResponder {
	BOOL shouldResign = [super resignFirstResponder];
	
	if (shouldResign) {
		[self updatePlaceholderLayer];
	}
	
	return shouldResign;
}

@end
