//
//  YAxisView.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 8/12/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "YAxisView.h"
#import "EWDatabase.h"
#import "WeightFormatters.h"


@implementation YAxisView


- (void)useParameters:(GraphViewParameters *)parameters {
	p = parameters;
}


- (void)drawRect:(CGRect)rect {
	NSAssert(p != NULL, @"Attempt to draw Y-axis view before parameters are set.");
	
	const CGRect bounds = self.bounds;
	const CGFloat viewWidth = CGRectGetWidth(bounds);
	const CGFloat tickWidth = 6.5;
	const CGFloat minorTickWidth = 3.5;
		
	// vertical line at the right side
	CGMutablePathRef tickPath = CGPathCreateMutable();
	CGFloat barX = viewWidth - 0.5;
	CGPathMoveToPoint(tickPath, NULL, barX, CGRectGetMinY(bounds));
	CGPathAddLineToPoint(tickPath, NULL, barX, CGRectGetMaxY(bounds));

	// draw labels
	NSFormatter *formatter = [WeightFormatters chartWeightFormatter];
	UIFont *labelFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];	
	[[UIColor blackColor] setFill];
	float w;
	for (w = p->gridMinWeight; w < p->gridMaxWeight; w += p->gridIncrementWeight) {
		// draw tick label
		NSString *label = [formatter stringForObjectValue:[NSNumber numberWithFloat:w]];
		CGSize labelSize = [label sizeWithFont:labelFont];
		CGPoint point = CGPointApplyAffineTransform(CGPointMake(0, w), p->t);
		CGRect labelRect = CGRectMake(viewWidth - labelSize.width - tickWidth, 
									  point.y - (labelSize.height / 2),
									  labelSize.width,
									  labelSize.height);
		if (CGRectContainsRect(bounds, labelRect)) {
			[label drawInRect:labelRect withFont:labelFont];
		}
		// add tick line to path
		CGPathMoveToPoint(tickPath, NULL, viewWidth - tickWidth, point.y);
		CGPathAddLineToPoint(tickPath, NULL, viewWidth, point.y);
	}
	
	// minor ticks
	for (w = p->gridMinWeight; w < p->gridMaxWeight; w += [WeightFormatters chartWeightIncrement]) {
		CGPoint point = CGPointApplyAffineTransform(CGPointMake(0, w), p->t);
		CGPathMoveToPoint(tickPath, NULL, viewWidth - minorTickWidth, point.y);
		CGPathAddLineToPoint(tickPath, NULL, viewWidth, point.y);
	}
	
	CGContextRef ctxt = UIGraphicsGetCurrentContext();
	CGContextSetGrayStrokeColor(ctxt, 0.0, 1.0);
	CGContextSetLineWidth(ctxt, 1);
	CGContextAddPath(ctxt, tickPath);
	CGContextStrokePath(ctxt);
	CFRelease(tickPath);
}


@end
