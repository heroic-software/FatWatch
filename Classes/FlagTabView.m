//
//  FlagTabView.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/16/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "FlagTabView.h"


@implementation FlagTabView


- (void)awakeFromNib {
	UIView *view = [self.subviews objectAtIndex:0];
	[self selectTabAroundRect:[view frame]];
}


- (void)selectTabAroundRect:(CGRect)rect {
	tabRect = rect;
	[self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
	CGRect b = self.bounds;
	[[UIColor groupTableViewBackgroundColor] setFill];
	UIRectFill(b);
	[[UIColor whiteColor] setFill];
	UIRectFill(CGRectInset(tabRect, -10, -10));
	[[UIColor blackColor] setStroke];
	CGContextRef context = UIGraphicsGetCurrentContext();

	const CGFloat xL = CGRectGetMinX(tabRect)-10.5;
	const CGFloat xR = CGRectGetMaxX(tabRect)+10.5;
	const CGFloat yT = CGRectGetMinY(tabRect)-10.5;
	const CGFloat yB = CGRectGetMaxY(b)-0.5;
	
	CGContextMoveToPoint(context, CGRectGetMinX(b), yB);
	CGContextAddLineToPoint(context, xL, yB);
	CGContextAddLineToPoint(context, xL, yT);
	CGContextAddLineToPoint(context, xR, yT);
	CGContextAddLineToPoint(context, xR, yB);
	CGContextAddLineToPoint(context, CGRectGetMaxX(b), yB);
	CGContextStrokePath(context);
}


- (void)dealloc {
    [super dealloc];
}


@end
