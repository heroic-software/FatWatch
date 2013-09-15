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
#import "EWGoal.h"
#import "GraphDrawingOperation.h"


static const CGFloat gTickWidth = 6.5f;
static const CGFloat gMinorTickWidth = 3.5f;


@implementation YAxisView


@synthesize database;


- (void)useParameters:(GraphViewParameters *)parameters {
	p = parameters;
}


- (CGSize)sizeThatFits:(CGSize)size {
	NSFormatter *formatter = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleGraph];
	// 993 lbs | 451 kg | 70 st 13 lb
	NSNumber *number = @993.0f;
	NSString *label = [formatter stringForObjectValue:number];
	UIFont *labelFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];	
	CGSize labelSize = [label sizeWithFont:labelFont];
	return CGSizeMake(labelSize.width + 2*gTickWidth, size.height);
}


- (void)drawLabelForWeight:(float)w formatter:(NSFormatter *)formatter font:(UIFont *)labelFont
{
	const CGRect bounds = self.bounds;
	const CGFloat viewWidth = CGRectGetWidth(bounds);
	NSString *label = [formatter stringForObjectValue:@(w)];
	CGSize labelSize = [label sizeWithFont:labelFont];
	CGPoint point = CGPointApplyAffineTransform(CGPointMake(0, w), p->t);
	CGRect labelRect = CGRectMake(viewWidth - labelSize.width - gTickWidth, 
								  point.y - (labelSize.height / 2),
								  labelSize.width,
								  labelSize.height);
	//if (CGRectContainsRect(bounds, labelRect)) {
		[label drawAtPoint:labelRect.origin withFont:labelFont];
	//}
}


- (void)drawRect:(CGRect)rect {
	NSAssert(p != NULL, @"Attempt to draw Y-axis view before parameters are set.");
	
	const CGRect bounds = self.bounds;
	const CGFloat viewWidth = CGRectGetWidth(bounds);
	
	CGContextRef ctxt = UIGraphicsGetCurrentContext();
	
	// vertical line at the right side
	CGMutablePathRef tickPath = CGPathCreateMutable();
	CGFloat barX = viewWidth - 0.5f;
	CGPathMoveToPoint(tickPath, NULL, barX, CGRectGetMinY(bounds));
	CGPathAddLineToPoint(tickPath, NULL, barX, CGRectGetMaxY(bounds));

	// draw labels
	UIFont *labelFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];	
	NSFormatter *formatter = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleGraph];
	[[UIColor blackColor] setFill];
	for (float w = p->gridMinWeight; w < p->maxWeight; w += p->gridIncrement) {
		// draw tick label
		[self drawLabelForWeight:w formatter:formatter font:labelFont];
		// add tick line to path
		CGPoint point = CGPointApplyAffineTransform(CGPointMake(0, w), p->t);
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
	
	CGContextSetGrayStrokeColor(ctxt, 0, 1);
	CGContextSetLineWidth(ctxt, 1);
	CGContextAddPath(ctxt, tickPath);
	CGContextStrokePath(ctxt);
	CFRelease(tickPath);	

	// Goal Indicator
	EWGoal *goal = [[EWGoal alloc] initWithDatabase:database];
	if (goal.defined && !p->showFatWeight) {
		static const CGFloat dashLengths[] = { 4, 4 };
		
		float goalWeight = goal.endWeight;
		CGRect band = CGRectApplyAffineTransform(CGRectMake(0, goalWeight - gGoalBandHalfHeight, 
															1, gGoalBandHeight),
												 p->t);
		band.origin.x = 0;
		band.size.width = viewWidth;
		
		CGContextSaveGState(ctxt);
		{
			CGFloat y;
									
			y = CGRectGetMidY(band);
			const CGFloat kTabHalfHeight = 0.6f * [UIFont systemFontSize];
			const CGFloat xLeft = viewWidth - 1.5f * gTickWidth;
			const CGFloat xRight = viewWidth;
			const CGFloat yTop = y - kTabHalfHeight;
			const CGFloat yBottom = y + kTabHalfHeight;
			CGContextMoveToPoint(ctxt, xRight, y);
			CGContextAddCurveToPoint(ctxt, xLeft, y, xRight, yTop, xLeft, yTop);
			CGContextAddLineToPoint(ctxt, 0, yTop);
			CGContextAddLineToPoint(ctxt, 0, yBottom);
			CGContextAddLineToPoint(ctxt, xLeft, yBottom);
			CGContextAddCurveToPoint(ctxt, xRight, yBottom, xLeft, y, xRight, y);
			
			CGContextSetRGBFillColor(ctxt, 0.0f, 0.6f, 0.0f, 1);
			CGContextFillPath(ctxt);
			
			y = CGRectGetMinY(band);
			CGContextMoveToPoint(ctxt, 0, y);
			CGContextAddLineToPoint(ctxt, viewWidth, y);
			
			y = CGRectGetMaxY(band);
			CGContextMoveToPoint(ctxt, 0, y);
			CGContextAddLineToPoint(ctxt, viewWidth, y);
			
			CGContextSetLineWidth(ctxt, 1);
			CGContextSetLineDash(ctxt, -viewWidth, dashLengths, 2);
			CGContextSetRGBStrokeColor(ctxt, 0.0f, 0.6f, 0.0f, 1);
			CGContextStrokePath(ctxt);

			// draw text
			[[UIColor whiteColor] set];
			[self drawLabelForWeight:goalWeight formatter:formatter 
								font:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
		}
		CGContextRestoreGState(ctxt);
	}
	[goal release];
}


- (void)dealloc {
	[database release];
	[super dealloc];
}


@end
