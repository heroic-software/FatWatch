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
@synthesize imageRef;
@synthesize beginMonthDay;
@synthesize endMonthDay;


- (void)computePoints {

	dayCount = 1 + EWDaysBetweenMonthDays(beginMonthDay, endMonthDay);
	
	EWMonthDay mdStart = p->mdEarliest;
	EWMonthDay mdStop = p->mdLatest;
	
	if (mdStart == 0 || mdStop == 0) {
		return; // no data, nothing to draw!
	}
	
	CGFloat x;
	
	Database *db = [Database sharedDatabase];

	if (mdStart < beginMonthDay) {
		// If we requested a start after actual data starts, start there.
		x = 1;
		mdStart = beginMonthDay;
		// Compute head point, because there is earlier data.
		EWMonthDay mdHead = [db monthDayOfWeightBefore:mdStart];
		if (mdHead != 0) {
			headPoint.x = x + EWDaysBetweenMonthDays(mdStart, mdHead);
			headPoint.y = [db trendWeightOnMonthDay:mdHead];
		}
	} else {
		// Otherwise, bump X to compensate.
		x = 1 + EWDaysBetweenMonthDays(beginMonthDay, mdStart);
		// don't need to compute headPoint because there is no earlier data
	}
	
	if (endMonthDay < mdStop) {
		// If we requested an end before data ends, stop there.
		mdStop = endMonthDay;
		// Compute tail point, because there is later data.
		EWMonthDay mdTail = [db monthDayOfWeightAfter:mdStop];
		if (mdTail != 0) {
			tailPoint.x = x + EWDaysBetweenMonthDays(mdStart, mdTail);
			tailPoint.y = [db trendWeightOnMonthDay:mdTail];
		}
	}
	
	pointData = [[NSMutableData alloc] initWithCapacity:31 * sizeof(GraphPoint)];
	
	MonthData *data = nil;
	EWMonthDay md;
	for (md = mdStart; md <= mdStop; md = EWMonthDayNext(md)) {
		EWDay day = EWMonthDayGetDay(md);
		if (data == nil || day == 1) {
			data = [db dataForMonth:EWMonthDayGetMonth(md)];
		}
		float scale = [data scaleWeightOnDay:day];
		if (scale > 0) {
			float trend = [data trendWeightOnDay:day];
			GraphPoint gp;
			gp.scale = CGPointMake(x, scale);
			gp.trend = CGPointMake(x, trend);
			gp.flag = [data isFlaggedOnDay:day];
			[pointData appendBytes:&gp length:sizeof(GraphPoint)];
		}
		x += 1;
	}
}


- (CGPathRef)createWeekendsBackgroundPath {
	// If a single day is less than a pixel wide, don't bother.
	if (p->scaleX < 1) return NULL;
	
	// If weekend shading has been disabled, don't do anything.
	if (! [[NSUserDefaults standardUserDefaults] boolForKey:@"HighlightWeekends"]) return NULL;

	CGMutablePathRef path = CGPathCreateMutable();
	CGFloat h = p->maxWeight - p->minWeight;
	
	NSUInteger wd = EWWeekdayFromMonthAndDay(EWMonthDayGetMonth(beginMonthDay), 
											 EWMonthDayGetDay(beginMonthDay));

	if (wd == 1) {
		CGPathAddRect(path, &p->t, CGRectMake(0.5, p->minWeight, 1, h));
	}
	
	CGRect dayRect = CGRectMake(7.5 - wd, p->minWeight, 2, h);
	while (dayRect.origin.x < dayCount) {
		CGPathAddRect(path, &p->t, dayRect);
		dayRect.origin.x += 7;
	}
	
	return path;
}


- (CGPathRef)createGridPath {
	CGMutablePathRef gridPath = CGPathCreateMutable();
	// vertical lines

	CGFloat x = 0.5;
	EWMonthDay md = beginMonthDay;
	
	while (md <= endMonthDay) {
		EWMonth month = EWMonthDayGetMonth(md);
		EWDay day = EWMonthDayGetDay(md);
		if (day == 1) {
			CGPathMoveToPoint(gridPath, &p->t, x, p->minWeight);
			CGPathAddLineToPoint(gridPath, &p->t, x, p->maxWeight);
			x += EWDaysInMonth(month);
		} else {
			x += EWDaysInMonth(month) - day + 1;
		}
		md = EWMonthDayMake(month + 1, 1);
	}
	
	// horizontal lines:
	float w;
	for (w = p->gridMinWeight; w < p->gridMaxWeight; w += p->gridIncrementWeight) {
		CGPathMoveToPoint(gridPath, &p->t, -0.5, w);
		CGPathAddLineToPoint(gridPath, &p->t, dayCount + 1, w);
	}
	return gridPath;
}


- (void)drawNoDataWarningInContext:(CGContextRef)ctxt {
	const CGFloat fontSize = 30;
	
	CGContextSetGrayFillColor(ctxt, 0.3, 1);
	CGContextSetTextMatrix(ctxt, CGAffineTransformMakeScale(1.0, -1.0));
	CGContextSelectFont(ctxt, "Helvetica-Bold", fontSize, kCGEncodingMacRoman);
	
	NSString *warningString = NSLocalizedString(@"CHART_NO_DATA", nil);
	NSData *text = [warningString dataUsingEncoding:NSMacOSRomanStringEncoding];
	
	CGPoint leftPoint = CGContextGetTextPosition(ctxt);
	CGContextSetTextDrawingMode(ctxt, kCGTextInvisible);
	CGContextShowText(ctxt, [text bytes], [text length]);
	CGPoint rightPoint = CGContextGetTextPosition(ctxt);
	CGContextSetTextDrawingMode(ctxt, kCGTextFill);
	
	CGSize size = CGSizeMake(rightPoint.x - leftPoint.x, fontSize);
	
	CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
	center.x -= size.width / 2;
	center.y += size.height / 2;
	CGContextShowTextAtPoint(ctxt, center.x, center.y, [text bytes], [text length]);
}


- (CGPathRef)createTrendPath {
	CGMutablePathRef path = CGPathCreateMutable();
	
	NSUInteger gpCount = [pointData length] / sizeof(GraphPoint);
	if (gpCount > 0) {
		const GraphPoint *gp = [pointData bytes];
		
		if (headPoint.y > 0) {
			CGPathMoveToPoint(path, &p->t, headPoint.x, headPoint.y);
			CGPathAddLineToPoint(path, &p->t, gp[0].trend.x, gp[0].trend.y);
		} else {
			CGPathMoveToPoint(path, &p->t, gp[0].trend.x, gp[0].trend.y);
		}
		
		int k;
		for (k = 1; k < gpCount; k++) {
			CGPathAddLineToPoint(path, &p->t, gp[k].trend.x, gp[k].trend.y);
		}

		if (tailPoint.y > 0) {
			CGPathAddLineToPoint(path, &p->t, tailPoint.x, tailPoint.y);
		}
	}
	
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
	} else if (p->shouldDrawNoDataWarning) {
		[self drawNoDataWarningInContext:ctxt];
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
	
    imageRef = CGBitmapContextCreateImage(ctxt);

	void *bitmapData = CGBitmapContextGetData(ctxt); 
    CGContextRelease(ctxt);
    if (bitmapData) free(bitmapData);

#if TARGET_IPHONE_SIMULATOR
	// Simulate iPhone's slow drawing
	[NSThread sleepForTimeInterval:0.5];
#endif
	
	[delegate performSelectorOnMainThread:@selector(drawingOperationComplete:) 
							   withObject:self
							waitUntilDone:NO];
}


- (void)dealloc {
	CGImageRelease(imageRef);
	[pointData release];
	[super dealloc];
}


@end
