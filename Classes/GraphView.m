//
//  GraphView.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/16/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "GraphView.h"
#import "GraphDrawingOperation.h"


static const CGFloat kLabelOffsetX = 2;
static const CGFloat kLabelOffsetY = 0;


void GraphViewDrawPattern(void *info, CGContextRef context) {
	CGContextSetGrayFillColor(context, 0.9, 1.0);
	CGContextSetGrayStrokeColor(context, 0.8, 1.0);
	CGContextAddRect(context, CGRectMake(0.5, 0.5, kDayWidth, kDayWidth));
	CGContextDrawPath(context, kCGPathFillStroke);
}


@implementation GraphView


@synthesize image;
@synthesize beginMonthDay;
@synthesize endMonthDay;
@synthesize p;


- (id)initWithFrame:(CGRect)frame {
	if ([super initWithFrame:frame]) {
		self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}


- (void)setImage:(CGImageRef)newImage {
	if (image != newImage) {
		CGImageRetain(newImage);
		CGImageRelease(image);
		image = newImage;
	}
}


- (CGImageRef)createMaskOfSize:(CGSize)size {
	int pixelsWide = size.width;
	int pixelsHigh = size.height;
	int bitmapBytesPerRow   = (pixelsWide * 4);
	int bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	void *bitmapData = NSZoneMalloc([self zone], bitmapByteCount);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef ctxt = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8 /* bits per component */, bitmapBytesPerRow, colorSpace, kCGImageAlphaNone);

	static const CGFloat fadeWidth = 8;
	static const CGFloat components[] = { 1, 1, 0, 1 };
	static const CGFloat locations[] = { 0, 1 };
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
	CGContextDrawLinearGradient(ctxt, gradient, CGPointMake(size.width - fadeWidth, 0), CGPointMake(size.width, 0), kCGGradientDrawsBeforeStartLocation);
	CGGradientRelease(gradient);

    CGImageRef mask = CGBitmapContextCreateImage(ctxt);

	CGColorSpaceRelease(colorSpace);
	NSZoneFree([self zone], bitmapData);
	
	return mask;
}


- (void)drawYearLabels {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"y";
	
	[[UIColor blackColor] setFill];
	
	UIFont *font = [UIFont systemFontOfSize:20];
	
	EWMonth month = EWMonthDayGetMonth(beginMonthDay);
	month -= (month % 12) + 12; // adjust to earlier january
	
	CGFloat x = EWDaysBetweenMonthDays(beginMonthDay, EWMonthDayMake(month, 1));
	
	while (month < (EWMonthDayGetMonth(endMonthDay) + 12)) {
		CGFloat width = EWDaysBetweenMonthDays(EWMonthDayMake(month, 1), EWMonthDayMake(month + 12, 1));
		
		NSDate *date = EWDateFromMonthAndDay(month, 1);
		NSString *text = [formatter stringFromDate:date];
		
		CGRect clipRect = CGRectMake(x * p->scaleX, 0, width * p->scaleX, 100);
		CGSize textSize = [text sizeWithFont:font];
		CGPoint textPoint = CGPointMake(x * p->scaleX + kLabelOffsetX, kLabelOffsetY);
		
		if (textSize.width > clipRect.size.width) {
			CGContextRef context = UIGraphicsGetCurrentContext();
			CGContextSaveGState(context);
			CGImageRef maskImage = [self createMaskOfSize:clipRect.size];
			CGContextClipToMask(context, clipRect, maskImage);
			[text drawAtPoint:textPoint withFont:font];
			CGContextRestoreGState(context);
			CGImageRelease(maskImage);
		} else {
			[text drawAtPoint:textPoint withFont:font];
		}
		
		month += 12;
		x += width;
	}
	
	[formatter release];
}


- (void)drawMonthLabels {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = NSLocalizedString(@"MONTH_YEAR_DATE_FORMAT", nil);
	
	[[UIColor blackColor] setFill];
	
	UIFont *font = [UIFont systemFontOfSize:20];
		
	EWMonth month = EWMonthDayGetMonth(beginMonthDay);
	CGFloat x = 1 - EWMonthDayGetDay(beginMonthDay);
	
	while (month <= EWMonthDayGetMonth(endMonthDay)) {
		CGFloat width = EWDaysInMonth(month);
		
		NSDate *date = EWDateFromMonthAndDay(month, 1);
		NSString *text = [formatter stringFromDate:date];

		CGRect clipRect = CGRectMake(x * p->scaleX, 0, width * p->scaleX, 100);
		CGSize textSize = [text sizeWithFont:font];
		CGPoint textPoint = CGPointMake(x * p->scaleX + kLabelOffsetX, kLabelOffsetY);
		
		if (textSize.width > clipRect.size.width) {
			CGContextRef context = UIGraphicsGetCurrentContext();
			CGContextSaveGState(context);
			CGImageRef maskImage = [self createMaskOfSize:clipRect.size];
			CGContextClipToMask(context, clipRect, maskImage);
			[text drawAtPoint:textPoint withFont:font];
			CGContextRestoreGState(context);
			CGImageRelease(maskImage);
		} else {
			[text drawAtPoint:textPoint withFont:font];
		}
		
		month += 1;
		x += width;
	}
	
	[formatter release];
}


- (void)drawRect:(CGRect)rect {
	if (image != NULL) {
		CGRect bounds = self.bounds;
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSaveGState(context);
		CGContextTranslateCTM(context, 0, CGRectGetHeight(bounds));
		CGContextScaleCTM(context, 1, -1);
		CGContextDrawImage(context, bounds, image);
		CGContextRestoreGState(context);
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
	}

	if (p->scaleX < 1) {
		[self drawYearLabels];
	} else {
		[self drawMonthLabels];
	}
}


- (void)dealloc {
	CGImageRelease(image);
	[super dealloc];
}


@end
