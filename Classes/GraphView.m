//
//  GraphView.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/16/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "GraphView.h"
#import "Database.h"
#import "MonthData.h"
#import "EWGoal.h"



@implementation GraphView


@synthesize image;


- (id)initWithFrame:(CGRect)frame {
	if ([super initWithFrame:frame]) {
		self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}


- (void)setImage:(UIImage *)newImage {
	if (image != newImage) {
		[image release];
		image = [newImage retain];
		[self setNeedsDisplay];
	}
}


void GraphViewDrawPattern(void *info, CGContextRef context) {
	const CGFloat d = 7;
	CGContextSetGrayFillColor(context, 0.6, 1.0);
	CGContextSetGrayStrokeColor(context, 0.4, 1.0);
	CGContextAddRect(context, CGRectMake(0.5, 0.5, d, d));
	CGContextDrawPath(context, kCGPathFillStroke);
}


- (void)drawRect:(CGRect)rect {
	if (image) {
		[image drawAtPoint:CGPointZero];
	} else {
		static CGPatternRef pattern = NULL;
		
		if (pattern == NULL) {
			CGPatternCallbacks callbacks;
			callbacks.version = 0;
			callbacks.drawPattern = GraphViewDrawPattern;
			callbacks.releaseInfo = NULL;
			pattern = CGPatternCreate(NULL, CGRectMake(0, 0, 7, 7), CGAffineTransformIdentity, 7, 7, kCGPatternTilingConstantSpacing, TRUE, &callbacks);
		}
		
		CGContextRef ctxt = UIGraphicsGetCurrentContext();
		CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
		CGColorSpaceRef space = CGColorSpaceCreatePattern(baseSpace);
		CGContextSetFillColorSpace(ctxt, space);
		const CGFloat alpha[] = { 1.0 };
		CGContextSetFillPattern(ctxt, pattern, alpha);
		CGContextFillRect(ctxt, self.bounds);
		CGColorSpaceRelease(space);
		CGColorSpaceRelease(baseSpace);
	}
}


@end
