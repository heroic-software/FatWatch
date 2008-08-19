//
//  YAxisView.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 8/12/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "YAxisView.h"
#import "Database.h"
#import "WeightFormatters.h"


@implementation YAxisView


- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	CGRect bounds = self.bounds;
	
	Database *database = [Database sharedDatabase];
	const float minWeight = [database minimumWeight] - 10.0f;
	const float maxWeight = [database maximumWeight] + 10.0f;
	const float scaleY = (CGRectGetHeight(bounds) / (maxWeight - minWeight));
	
	NSFormatter *formatter = [WeightFormatters chartWeightFormatter];
	
	float baseIncrement = [WeightFormatters chartWeightIncrement];

	// need initial increment = 1, then secondary increment = 5
	float weightIncrement = baseIncrement;

	UIFont *labelFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];

	CGFloat labelHeight = labelFont.pointSize;
	while (scaleY * weightIncrement < labelHeight) {
		weightIncrement += baseIncrement;
	}
	
	const float startWeight = roundf(minWeight / weightIncrement) * weightIncrement;
	const float endWeight = roundf(maxWeight / weightIncrement) * weightIncrement;
	
	CGContextRef ctxt = UIGraphicsGetCurrentContext();

	// draw white background
	CGContextSetGrayFillColor(ctxt, 1.0, 1.0);
	CGContextFillRect(ctxt, bounds);
	
	// gray vertical line at the right size
	CGContextMoveToPoint(ctxt, CGRectGetMaxX(bounds)-0.5, CGRectGetMinY(bounds));
	CGContextAddLineToPoint(ctxt, CGRectGetMaxX(bounds)-0.5, CGRectGetMaxY(bounds));
	CGContextSetGrayStrokeColor(ctxt, 0.7, 1.0);
	CGContextSetLineWidth(ctxt, 1.0);
	CGContextStrokePath(ctxt);
	
	CGContextSetGrayFillColor(ctxt, 0.0, 1.0);
	CGContextSetGrayStrokeColor(ctxt, 0.0, 1.0);
	CGContextSetLineWidth(ctxt, 3);
	float w;
	CGFloat x = CGRectGetWidth(bounds) / 2;
	for (w = startWeight; w < endWeight; w += weightIncrement) {
		CGFloat y = scaleY * (maxWeight - w);
		NSString *label = [formatter stringForObjectValue:[NSNumber numberWithFloat:w]];
		CGSize labelSize = [label sizeWithFont:labelFont];
		
		CGPoint labelPoint = CGPointMake(x - (labelSize.width / 2), y - (labelSize.height / 2));
		[label drawAtPoint:labelPoint withFont:labelFont];
		
		CGContextMoveToPoint(ctxt, x + (labelSize.width / 2), y);
		CGContextAddLineToPoint(ctxt, CGRectGetWidth(bounds), y);
		CGContextStrokePath(ctxt);
	}
	
	// draw minor tick marks
}


- (void)dealloc {
	[super dealloc];
}


@end
