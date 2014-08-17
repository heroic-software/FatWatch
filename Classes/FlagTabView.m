//
//  FlagTabView.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/16/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "FlagTabView.h"


@implementation FlagTabView
{
	CGRect tabRect;
}

- (void)awakeFromNib {
	UIView *view = (self.subviews)[0];
	[self selectTabAroundRect:[view frame]];
}


- (void)selectTabAroundRect:(CGRect)rect {
	tabRect = rect;
	[self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
	CGRect b = self.bounds;
	[[UIColor whiteColor] setFill];
	UIRectFill(CGRectInset(tabRect, -10, -10));
	[[UIColor grayColor] setStroke];
	CGContextRef context = UIGraphicsGetCurrentContext();

	const CGFloat xL = CGRectGetMinX(tabRect)-10.5f;
	const CGFloat xR = CGRectGetMaxX(tabRect)+10.5f;
	const CGFloat yT = CGRectGetMinY(tabRect)-10.5f;
	const CGFloat yB = CGRectGetMaxY(b)-0.5f;
	
	CGContextMoveToPoint(context, CGRectGetMinX(b), yB);
	CGContextAddLineToPoint(context, xL, yB);
	CGContextAddLineToPoint(context, xL, yT);
	CGContextAddLineToPoint(context, xR, yT);
	CGContextAddLineToPoint(context, xR, yB);
	CGContextAddLineToPoint(context, CGRectGetMaxX(b), yB);
	CGContextStrokePath(context);
}




@end
