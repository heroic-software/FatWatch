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
@synthesize month;
@synthesize p;
@synthesize bounds;
@synthesize image;


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


- (void)setMonth:(EWMonth)m {
	month = m;
	
	Database *database = [Database sharedDatabase];

	pointCount = 0;
	
	MonthData *md = [database dataForMonth:month];
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
	
	if (month > [database earliestMonth]) {
		MonthData *md = [database dataForMonth:(month - 1)];
		EWDay day = [md lastDayWithWeight];
		if (day > 0) {
			float trend = [md trendWeightOnDay:day];
			NSInteger dayCount = EWDaysInMonth(month - 1);
			headPoint.x = day - dayCount;
			headPoint.y = trend;
		}
	}
	
	if (month < [database latestMonth]) {
		MonthData *md = [database dataForMonth:(month + 1)];
		EWDay day = [md firstDayWithWeight];
		if (day > 0) {
			float trend = [md trendWeightOnDay:day];
			tailPoint.x = EWDaysInMonth(month) + day;
			tailPoint.y = trend;
		}
	}
}


#pragma mark Secondary Thread


- (CGPathRef)createWeekendsBackgroundPath {
	CGMutablePathRef path = NULL;
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HighlightWeekends"]) {
		path = CGPathCreateMutable();
		CGFloat h = p->maxWeight - p->minWeight;
		CGRect dayRect = CGRectMake(0, p->minWeight, 1, h);
		
		EWDay day = 1;
		NSUInteger lastDay = EWDaysInMonth(month);
		NSInteger wd = EWWeekdayFromMonthAndDay(month, 1);
		
		if (wd != 1 && wd != 7) {
			day += (7 - wd);
			wd = 7;
		}
		
		while (day <= lastDay) {
			dayRect.origin.x = day - 0.5;
			CGPathAddRect(path, &p->t, dayRect);
			if (wd == 1) {
				day += 6;
				wd = 7;
			} else {
				day += 1;
				wd = 1;
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


- (CGPathRef)createTrendPath {
	CGMutablePathRef path = CGPathCreateMutable();
		
	if (headPoint.y > 0) {
		CGPathMoveToPoint(path, &p->t, headPoint.x, headPoint.y);
		CGPathAddLineToPoint(path, &p->t, trendPoints[0].x, trendPoints[0].y);
	}
	
	CGPathAddLines(path, &p->t, trendPoints, pointCount);
	
	if (tailPoint.y > 0) {
		CGPathAddLineToPoint(path, &p->t, tailPoint.x, tailPoint.y);
	}
	
	return path;
}


- (CGPathRef)createMarksPathUsingFlaggedPoints:(BOOL)filter {
	CGMutablePathRef path = CGPathCreateMutable();
	
	const CGFloat markRadius = 0.5 * kDayWidth;
	
	NSInteger k;
	for (k = 0; k < pointCount; k++) {
		if (flags[k] == filter) {
			CGPoint scalePoint = CGPointApplyAffineTransform(scalePoints[k], p->t);
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
	
	return path;
}


- (CGPathRef)createErrorLinesPath {
	CGMutablePathRef path = CGPathCreateMutable();
	
	const CGFloat markRadius = 0; //0.45 * p->scaleX;
	
	NSInteger k;
	for (k = 0; k < pointCount; k++) {
		CGPoint scalePoint = CGPointApplyAffineTransform(scalePoints[k], p->t);
		CGPoint trendPoint = CGPointApplyAffineTransform(trendPoints[k], p->t);
		
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
			
			x = 1 + roundf([goal.startDate timeIntervalSinceDate:firstOfMonth] / SecondsPerDay);
			CGPathMoveToPoint(path, &p->t, x, goal.startWeight);
			
			x = 1 + roundf([goal.endDate timeIntervalSinceDate:firstOfMonth] / SecondsPerDay);
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
	
	for (NSArray *region in p->regions) {
		CGRect rect = [[region objectAtIndex:0] CGRectValue];
		UIColor *color = [region objectAtIndex:1];
		CGContextSetFillColorWithColor(ctxt, [color CGColor]);
		CGContextFillRect(ctxt, CGRectApplyAffineTransform(rect, p->t));
	}
	
	// name of month and year
	
	[GraphDrawingOperation drawCaptionForMonth:month inContext:ctxt];
		
	if (pointCount > 0) {
		CGContextSaveGState(ctxt);
				
		CGContextSetRGBStrokeColor(ctxt, 0.5,0.5,0.5, 1.0);
		CGContextSetLineWidth(ctxt, 2.0f);
		CGPathRef errorLinesPath = [self createErrorLinesPath];
		CGContextAddPath(ctxt, errorLinesPath);
		CGContextStrokePath(ctxt);
		CGPathRelease(errorLinesPath);

		// trend line
		
		CGContextSetRGBStrokeColor(ctxt, 0.8,0.1,0.1, 1.0);
		CGContextSetLineWidth(ctxt, 3.0f);
		CGPathRef trendPath = [self createTrendPath];
		CGContextAddPath(ctxt, trendPath);
		CGContextStrokePath(ctxt);
		CGPathRelease(trendPath);
		
		// weight marks: colored centers (white or yellow)
		// weight marks: outlines and error lines

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
	[super dealloc];
}


@end
