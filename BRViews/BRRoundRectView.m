//
//  BRRoundRectView.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/7/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "BRRoundRectView.h"


CGPathRef BRPathCreateRoundRect(CGRect rect, CGFloat radius) {
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGFloat minX = CGRectGetMinX(rect);
	CGFloat maxX = CGRectGetMaxX(rect);
	CGFloat minY = CGRectGetMinY(rect);
	CGFloat maxY = CGRectGetMaxY(rect);
	
	CGPathMoveToPoint   (path, NULL, minX + radius, minY);
	CGPathAddLineToPoint(path, NULL, maxX - radius, minY); // top side
	CGPathAddArcToPoint (path, NULL, maxX, minY, maxX, minY + radius, radius);
	CGPathAddLineToPoint(path, NULL, maxX, maxY - radius); // right side
	CGPathAddArcToPoint (path, NULL, maxX, maxY, maxX - radius, maxY, radius);
	CGPathAddLineToPoint(path, NULL, minX + radius, maxY); // bottom side
	CGPathAddArcToPoint (path, NULL, minX, maxY, minX, maxY - radius, radius);
	CGPathAddLineToPoint(path, NULL, minX, minY + radius); // left side
	CGPathAddArcToPoint (path, NULL, minX, minY, minX + radius, minY, radius);
	
	return path;
}


@implementation BRRoundRectView


- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super initWithCoder:coder])) {
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.contentMode = UIViewContentModeRedraw;
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	UIView *subview = [[self subviews] lastObject];
	
	NSAssert(subview != nil, @"BRRoundRectView must contain one subview");
	
	CGFloat radius = 2 * CGRectGetMinX(subview.frame);
	CGPathRef path = BRPathCreateRoundRect(CGRectInset(self.bounds, 1, 1), radius);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
	CGContextSetFillColorWithColor(context, [subview.backgroundColor CGColor]);
	CGContextAddPath(context, path);
	CGContextDrawPath(context, kCGPathFillStroke);
	
	CGPathRelease(path);
}


@end
