//
//  GraphView.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/16/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "GraphView.h"
#import "GraphDrawingOperation.h"


@implementation GraphView


@synthesize image;
@synthesize month;


- (id)initWithFrame:(CGRect)frame {
	if ([super initWithFrame:frame]) {
		self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}


void GraphViewDrawPattern(void *info, CGContextRef context) {
	CGContextSetGrayFillColor(context, 0.9, 1.0);
	CGContextSetGrayStrokeColor(context, 0.8, 1.0);
	CGContextAddRect(context, CGRectMake(0.5, 0.5, kDayWidth, kDayWidth));
	CGContextDrawPath(context, kCGPathFillStroke);
}


- (void)setImage:(CGImageRef)newImage {
	if (image != newImage) {
		CGImageRetain(newImage);
		CGImageRelease(image);
		image = newImage;
	}
}


- (void)drawRect:(CGRect)rect {
	if (image != NULL) {
		CGRect bounds = self.bounds;
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextTranslateCTM(context, 0, CGRectGetHeight(bounds));
		CGContextScaleCTM(context, 1, -1);
		CGContextDrawImage(context, bounds, image);
	} else {
		static CGPatternRef pattern = NULL;
		
		if (pattern == NULL) {
			CGPatternCallbacks callbacks;
			callbacks.version = 0;
			callbacks.drawPattern = GraphViewDrawPattern;
			callbacks.releaseInfo = NULL;
			pattern = CGPatternCreate(NULL, CGRectMake(0, 0, kDayWidth, kDayWidth), CGAffineTransformIdentity, kDayWidth, kDayWidth, kCGPatternTilingConstantSpacing, TRUE, &callbacks);
		}
		
		CGContextRef ctxt = UIGraphicsGetCurrentContext();
		CGColorSpaceRef space = CGColorSpaceCreatePattern(NULL);
		CGContextSetFillColorSpace(ctxt, space);
		const CGFloat alpha[] = { 1.0 };
		CGContextSetFillPattern(ctxt, pattern, alpha);
		CGContextFillRect(ctxt, self.bounds);
		CGColorSpaceRelease(space);

		if (month != EWMonthNone) {
			[GraphDrawingOperation drawCaptionForMonth:month inContext:ctxt];
		}
	}
}


- (void)dealloc {
	CGImageRelease(image);
	[super dealloc];
}


@end
