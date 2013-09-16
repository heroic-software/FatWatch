//
//  GraphView.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/16/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "GraphView.h"


static const CGFloat kLabelOffsetX = 2;
static const CGFloat kLabelOffsetY = 0;


void GraphViewDrawPattern(void *info, CGContextRef context) {
	CGContextSetGrayFillColor(context, 0.9f, 1.0f);
	CGContextSetGrayStrokeColor(context, 0.8f, 1.0f);
	CGContextAddRect(context, CGRectMake(0.5f, 0.5f, kDayWidth, kDayWidth));
	CGContextDrawPath(context, kCGPathFillStroke);
}


@implementation GraphView


@synthesize image;
@synthesize beginMonthDay;
@synthesize endMonthDay;
@synthesize p;
@synthesize yAxisView;
@synthesize drawBorder;


- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
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


- (CGImageRef)newMaskOfSize:(CGSize)size {
	static const size_t bitsPerComponent = 8;
	static const size_t bytesPerPixel = 1;
	size_t pixelsWide = size.width;
	size_t pixelsHigh = size.height;
	size_t bitmapBytesPerRow   = (pixelsWide * bytesPerPixel);

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	void *data = malloc(bitmapBytesPerRow * pixelsHigh);
	CGContextRef ctxt = CGBitmapContextCreate(data, pixelsWide, pixelsHigh, bitsPerComponent, bitmapBytesPerRow, colorSpace, kCGImageAlphaNone);

	static const CGFloat fadeWidth = 8;
	static const CGFloat components[] = { 1, 1, 0, 1 };
	static const CGFloat locations[] = { 0, 1 };
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
	
	CGContextDrawLinearGradient(ctxt, gradient, CGPointMake(size.width - fadeWidth, 0), CGPointMake(size.width, 0), kCGGradientDrawsBeforeStartLocation);
    CGImageRef mask = CGBitmapContextCreateImage(ctxt);

	CGGradientRelease(gradient);
	CGContextRelease(ctxt);
	free(data);
	CGColorSpaceRelease(colorSpace);
	
	return mask;
}


- (void)drawYearLabels {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	if (p.scaleX * 365 < 45) {
		formatter.dateFormat = @"’yy";
	} else {
		formatter.dateFormat = @"y";
	}
	
	[[UIColor blackColor] setFill];
	
	UIFont *font = [UIFont systemFontOfSize:20];
	
	EWMonth month = EWMonthDayGetMonth(beginMonthDay);
	month -= (month % 12) + 12; // adjust to earlier january
	
	CGFloat x = EWDaysBetweenMonthDays(beginMonthDay, EWMonthDayMake(month, 1));
	
	while (month < (EWMonthDayGetMonth(endMonthDay) + 12)) {
		CGFloat width = EWDaysBetweenMonthDays(EWMonthDayMake(month, 1), EWMonthDayMake(month + 12, 1));
		
		NSDate *date = EWDateFromMonthAndDay(month, 1);
		NSString *text = [formatter stringFromDate:date];
		
		CGRect clipRect = CGRectMake(x * p.scaleX, 0, width * p.scaleX, 100);
		CGSize textSize = [text sizeWithFont:font];
		CGPoint textPoint = CGPointMake(x * p.scaleX + kLabelOffsetX, kLabelOffsetY);
		
		if (textSize.width > clipRect.size.width) {
			CGContextRef context = UIGraphicsGetCurrentContext();
			CGContextSaveGState(context);
			CGImageRef maskImage = [self newMaskOfSize:clipRect.size];
			CGContextClipToMask(context, clipRect, maskImage);
			CGImageRelease(maskImage);
			[text drawAtPoint:textPoint withFont:font];
			CGContextRestoreGState(context);
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
	formatter.dateFormat = NSLocalizedString(@"MMMM y", @"Month Year date format");
	
	[[UIColor blackColor] setFill];
	
	UIFont *font = [UIFont systemFontOfSize:20];
		
	EWMonth month = EWMonthDayGetMonth(beginMonthDay);
	CGFloat x = 1 - EWMonthDayGetDay(beginMonthDay);
	
	while (month <= EWMonthDayGetMonth(endMonthDay)) {
		CGFloat width = EWDaysInMonth(month);
		
		NSDate *date = EWDateFromMonthAndDay(month, 1);
		NSString *text = [formatter stringFromDate:date];

		CGRect clipRect = CGRectMake(x * p.scaleX, 0, width * p.scaleX, 100);
		CGSize textSize = [text sizeWithFont:font];
		CGPoint textPoint = CGPointMake(x * p.scaleX + kLabelOffsetX, kLabelOffsetY);
		
		if (textSize.width > clipRect.size.width) {
			CGContextRef context = UIGraphicsGetCurrentContext();
			CGContextSaveGState(context);
			CGImageRef maskImage = [self newMaskOfSize:clipRect.size];
			CGContextClipToMask(context, clipRect, maskImage);
			CGImageRelease(maskImage);
			[text drawAtPoint:textPoint withFont:font];
			CGContextRestoreGState(context);
		} else {
			[text drawAtPoint:textPoint withFont:font];
		}
		
		month += 1;
		x += width;
	}
	
	[formatter release];
}


- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();

	if (image != NULL) {
		CGRect bounds = self.bounds;
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
		
		CGColorSpaceRef space = CGColorSpaceCreatePattern(NULL);
		CGContextSetFillColorSpace(context, space);
		const CGFloat alpha[] = { 1.0f };
		CGContextSetFillPattern(context, pattern, alpha);
		CGContextFillRect(context, self.bounds);
		CGColorSpaceRelease(space);
	}

	if (p) {
		if (p.scaleX * 30 < 28) {
			[self drawYearLabels];
		} else {
			[self drawMonthLabels];
		}
	}
	
	if (drawBorder) {
		CGFloat y = CGRectGetMaxY(self.bounds) - 0.5f;
		CGFloat x = CGRectGetMaxX(self.bounds);
		CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
		CGContextSetLineWidth(context, 1);
		CGContextMoveToPoint(context, 0, y);
		CGContextAddLineToPoint(context, x, y);
		CGContextStrokePath(context);
	}
}


#pragma mark Image Export


- (UIImage *)exportableImage {
	CGRect contextRect = self.bounds;

	if (yAxisView) {
		contextRect.size.width += CGRectGetWidth(yAxisView.bounds);
	}
	
	if (UIGraphicsBeginImageContextWithOptions) {
		UIGraphicsBeginImageContextWithOptions(contextRect.size, YES, 0);
	} else {
		UIGraphicsBeginImageContext(contextRect.size);
	}
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 1, 1, 1, 1);
	CGContextFillRect(context, contextRect);
	
	BOOL oldBorderState = drawBorder;
	drawBorder = NO;

	if (yAxisView) {
		CGRect yAxisBounds = yAxisView.bounds;
		CGFloat w = CGRectGetWidth(yAxisBounds);
		CGContextSaveGState(context);
		CGContextTranslateCTM(context, w, 0);
		CGContextClipToRect(context, self.bounds);
		[self drawRect:self.bounds];
		CGContextRestoreGState(context);
		[yAxisView drawRect:yAxisBounds];
	} else {
		[self drawRect:self.bounds];
	}
	
	drawBorder = oldBorderState;

	UIImage *exportImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return exportImage;
}


- (void)exportImageToSavedPhotos {
	UIImageWriteToSavedPhotosAlbum([self exportableImage], nil, nil, nil);
}


- (void)exportImageToPasteboard {
	[[UIPasteboard generalPasteboard] setImage:[self exportableImage]];
}


- (void)copy:(id)sender {
	[self exportImageToPasteboard];
}


#pragma mark Cleanup


- (void)dealloc {
	CGImageRelease(image);
	[yAxisView release];
	[super dealloc];
}


@end
