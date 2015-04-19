/*
 * BRTextView.m
 * Created by Benjamin Ragheb on 11/27/08.
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
