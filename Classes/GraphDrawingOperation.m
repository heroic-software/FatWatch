//
//  GraphDrawingOperation.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 9/4/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "GraphDrawingOperation.h"
#import "Database.h"
#import "MonthData.h"
#import "EWGoal.h"
#import "WeightFormatters.h"


@implementation GraphDrawingOperation


@synthesize delegate;
@synthesize index;
@synthesize p;
@synthesize bounds;
@synthesize image;
@synthesize beginMonthDay;
@synthesize endMonthDay;


+ (void)drawCaptionForMonth:(EWMonth)month inContext:(CGContextRef)ctxt {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.formatterBehavior = NSDateFormatterBehavior10_4;
	formatter.dateFormat = NSLocalizedString(@"MONTH_YEAR_DATE_FORMAT", nil);
	
	// month and year label at the top
	NSDate *date = EWDateFromMonthAndDay(month, 1);
	
	CGContextSetRGBFillColor(ctxt, 0,0,0, 1);
	
	NSData *text = [[formatter stringFromDate:date] dataUsingEncoding:NSMacOSRomanStringEncoding];
	
	CGContextSetTextMatrix(ctxt, CGAffineTransformMakeScale(1.0, -1.0));
	CGContextSelectFont(ctxt, "Helvetica", 20, kCGEncodingMacRoman);
	CGContextShowTextAtPoint(ctxt, 4, 22, [text bytes], [text length]);
	
	[formatter release];
}


#pragma mark Main Thread


// Nothing any more


#pragma mark Secondary Thread


- (void)computePoints {

	Database *db = [Database sharedDatabase];

	EWMonth month = EWMonthDayGetMonth(beginMonthDay);
	MonthData *data = [db dataForMonth:month];
	
	pointData = [[NSMutableData alloc] initWithCapacity:31 * sizeof(GraphPoint)];
	
	dayCount = 1;

	EWMonthDay md;
	for (md = beginMonthDay; md <= endMonthDay; md = EWNextMonthDay(md)) {
		if (month != EWMonthDayGetMonth(md)) {
			month = EWMonthDayGetMonth(md);
			data = [db dataForMonth:month];
		}
		EWDay day = EWMonthDayGetDay(md);
		float scale = [data scaleWeightOnDay:day];
		if (scale > 0) {
			float trend = [data trendWeightOnDay:day];
			GraphPoint gp;
			gp.scale = CGPointMake(dayCount, scale);
			gp.trend = CGPointMake(dayCount, trend);
			gp.flag = [data isFlaggedOnDay:day];
			[pointData appendBytes:&gp length:sizeof(GraphPoint)];
		}
		dayCount += 1;
	}
}


- (CGPathRef)createWeekendsBackgroundPath {
	CGMutablePathRef path = NULL;
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HighlightWeekends"]) {
		path = CGPathCreateMutable();
		CGFloat h = p->maxWeight - p->minWeight;
		CGRect dayRect = CGRectMake(0.5, p->minWeight, 1, h);
		
		EWMonthDay md;
		for (md = beginMonthDay; md <= endMonthDay; md = EWNextMonthDay(md)) {
			if (EWMonthAndDayIsWeekend(EWMonthDayGetMonth(md), EWMonthDayGetDay(md))) {
				CGPathAddRect(path, &p->t, dayRect);
			}
			dayRect.origin.x += 1;
		}
	}
	
	return path;
}


- (CGPathRef)createGridPath {
	CGMutablePathRef gridPath = CGPathCreateMutable();
	CGPathMoveToPoint(gridPath, NULL, 0.5, CGRectGetMinY(bounds));
	CGPathAddLineToPoint(gridPath, NULL, 0.5, CGRectGetMaxY(bounds));
	float w;
	for (w = p->gridMinWeight; w < p->gridMaxWeight; w += p->gridIncrementWeight) {
		CGPathMoveToPoint(gridPath, &p->t, -0.5, w);
		CGPathAddLineToPoint(gridPath, &p->t, dayCount + 1, w);
	}
	return gridPath;
}


- (CGPathRef)createTrendPath {
	CGMutablePathRef path = CGPathCreateMutable();
		
//	if (headPoint.y > 0) {
//		CGPathMoveToPoint(path, &p->t, headPoint.x, headPoint.y);
//		CGPathAddLineToPoint(path, &p->t, trendPoints[0].x, trendPoints[0].y);
//	}
	
	NSUInteger gpCount = [pointData length] / sizeof(GraphPoint);
	if (gpCount > 0) {
		const GraphPoint *gp = [pointData bytes];
		CGPathMoveToPoint(path, &p->t, gp[0].trend.x, gp[0].trend.y);
		int k;
		for (k = 1; k < gpCount; k++) {
			CGPathAddLineToPoint(path, &p->t, gp[k].trend.x, gp[k].trend.y);
		}
	}
	
//	if (tailPoint.y > 0) {
//		CGPathAddLineToPoint(path, &p->t, tailPoint.x, tailPoint.y);
//	}
	
	return path;
}


- (CGPathRef)createMarksPathUsingFlaggedPoints:(BOOL)filter {
	CGMutablePathRef path = CGPathCreateMutable();
	
	const CGFloat markRadius = 0.5 * MIN(kDayWidth, p->scaleX);
	
	NSUInteger gpCount = [pointData length] / sizeof(GraphPoint);
	if (gpCount > 0) {
		const GraphPoint *gp = [pointData bytes];
		int k;
		for (k = 0; k < gpCount; k++) {
			if (gp[k].flag == filter) {
				CGPoint scalePoint = CGPointApplyAffineTransform(gp[k].scale, p->t);
				scalePoint.x = roundf(scalePoint.x);
				scalePoint.y = roundf(scalePoint.y);

				// Rhombus
				CGPathMoveToPoint(path, NULL, scalePoint.x, scalePoint.y + markRadius);
				CGPathAddLineToPoint(path, NULL, scalePoint.x + markRadius, scalePoint.y);
				CGPathAddLineToPoint(path, NULL, scalePoint.x, scalePoint.y - markRadius);
				CGPathAddLineToPoint(path, NULL, scalePoint.x - markRadius, scalePoint.y);
				CGPathCloseSubpath(path);
			}
		}
	}
	
	return path;
}


- (CGPathRef)createErrorLinesPath {
	CGMutablePathRef path = CGPathCreateMutable();
	
	const CGFloat markRadius = 0; //0.45 * p->scaleX;
	
	NSUInteger gpCount = [pointData length] / sizeof(GraphPoint);
	if (gpCount > 0) {
		const GraphPoint *gp = [pointData bytes];
		int k;
		for (k = 0; k < gpCount; k++) {
			CGPoint scalePoint = CGPointApplyAffineTransform(gp[k].scale, p->t);
			CGPoint trendPoint = CGPointApplyAffineTransform(gp[k].trend, p->t);
			
			CGFloat y = 0;
			
			CGFloat variance = scalePoint.y - trendPoint.y;
			if (variance > markRadius) {
				y = scalePoint.y - markRadius;
			} else if (variance < -markRadius) {
				y = scalePoint.y + markRadius;
			}
			
			if (y != 0) {
				CGPathMoveToPoint(path, NULL, trendPoint.x, trendPoint.y);
				CGPathAddLineToPoint(path, NULL, scalePoint.x, y);
			}
		}
	}
		
	return path;
}


- (CGPathRef)createGoalPath {
	CGMutablePathRef path = NULL;
	
	EWGoal *goal = [EWGoal sharedGoal];
	if (goal.defined) {
		path = CGPathCreateMutable();
		
		if (goal.startMonthDay < endMonthDay) {
			NSDate *firstOfGraph = EWDateFromMonthDay(beginMonthDay);
			CGFloat x;
			
			x = 1 + roundf([goal.startDate timeIntervalSinceDate:firstOfGraph] / SecondsPerDay);
			CGPathMoveToPoint(path, &p->t, x, goal.startWeight);
			
			x = 1 + roundf([goal.endDate timeIntervalSinceDate:firstOfGraph] / SecondsPerDay);
			CGPathAddLineToPoint(path, &p->t, x, goal.endWeight);
			
			if (x < dayCount) {
				CGPathAddLineToPoint(path, &p->t, dayCount + 1, goal.endWeight);
			}
		}
	}
	
	return path;
}


- (CGContextRef)createBitmapContext {
	int pixelsWide = CGRectGetWidth(bounds);
	int pixelsHigh = CGRectGetHeight(bounds);
	
	int bitmapBytesPerRow   = (pixelsWide * 4);
    int bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	void *bitmapData = malloc(bitmapByteCount);
	NSAssert(bitmapByteCount, @"could not allocate memory for bitmap");
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef ctxt = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8 /* bits per component */, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
	if (ctxt == NULL) {
		free(bitmapData);
		NSAssert(NO, @"could not create bitmap context");
	}
	CGColorSpaceRelease(colorSpace);
	
	CGContextTranslateCTM(ctxt, 0, pixelsHigh);
	CGContextScaleCTM(ctxt, 1, -1);
	
	return ctxt;
}


- (void)main {
	[self computePoints];
	
	CGContextRef ctxt = [self createBitmapContext];
	
	// shaded background to show weekends
	
	CGPathRef weekendsBackgroundPath = [self createWeekendsBackgroundPath];
	if (weekendsBackgroundPath) {
		CGContextAddPath(ctxt, weekendsBackgroundPath);
		CGContextSetRGBFillColor(ctxt, 0.9,0.9,0.9, 1.0);
		CGContextFillPath(ctxt);
		CGPathRelease(weekendsBackgroundPath);
	}
	
	// vertical grid line to indicate start of month
	// horizontal grid lines at weight intervals
	
	CGPathRef gridPath = [self createGridPath];
	CGContextAddPath(ctxt, gridPath);
	CGContextSetRGBStrokeColor(ctxt, 0.8,0.8,0.8, 1.0);
	CGContextStrokePath(ctxt);
	CGPathRelease(gridPath);

	// shade based on BMI
	
	if ([p->regions count] > 0) {
		static const CGFloat clearColorComponents[] = { 0, 0, 0, 0 };
		static const CGFloat gradientLocations[] = { 0.4, 1 };

		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CFMutableArrayRef colorArray = CFArrayCreateMutable(kCFAllocatorDefault, 2, &kCFTypeArrayCallBacks);
		CGColorRef clearColor = CGColorCreate(colorSpace, clearColorComponents);
		CFArraySetValueAtIndex(colorArray, 0, clearColor);
		CGColorRelease(clearColor);
		
		for (NSArray *region in p->regions) {
			CGRect rect = [[region objectAtIndex:0] CGRectValue];
			UIColor *color = [region objectAtIndex:1];
			
			CFArraySetValueAtIndex(colorArray, 1, [color CGColor]);

			CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colorArray, gradientLocations);
			
			CGPoint startPoint = CGPointApplyAffineTransform(CGPointMake(0, CGRectGetMinY(rect)), p->t);
			CGPoint endPoint = CGPointApplyAffineTransform(CGPointMake(0, CGRectGetMaxY(rect)), p->t);
			CGContextDrawLinearGradient(ctxt, gradient, startPoint, endPoint, 0);
			
			CGGradientRelease(gradient);
		}
		
		CFRelease(colorArray);
		CGColorSpaceRelease(colorSpace);
	}
	
	// name of month and year
	
	// TODO: draw at appropriate point
	[GraphDrawingOperation drawCaptionForMonth:EWMonthDayGetMonth(beginMonthDay) inContext:ctxt];
		
	if ([pointData length] > 0) {
		CGContextSaveGState(ctxt);
		
		BOOL drawMarks = (p->scaleX > 3);
		
		if (drawMarks) {
			CGContextSetRGBStrokeColor(ctxt, 0.5,0.5,0.5, 1.0);
			CGContextSetLineWidth(ctxt, 2.0f);
			CGPathRef errorLinesPath = [self createErrorLinesPath];
			CGContextAddPath(ctxt, errorLinesPath);
			CGContextStrokePath(ctxt);
			CGPathRelease(errorLinesPath);
		}

		// trend line
		
		CGContextSetRGBStrokeColor(ctxt, 0.8,0.1,0.1, 1.0);
		CGContextSetLineWidth(ctxt, 3.0f);
		CGPathRef trendPath = [self createTrendPath];
		CGContextAddPath(ctxt, trendPath);
		CGContextStrokePath(ctxt);
		CGPathRelease(trendPath);
		
		// weight marks: colored centers (white or yellow)
		// weight marks: outlines and error lines

		if (drawMarks) {
			CGContextSetLineWidth(ctxt, 1.5f);
			CGContextSetRGBStrokeColor(ctxt, 0,0,0, 1.0);
			
			CGContextSetRGBFillColor(ctxt, 1.0, 1.0, 1.0, 1.0); // white for unflagged
			CGPathRef unflaggedMarksPath = [self createMarksPathUsingFlaggedPoints:NO];
			CGContextAddPath(ctxt, unflaggedMarksPath);
			CGContextDrawPath(ctxt, kCGPathFillStroke);
			CGPathRelease(unflaggedMarksPath);
			
			CGContextSetRGBFillColor(ctxt, 0.2, 0.3, 0.8, 1.0);
			CGPathRef flaggedMarksPath = [self createMarksPathUsingFlaggedPoints:YES];
			CGContextAddPath(ctxt, flaggedMarksPath);
			CGContextDrawPath(ctxt, kCGPathFillStroke);
			CGPathRelease(flaggedMarksPath);
		}
		
		CGContextRestoreGState(ctxt);
	}
	
	// goal line: sloped part
	// goal line: flat part
	
	CGPathRef goalPath = [self createGoalPath];
	if (goalPath) {
		static const CGFloat kDashLengths[] = { 6, 3 };
		static const int kDashLengthsCount = 2;
		
		CGContextSetLineWidth(ctxt, 3);
		CGContextSetLineDash(ctxt, 0, kDashLengths, kDashLengthsCount);
		CGContextSetRGBStrokeColor(ctxt, 0.0, 0.6, 0.0, 0.8);
		CGContextAddPath(ctxt, goalPath);
		CGContextStrokePath(ctxt);
		CGPathRelease(goalPath);
	}
	
    CGImageRef imageRef = CGBitmapContextCreateImage(ctxt);
	image = [[UIImage alloc] initWithCGImage:imageRef];
	CGImageRelease(imageRef);

	void *bitmapData = CGBitmapContextGetData(ctxt); 
    CGContextRelease(ctxt);
    if (bitmapData) free(bitmapData);

#if TARGET_IPHONE_SIMULATOR
	// Simulate iPhone's slow drawing
	[NSThread sleepForTimeInterval:0.5];
#endif
	
	if ([self isCancelled]) return;
	
	[delegate performSelectorOnMainThread:@selector(drawingOperationComplete:) withObject:self waitUntilDone:NO];
}


- (void)dealloc {
	[image release];
	[pointData release];
	[super dealloc];
}


@end
