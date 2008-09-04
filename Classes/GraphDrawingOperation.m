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


@implementation GraphDrawingOperation


@synthesize delegate;
@synthesize index;
@synthesize month;
@synthesize p;
@synthesize bounds;
@synthesize image;


- (CGPathRef)createWeekendsBackgroundPath {
	CGMutablePathRef path = NULL;
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HighlightWeekends"]) {
		path = CGPathCreateMutable();
		
		// better algorithm: get weekday of first day, then increment by 2 and 5
		CGFloat h = p->maxWeight - p->minWeight;
		NSUInteger dayCount = EWDaysInMonth(month);
		EWDay day;
		for (day = 1; day <= dayCount; day++) {
			if (EWMonthAndDayIsWeekend(month, day)) {
				CGRect dayRect = CGRectMake(day - 0.5, p->minWeight, 1, h);
				CGPathAddRect(path, &p->t, dayRect);
			}
		}
	}
	
	return path;
}


- (CGPathRef)createGridPath {
	NSUInteger dayCount = EWDaysInMonth(month);
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


- (void)drawMonthYearCaptionInContext:(CGContextRef)ctxt {
	static NSDateFormatter *formatter = nil;
	
	if (formatter == nil) {
		formatter = [[NSDateFormatter alloc] init];
		formatter.formatterBehavior = NSDateFormatterBehavior10_4;
		formatter.dateFormat = NSLocalizedString(@"MONTH_YEAR_DATE_FORMAT", nil);
	}
	// month and year label at the top
	NSDate *date = EWDateFromMonthAndDay(month, 1);
	
	CGContextSetGrayFillColor(ctxt, 0, 1);
	
	NSData *text = [[formatter stringFromDate:date] dataUsingEncoding:NSMacOSRomanStringEncoding];
	
	CGContextSetTextMatrix(ctxt, CGAffineTransformMakeScale(1.0, -1.0));
	CGContextSelectFont(ctxt, "Helvetica", 20, kCGEncodingMacRoman);
	CGContextShowTextAtPoint(ctxt, 4, 22, [text bytes], [text length]);
}


- (NSUInteger)computeScalePoints:(CGPoint *)scalePoints trendPoints:(CGPoint *)trendPoints flags:(BOOL *)flags {
	NSUInteger pointCount = 0;
	
	MonthData *md = [[Database sharedDatabase] dataForMonth:month];
	NSUInteger dayCount = EWDaysInMonth(month);
	EWDay day;
	for (day = 1; day <= dayCount; day++) {
		float measured = [md measuredWeightOnDay:day];
		if (measured > 0) {
			float trend = [md trendWeightOnDay:day];
			scalePoints[pointCount] = CGPointMake(day, measured);
			trendPoints[pointCount] = CGPointMake(day, trend);
			flags[pointCount] = [md isFlaggedOnDay:day];
			pointCount++;
		}
	}
	
	return pointCount;
}


- (CGPathRef)createTrendPathFromPoints:(CGPoint *)trendPoints count:(NSUInteger)pointCount {
	CGMutablePathRef path = CGPathCreateMutable();
	
	Database *database = [Database sharedDatabase];
	
	if (month > [database earliestMonth]) {
		MonthData *md = [database dataForMonth:(month - 1)];
		EWDay day = [md lastDayWithWeight];
		if (day > 0) {
			float trend = [md trendWeightOnDay:day];
			NSInteger dayCount = EWDaysInMonth(month - 1);
			CGPathMoveToPoint(path, &p->t, day - dayCount, trend);
			CGPathAddLineToPoint(path, &p->t, trendPoints[0].x, trendPoints[0].y);
		}
	}
	
	CGPathAddLines(path, &p->t, trendPoints, pointCount);
	
	if (month < [database latestMonth]) {
		MonthData *md = [database dataForMonth:(month + 1)];
		EWDay day = [md firstDayWithWeight];
		if (day > 0) {
			float trend = [md trendWeightOnDay:day];
			CGPathAddLineToPoint(path, &p->t, EWDaysInMonth(month) + day, trend);
		}
	}
	
	return path;
}


- (CGPathRef)createMarksPathFromScalePoints:(CGPoint *)scalePoints trendPoints:(CGPoint *)trendPoints flags:(BOOL *)flags count:(NSUInteger)pointCount usingFlaggedPoints:(BOOL)filter {
	CGMutablePathRef path = CGPathCreateMutable();
	
	const CGFloat markRadius = 0.45 * p->scaleX;
	
	NSInteger k;
	for (k = 0; k < pointCount; k++) {
		if (flags[k] == filter) {
			CGPoint scalePoint = CGPointApplyAffineTransform(scalePoints[k], p->t);
			CGPoint trendPoint = CGPointApplyAffineTransform(trendPoints[k], p->t);
			
			if (ABS(scalePoint.y - trendPoint.y) > markRadius) {
				CGFloat y = scalePoint.y;
				if (trendPoint.y < scalePoint.y) {
					y -= markRadius;
				} else {
					y += markRadius;
				}
				CGPathMoveToPoint(path, NULL, trendPoint.x, trendPoint.y);
				CGPathAddLineToPoint(path, NULL, scalePoint.x, y);
			}
			
			/*/
			 CGPathMoveToPoint(path, NULL, scalePoint.x, scalePoint.y + markRadius);
			 CGPathAddLineToPoint(path, NULL, scalePoint.x + markRadius, scalePoint.y);
			 CGPathAddLineToPoint(path, NULL, scalePoint.x, scalePoint.y - markRadius);
			 CGPathAddLineToPoint(path, NULL, scalePoint.x - markRadius, scalePoint.y);
			 CGPathCloseSubpath(path);
			 /*/
			CGRect markRect = CGRectMake(scalePoint.x - markRadius, scalePoint.y - markRadius, 2*markRadius, 2*markRadius);
			CGPathAddEllipseInRect(path, NULL, markRect);
		}
	}
	
	return path;
}


- (CGPathRef)createGoalPath {
	CGMutablePathRef path = NULL;
	
	EWGoal *goal = [EWGoal sharedGoal];
	if (goal.defined) {
		path = CGPathCreateMutable();
		
		EWMonth startMonth = EWMonthDayGetMonth(goal.startMonthDay);
		if (month >= startMonth) {
			NSDate *firstOfMonth = EWDateFromMonthAndDay(month, 1);
			CGFloat x;
			
			x = [goal.startDate timeIntervalSinceDate:firstOfMonth] / 86400;
			CGPathMoveToPoint(path, &p->t, x, goal.startWeight);
			
			x = [goal.endDate timeIntervalSinceDate:firstOfMonth] / 86400;
			CGPathAddLineToPoint(path, &p->t, x, goal.endWeight);
			
			CGFloat dayCount = EWDaysInMonth(month);
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
	CGContextRef ctxt = [self createBitmapContext];
	
	// shaded background to show weekends
	
	CGPathRef weekendsBackgroundPath = [self createWeekendsBackgroundPath];
	if (weekendsBackgroundPath) {
		CGContextAddPath(ctxt, weekendsBackgroundPath);
		CGContextSetGrayFillColor(ctxt, 0.9, 1.0);
		CGContextFillPath(ctxt);
		CFRelease(weekendsBackgroundPath);
	}
	
	// vertical grid line to indicate start of month
	// horizontal grid lines at weight intervals
	
	CGPathRef gridPath = [self createGridPath];
	CGContextAddPath(ctxt, gridPath);
	CGContextSetGrayStrokeColor(ctxt, 0.8, 1.0);
	CGContextStrokePath(ctxt);
	CFRelease(gridPath);
	
	// name of month and year
	
	[self drawMonthYearCaptionInContext:ctxt];
	
	CGPoint scalePoints[31];
	CGPoint trendPoints[31];
	BOOL flags[31];
	NSUInteger pointCount = [self computeScalePoints:scalePoints trendPoints:trendPoints flags:flags];
	
	if (pointCount > 0) {
		CGContextSaveGState(ctxt);
		
		CGContextSetLineJoin(ctxt, kCGLineJoinMiter);
		CGContextSetShadow(ctxt, CGSizeMake(2, -1), 1.5);
		
		// trend line
		
		CGPathRef trendPath = [self createTrendPathFromPoints:trendPoints count:pointCount];
		CGContextAddPath(ctxt, trendPath);
		CGContextSetGrayStrokeColor(ctxt, 0.0, 1.0);
		CGContextSetLineWidth(ctxt, 3.0f);
		CGContextStrokePath(ctxt);
		CFRelease(trendPath);
		
		// weight marks: colored centers (white or yellow)
		// weight marks: outlines and error lines
		
		CGContextSetLineWidth(ctxt, 1.0f);
		
		CGPathRef unflaggedMarksPath = [self createMarksPathFromScalePoints:scalePoints trendPoints:trendPoints flags:flags count:pointCount usingFlaggedPoints:NO];
		CGContextSetRGBFillColor(ctxt, 1.0, 1.0, 1.0, 1.0); // white for unflagged
		CGContextAddPath(ctxt, unflaggedMarksPath);
		CGContextDrawPath(ctxt, kCGPathFillStroke);
		CFRelease(unflaggedMarksPath);
		
		CGPathRef flaggedMarksPath = [self createMarksPathFromScalePoints:scalePoints trendPoints:trendPoints flags:flags count:pointCount usingFlaggedPoints:YES];
		CGContextSetRGBFillColor(ctxt, 1.0, 1.0, 0.0, 1.0); // yellow for flagged
		CGContextAddPath(ctxt, flaggedMarksPath);
		CGContextDrawPath(ctxt, kCGPathFillStroke);
		CFRelease(flaggedMarksPath);
		
		CGContextRestoreGState(ctxt);
	}
	
	// goal line: sloped part
	// goal line: flat part
	
	CGPathRef goalPath = [self createGoalPath];
	if (goalPath) {
		static const CGFloat kDashLengths[] = { 4, 2 };
		static const int kDashLengthsCount = 2;
		
		CGContextSetLineWidth(ctxt, 3);
		CGContextSetLineDash(ctxt, 0, kDashLengths, kDashLengthsCount);
		CGContextSetRGBStrokeColor(ctxt, 0.0, 0.8, 0.0, 0.8);
		CGContextAddPath(ctxt, goalPath);
		CGContextStrokePath(ctxt);
	}
	
    CGImageRef imageRef = CGBitmapContextCreateImage(ctxt);
	image = [[UIImage alloc] initWithCGImage:imageRef];
	CGImageRelease(imageRef);

	void *bitmapData = CGBitmapContextGetData(ctxt); 
    CGContextRelease(ctxt);
    if (bitmapData) free(bitmapData);

#if TARGET_IPHONE_SIMULATOR
	// Simulate iPhone's slow drawing
	[NSThread sleepForTimeInterval:1];
#endif
	
	[delegate performSelectorOnMainThread:@selector(drawingOperationComplete:) withObject:self waitUntilDone:NO];
}


- (void)dealloc {
	[image release];
	[super dealloc];
}


@end
