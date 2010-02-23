//
//  YAxisView.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 8/12/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "YAxisView.h"
#import "EWDatabase.h"
#import "EWWeightFormatter.h"
#import "NSUserDefaults+EWAdditions.h"


static const CGFloat gTickWidth = 6.5;
static const CGFloat gMinorTickWidth = 3.5;


@implementation YAxisView


- (void)useParameters:(GraphViewParameters *)parameters {
	p = parameters;
}


- (CGSize)sizeThatFits:(CGSize)size {
	NSFormatter *formatter = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleGraph];
	// 993 lbs | 451 kg | 70 st 13 lb
	NSNumber *number = [NSNumber numberWithFloat:993];
	NSString *label = [formatter stringForObjectValue:number];
	UIFont *labelFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];	
	CGSize labelSize = [label sizeWithFont:labelFont];
	return CGSizeMake(labelSize.width + 2*gTickWidth, size.height);
}


- (void)drawRect:(CGRect)rect {
	NSAssert(p != NULL, @"Attempt to draw Y-axis view before parameters are set.");
	
	const CGRect bounds = self.bounds;
	const CGFloat viewWidth = CGRectGetWidth(bounds);
		
	// vertical line at the right side
	CGMutablePathRef tickPath = CGPathCreateMutable();
	CGFloat barX = viewWidth - 0.5;
	CGPathMoveToPoint(tickPath, NULL, barX, CGRectGetMinY(bounds));
	CGPathAddLineToPoint(tickPath, NULL, barX, CGRectGetMaxY(bounds));

	// draw labels
	NSFormatter *formatter = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleGraph];
	UIFont *labelFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];	
	[[UIColor blackColor] setFill];
	for (float w = p->gridMinWeight; w < p->maxWeight; w += p->gridIncrement) {
		// draw tick label
		NSString *label = [formatter stringForObjectValue:[NSNumber numberWithFloat:w]];
		CGSize labelSize = [label sizeWithFont:labelFont];
		CGPoint point = CGPointApplyAffineTransform(CGPointMake(0, w), p->t);
		CGRect labelRect = CGRectMake(viewWidth - labelSize.width - gTickWidth, 
									  point.y - (labelSize.height / 2),
									  labelSize.width,
									  labelSize.height);
		//if (CGRectContainsRect(bounds, labelRect)) {
			[label drawAtPoint:labelRect.origin withFont:labelFont];
		//}
		// add tick line to path
		CGPathMoveToPoint(tickPath, NULL, viewWidth - gTickWidth, point.y);
		CGPathAddLineToPoint(tickPath, NULL, viewWidth, point.y);
	}
	
	// minor ticks
	float incr = [[NSUserDefaults standardUserDefaults] weightWholeIncrement];
	for (float w = p->gridMinWeight; w < p->maxWeight; w += incr) {
		CGPoint point = CGPointApplyAffineTransform(CGPointMake(0, w), p->t);
		CGPathMoveToPoint(tickPath, NULL, viewWidth - gMinorTickWidth, point.y);
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
