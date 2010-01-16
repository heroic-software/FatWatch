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


@synthesize selected;
@synthesize image;
@synthesize beginMonthDay;
@synthesize endMonthDay;
@synthesize p;
@synthesize yAxisView;
@synthesize drawBorder;


- (id)initWithFrame:(CGRect)frame {
	if ([super initWithFrame:frame]) {
		self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}


- (void)setSelected:(BOOL)flag {
	if (selected != flag) {
		selected = flag;
		[self setNeedsDisplay];
	}
}


- (void)setImage:(CGImageRef)newImage {
	if (image != newImage) {
		CGImageRetain(newImage);
		CGImageRelease(image);
		image = newImage;
	}
}


- (CGImageRef)newMaskOfSize:(CGSize)size {
	const int bitsPerComponent = 8;
	const int bytesPerPixel = 1;
	int pixelsWide = size.width;
	int pixelsHigh = size.height;
	int bitmapBytesPerRow   = (pixelsWide * bytesPerPixel);
	void *bitmapData = calloc(pixelsHigh, bitmapBytesPerRow);
	
	// TODO: replace bitmapData with NULL
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef ctxt = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, bitsPerComponent, bitmapBytesPerRow, colorSpace, kCGImageAlphaNone);

	static const CGFloat fadeWidth = 8;
	static const CGFloat components[] = { 1, 1, 0, 1 };
	static const CGFloat locations[] = { 0, 1 };
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
	
	CGContextDrawLinearGradient(ctxt, gradient, CGPointMake(size.width - fadeWidth, 0), CGPointMake(size.width, 0), kCGGradientDrawsBeforeStartLocation);
    CGImageRef mask = CGBitmapContextCreateImage(ctxt);

	CGGradientRelease(gradient);
	CGContextRelease(ctxt);
	CGColorSpaceRelease(colorSpace);
	free(bitmapData);

	// TODO: confirm this bug on device
	// 3.0 CFVersion 478.470000
	// 3.1 CFVersion 478.520000
	if (kCFCoreFoundationVersionNumber == 478.47) {
		CFRetain(CGImageGetDataProvider(mask));
	}

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

		CGRect clipRect = CGRectMake(x * p->scaleX, 0, width * p->scaleX, 100);
		CGSize textSize = [text sizeWithFont:font];
		CGPoint textPoint = CGPointMake(x * p->scaleX + kLabelOffsetX, kLabelOffsetY);
		
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
		const CGFloat alpha[] = { 1.0 };
		CGContextSetFillPattern(context, pattern, alpha);
		CGContextFillRect(context, self.bounds);
		CGColorSpaceRelease(space);
	}

	if (p) {
		if (p->scaleX < 1) {
			[self drawYearLabels];
		} else {
			[self drawMonthLabels];
		}
	}
	
	if (selected) {
		CGContextSetRGBFillColor(context, 0, 0, 0, 0.2f);
		CGContextFillRect(context, rect);
	}
	
	if (drawBorder && !exporting) {
		CGFloat y = CGRectGetMaxY(self.bounds) - 0.5;
		CGFloat x = CGRectGetMaxX(self.bounds);
		CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
		CGContextSetLineWidth(context, 1);
		CGContextMoveToPoint(context, 0, y);
		CGContextAddLineToPoint(context, x, y);
		CGContextStrokePath(context);
	}
}


#pragma mark Image Export


- (void)beginExport {
	if (image) {
		exporting = YES;
		self.selected = YES;
		[self performSelector:@selector(showExportActionSheet) withObject:nil afterDelay:1];
	}
}


- (void)cancelExport {
	if (exporting) {
		exporting = NO;
		self.selected = NO;
		[GraphView cancelPreviousPerformRequestsWithTarget:self selector:@selector(showExportActionSheet) object:nil];
	}
}


- (void)showExportActionSheet {
	UIActionSheet *sheet = [[UIActionSheet alloc] init];
	sheet.delegate = self;
	[sheet addButtonWithTitle:NSLocalizedString(@"Save Image", @"Save image")];
	[sheet addButtonWithTitle:NSLocalizedString(@"Copy", @"Copy image")];
	sheet.cancelButtonIndex = 
	[sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel image")];
	if (self.window) {
		[sheet showInView:self.window];
	} else {
		NSLog(@"Can't show sheet: GraphView.window = nil");
	}
	[sheet release];
}


- (UIImage *)exportableImage {
	CGRect contextRect = self.bounds;

	if (yAxisView) {
		contextRect.size.width += CGRectGetWidth(yAxisView.bounds);
	}
	
	UIGraphicsBeginImageContext(contextRect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 1, 1, 1, 1);
	CGContextFillRect(context, contextRect);

	if (yAxisView) {
		CGRect yAxisBounds = yAxisView.bounds;
		CGFloat w = CGRectGetWidth(yAxisBounds);
		CGContextTranslateCTM(context, w, 0);
		[self drawRect:self.bounds];
		CGContextTranslateCTM(context, -w, 0);
		[yAxisView drawRect:yAxisBounds];
	} else {
		[self drawRect:self.bounds];
	}

	UIImage *exportImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return exportImage;
}


- (void)exportImageToSavedPhotos {
	UIImageWriteToSavedPhotosAlbum([self exportableImage], nil, nil, nil);
}


- (void)copy:(id)sender {
	[[UIPasteboard generalPasteboard] setImage:[self exportableImage]];
}


#pragma mark UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	self.selected = NO;
	if (buttonIndex == 0) {
		[self exportImageToSavedPhotos];
	}
	else if (buttonIndex == 1) {
		[self copy:nil];
	}
	exporting = NO;
}


#pragma mark UIView Touches


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self beginExport];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self cancelExport];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self cancelExport];
}


#pragma mark Cleanup


- (void)dealloc {
	CGImageRelease(image);
	[yAxisView release];
	[super dealloc];
}


@end
