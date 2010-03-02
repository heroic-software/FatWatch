//
//  GraphDrawingOperation.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 9/4/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "GraphDrawingOperation.h"
#import "EWDatabase.h"
#import "EWDBMonth.h"
#import "EWGoal.h"
#import "EWWeightFormatter.h"
#import "SlopeComputer.h"
#import "NSUserDefaults+EWAdditions.h"
#import "BRColorPalette.h"


static NSOperationQueue *gDrawingQueue = nil;


static const CGFloat kGraphMarginTop = 32;
static const CGFloat kGraphMarginBottom = 24;
static const CGFloat kGraphMarginRight = 24;
static const CGFloat kBandHeight = 4;


static float EWChartWeightIncrementAfterIncrement(float previousIncrement) {
	switch ([[NSUserDefaults standardUserDefaults] weightUnit]) {
		case EWWeightUnitKilograms:
			return previousIncrement + (1 / kKilogramsPerPound);
		case EWWeightUnitStones:
			if (previousIncrement == 1) {
				return 7;
			} else {
				return previousIncrement + 7;
			}
		case EWWeightUnitPounds:
			if (previousIncrement == 1) {
				return 5;
			} else {
				return previousIncrement + 5;
			}
		default:
			return 0;
	}
}


#define GraphRegionMake(r, c) [NSArray arrayWithObjects:[NSValue valueWithCGRect:(r)], (c), nil]
#define GraphRegionGetRect(rgn) [[rgn objectAtIndex:0] CGRectValue]
#define GraphRegionGetColor(rgn) [rgn objectAtIndex:1]


@implementation GraphDrawingOperation


@synthesize delegate;
@synthesize index;
@synthesize p;
@synthesize bounds;
@synthesize imageRef;
@synthesize beginMonthDay;
@synthesize endMonthDay;
@synthesize showGoalLine;
@synthesize showTrajectoryLine;


#pragma mark Queue


+ (void)flushQueue {
	[gDrawingQueue cancelAllOperations];
	[gDrawingQueue waitUntilAllOperationsAreFinished];
}


- (void)enqueue {
	if (gDrawingQueue == nil) {
		gDrawingQueue = [[NSOperationQueue alloc] init];
	}
	
	[gDrawingQueue addOperation:self];
}


#pragma mark Graph Drawing


+ (void)prepareBMIRegionsForGraphViewParameters:(GraphViewParameters *)gp {
	if (! [[NSUserDefaults standardUserDefaults] isBMIEnabled]) return;
	
	if (! [[NSUserDefaults standardUserDefaults] highlightBMIZones]) return;
	
	float w[3];
	[EWWeightFormatter getBMIWeights:w];
	
	CGFloat width = 32; // at most 31 days in a month
	
	NSMutableArray *regions = [NSMutableArray arrayWithCapacity:4];
	
	CGRect rect;
	UIColor *color;
	CGFloat bandWeight = ((kBandHeight * 4) / gp->scaleY);
	CGRect wholeRect = CGRectMake(0,
								  gp->minWeight + bandWeight,
								  width,
								  gp->maxWeight - gp->minWeight - bandWeight);
	
	if (w[0] > gp->minWeight) {
		rect = CGRectMake(0, gp->minWeight, width, w[0] - gp->minWeight);
		rect = CGRectIntersection(wholeRect, rect);
		if (!CGRectIsEmpty(rect)) {
			color = [EWWeightFormatter backgroundColorForWeight:gp->minWeight];
			[regions addObject:GraphRegionMake(rect, color)];
		}
	}
	
	rect = CGRectMake(0, w[0], width, w[1] - w[0]);
	rect = CGRectIntersection(wholeRect, rect);
	if (!CGRectIsEmpty(rect)) {
		color = [EWWeightFormatter backgroundColorForWeight:0.5f*(w[0]+w[1])];
		[regions addObject:GraphRegionMake(rect, color)];
	}
	
	rect = CGRectMake(0, w[1], width, w[2] - w[1]);
	rect = CGRectIntersection(wholeRect, rect);
	if (!CGRectIsEmpty(rect)) {
		color = [EWWeightFormatter backgroundColorForWeight:0.5f*(w[1]+w[2])];
		[regions addObject:GraphRegionMake(rect, color)];
	}
	
	if (w[2] < gp->maxWeight) {
		rect = CGRectMake(0, w[2], width, gp->maxWeight - w[2]);
		rect = CGRectIntersection(wholeRect, rect);
		if (!CGRectIsEmpty(rect)) {
			color = [EWWeightFormatter backgroundColorForWeight:gp->maxWeight];
			[regions addObject:GraphRegionMake(rect, color)];
		}
	}
	
	gp->regions = [regions copy];
}


+ (void)prepareGraphViewInfo:(GraphViewParameters *)gp forSize:(CGSize)size numberOfDays:(NSUInteger)numberOfDays {
	// Assumes minWeight and maxWeight have already been set, but need adjusting
	// Does not set: shouldDrawNoDataWarning
	
	static float minRange = 0;
	if (minRange == 0) {
		switch ([[NSUserDefaults standardUserDefaults] weightUnit]) {
			case EWWeightUnitKilograms:
				minRange = 2 / kKilogramsPerPound;
				break;
			case EWWeightUnitPounds:
			default:
				minRange = 2;
				break;
		}
	}
	if ((gp->maxWeight - gp->minWeight) < minRange) {
		float centerWeight = 0.5f * (gp->minWeight + gp->maxWeight);
		gp->minWeight = centerWeight - (0.5f * minRange);
		gp->maxWeight = centerWeight + (0.5f * minRange);
	}

	if (numberOfDays == 1) {
		gp->scaleX = size.width;
	} else {
		gp->scaleX = (size.width - kGraphMarginRight) / numberOfDays;
	}
	gp->scaleY = (size.height - (kGraphMarginTop + kGraphMarginBottom)) / (gp->maxWeight - gp->minWeight);
	gp->minWeight -= (kGraphMarginBottom / gp->scaleY);
	gp->maxWeight += (kGraphMarginTop / gp->scaleY);
		
	float increment = [[NSUserDefaults standardUserDefaults] weightWholeIncrement];
	float minIncrement = [UIFont systemFontSize] / gp->scaleY;
	while (increment < minIncrement) {
		increment = EWChartWeightIncrementAfterIncrement(increment);
	}
	CGFloat adjustment = ((kBandHeight * 4 + kGraphMarginBottom) / gp->scaleY);
	gp->gridIncrement = increment;
	gp->gridMinWeight = floorf((gp->minWeight + adjustment) / increment) * increment;
	
	CGAffineTransform t = CGAffineTransformMakeTranslation(0, size.height);
	t = CGAffineTransformScale(t, gp->scaleX, -gp->scaleY);
	t = CGAffineTransformTranslate(t, -0.5, -gp->minWeight);
	gp->t = t;
	
	if (!gp->showFatWeight) {
		[self prepareBMIRegionsForGraphViewParameters:gp];
	}
	
	[[EWDatabase sharedDatabase] getEarliestMonthDay:&gp->mdEarliest
									  latestMonthDay:&gp->mdLatest];
}


- (void)computePoints {

	dayCount = 1 + EWDaysBetweenMonthDays(beginMonthDay, endMonthDay);
	
	if (p->mdEarliest == 0 || p->mdLatest == 0) {
		return; // no data, nothing to draw!
	}
	
	EWMonthDay mdStart; // first point to draw
	EWMonthDay mdStop; // last point to draw
	CGFloat x;
	
	EWDatabase *db = [EWDatabase sharedDatabase];
	
	// Is the requested start after actual data starts?
	if (p->mdEarliest < beginMonthDay) {
		// If so, comply with request.
		x = 1;
		mdStart = beginMonthDay;
		// Compute head point, because there is earlier data.
		EWMonthDay mdHead;
		const EWDBDay *dbd = [db getMonthDay:&mdHead withWeightBefore:mdStart onlyFat:p->showFatWeight];
		if (dbd) {
			headPoint.x = x + EWDaysBetweenMonthDays(mdStart, mdHead);
			headPoint.y = (p->showFatWeight ? dbd->trendFatWeight : dbd->trendWeight);
		}
	} else {
		// Otherwise, bump X to compensate.
		mdStart = p->mdEarliest;
		x = 1 + EWDaysBetweenMonthDays(beginMonthDay, mdStart);
		// don't need to compute headPoint because there is no earlier data
	}
	
	if (endMonthDay < p->mdLatest) {
		// If we requested an end before data ends, stop there.
		mdStop = endMonthDay;
		// Compute tail point, because there is later data.
		EWMonthDay mdTail;
		const EWDBDay *dbd = [db getMonthDay:&mdTail withWeightAfter:mdStop onlyFat:p->showFatWeight];
		if (dbd) {
			tailPoint.x = x + EWDaysBetweenMonthDays(mdStart, mdTail);
			tailPoint.y = (p->showFatWeight ? dbd->trendFatWeight : dbd->trendWeight);
		}
	} else {
		mdStop = p->mdLatest;
	}

	pointData = [[NSMutableData alloc] initWithCapacity:31 * sizeof(GraphPoint)];
	flagData = [[NSMutableData alloc] initWithCapacity:32];
	
	EWDBMonth *data = nil;
	for (EWMonthDay md = mdStart; md <= mdStop; md = EWMonthDayNext(md)) {
		EWDay day = EWMonthDayGetDay(md);
		if (data == nil || day == 1) {
			data = [db getDBMonth:EWMonthDayGetMonth(md)];
		}
		const EWDBDay *dd = [data getDBDayOnDay:day];
		if (p->showFatWeight && (dd->scaleFatWeight > 0)) {
			GraphPoint gp;
			gp.scale = CGPointMake(x, dd->scaleFatWeight);
			gp.trend = CGPointMake(x, dd->trendFatWeight);
			[pointData appendBytes:&gp length:sizeof(GraphPoint)];
		} else if (!p->showFatWeight && (dd->scaleWeight > 0)) {
			GraphPoint gp;
			gp.scale = CGPointMake(x, dd->scaleWeight);
			gp.trend = CGPointMake(x, dd->trendWeight);
			[pointData appendBytes:&gp length:sizeof(GraphPoint)];
		}
		unsigned char flagBits = ((dd->flags[0] ? 1 : 0) |
								  (dd->flags[1] ? 2 : 0) |
								  (dd->flags[2] ? 4 : 0) |
								  (dd->flags[3] ? 8 : 0));
		if (flagBits) {
			FlagPoint fp;
			fp.x = x;
			fp.bits = flagBits;
			[flagData appendBytes:&fp length:sizeof(FlagPoint)];
		}
		x += 1;
	}

#if TARGET_IPHONE_SIMULATOR
	NSLog(@"%@\nFrom %@ (%@)\n  To %@ (%@)\nHead %@\nTail %@\nPnts %d",
		  self,
		  EWDateFromMonthDay(mdStart), EWDateFromMonthDay(beginMonthDay),
		  EWDateFromMonthDay(mdStop), EWDateFromMonthDay(endMonthDay),
		  NSStringFromCGPoint(headPoint),
		  NSStringFromCGPoint(tailPoint),
		  [pointData length] / sizeof(GraphPoint));
#endif
	
}


- (CGPathRef)newWeekendsBackgroundPath {
	// If a single day is less than two pixels wide, don't bother.
	if (p->scaleX < 2) return NULL;
	
	// If weekend shading has been disabled, don't do anything.
	if (! [[NSUserDefaults standardUserDefaults] highlightWeekends]) return NULL;

	CGMutablePathRef path = CGPathCreateMutable();
	CGFloat bandWeight = ((kBandHeight * 4) / p->scaleY);
	CGFloat h = p->maxWeight - p->minWeight - bandWeight;
	
	NSUInteger wd = EWWeekdayFromMonthAndDay(EWMonthDayGetMonth(beginMonthDay), 
											 EWMonthDayGetDay(beginMonthDay));

	if (wd == 1) {
		CGPathAddRect(path, &p->t, CGRectMake(0.5, p->minWeight, 1, h));
	}
	
	CGRect dayRect = CGRectMake(7.5 - wd, p->minWeight + bandWeight, 2, h);
	while (dayRect.origin.x < dayCount) {
		CGPathAddRect(path, &p->t, dayRect);
		dayRect.origin.x += 7;
	}
	
	return path;
}


- (CGPathRef)newGridPath {
	CGMutablePathRef gridPath = CGPathCreateMutable();
	const CGFloat bandWeight = ((kBandHeight * 4) / p->scaleY);
	const CGFloat minY = p->minWeight + bandWeight;
	const CGFloat maxY = p->maxWeight;
	
	// vertical lines
	CGFloat x = 0.5;
	EWMonthDay md = beginMonthDay;
	while (md <= endMonthDay) {
		EWMonth month = EWMonthDayGetMonth(md);
		EWDay day = EWMonthDayGetDay(md);
		if (day == 1) {
			CGPathMoveToPoint(gridPath, &p->t, x, minY);
			CGPathAddLineToPoint(gridPath, &p->t, x, maxY);
			x += EWDaysInMonth(month);
		} else {
			x += EWDaysInMonth(month) - day + 1;
		}
		md = EWMonthDayMake(month + 1, 1);
	}
	
	// horizontal lines:
	const CGFloat xMax = (CGRectGetWidth(bounds) / p->scaleX) + 0.5;
	for (float w = p->gridMinWeight; w < p->maxWeight; w += p->gridIncrement) {
		CGPathMoveToPoint(gridPath, &p->t, -0.5, w);
		CGPathAddLineToPoint(gridPath, &p->t, xMax, w);
	}
	return gridPath;
}


- (void)drawNoDataWarningInContext:(CGContextRef)ctxt {
	const CGFloat fontSize = 30;
	
	CGContextSetGrayFillColor(ctxt, 0.3, 1);
	CGContextSetTextMatrix(ctxt, CGAffineTransformMakeScale(1.0, -1.0));
	CGContextSelectFont(ctxt, "Helvetica-Bold", fontSize, kCGEncodingMacRoman);
	
	NSString *warningString = NSLocalizedString(@"no weight to display", @"Empty chart message");
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


- (CGPathRef)newTrendPath {
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
		
		for (int k = 1; k < gpCount; k++) {
			CGPathAddLineToPoint(path, &p->t, gp[k].trend.x, gp[k].trend.y);
		}

		if (tailPoint.y > 0) {
			CGPathAddLineToPoint(path, &p->t, tailPoint.x, tailPoint.y);
		}
	} else {
		if (headPoint.y > 0 && tailPoint.y > 0) {
			CGPathMoveToPoint(path, &p->t, headPoint.x, headPoint.y);
			CGPathAddLineToPoint(path, &p->t, tailPoint.x, tailPoint.y);
		}
	}
	
	return path;
}


- (CGPathRef)newMarksPath {
	CGMutablePathRef path = CGPathCreateMutable();
	
	const CGFloat markRadius = 0.5 * MIN(kDayWidth, p->scaleX);
	
	NSUInteger gpCount = [pointData length] / sizeof(GraphPoint);
	if (gpCount > 0) {
		const GraphPoint *gp = [pointData bytes];
		for (int k = 0; k < gpCount; k++) {
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
	
	return path;
}


- (CGPathRef)newErrorLinesPath {
	CGMutablePathRef path = CGPathCreateMutable();
	
	const CGFloat markRadius = 0; //0.45 * p->scaleX;
	
	NSUInteger gpCount = [pointData length] / sizeof(GraphPoint);
	if (gpCount > 0) {
		const GraphPoint *gp = [pointData bytes];
		for (int k = 0; k < gpCount; k++) {
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


- (CGPathRef)newGoalPath {
	// we need at least one graph point
	if ([pointData length] < sizeof(GraphPoint)) return NULL;
	
	EWGoal *goal = [EWGoal sharedGoal];
	if (! goal.defined) return NULL;

	float goalWeight = goal.endWeight;
	
	const GraphPoint *lastGP = [pointData bytes] + [pointData length] - sizeof(GraphPoint);

	if (p->showFatWeight) {
		float currentNonFatWeight = goal.currentWeight - lastGP->scale.y;
		goalWeight -= currentNonFatWeight;
	}
	
	const CGFloat m = [goal weightChangePerDay];	
	const CGFloat x = lastGP->trend.x + fabsf((lastGP->trend.y - goalWeight) / m);

	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, &p->t, lastGP->trend.x, lastGP->trend.y);
	CGPathAddLineToPoint(path, &p->t, x, goalWeight);
	const CGFloat xMax = (CGRectGetWidth(bounds) / p->scaleX) + 0.5;
	if (x < xMax) {
		CGPathAddLineToPoint(path, &p->t, xMax, goalWeight);
	}		
	return path;
}


- (CGPathRef)newTrajectoryPath {
	NSUInteger gpCount = [pointData length] / sizeof(GraphPoint);
	if (gpCount == 0) return NULL;
	
	SlopeComputer *sc = [[SlopeComputer alloc] init];
	
	const GraphPoint *gp = [pointData bytes];
	for (int k = 0; k < gpCount; k++) {
		[sc addPoint:gp[k].trend];
	}

	const GraphPoint *lastGP = &gp[gpCount-1];
	const CGFloat xMax = (CGRectGetWidth(bounds) / p->scaleX) + 0.5;
	const CGFloat y = lastGP->trend.y + sc.slope * (xMax - lastGP->trend.x);
	
	[sc release];
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, &p->t, lastGP->trend.x, lastGP->trend.y);
	CGPathAddLineToPoint(path, &p->t, xMax, y);
	
	return path;
}


- (void)drawFlagBandsInContext:(CGContextRef)ctxt {
	const NSUInteger fpCount = [flagData length] / sizeof(FlagPoint);
	const FlagPoint *fp = [flagData bytes];
	for (int f = 0; f < 4; f++) {
		unsigned char mask = (1 << f);
		CGMutablePathRef flagPath = CGPathCreateMutable();
		CGRect rect = CGRectMake(0, CGRectGetMaxY(bounds) - (kBandHeight*(4-f)), p->scaleX, kBandHeight);
		for (int k = 0; k < fpCount; k++) {
			if (fp[k].bits & mask) {
				rect.origin.x = ((fp[k].x - 1) * p->scaleX);
				CGPathAddRect(flagPath, NULL, rect);
			}
		}
		rect.origin.x = 0;
		rect.size.width = CGRectGetWidth(bounds);
		
		NSString *colorName = [NSString stringWithFormat:@"Flag%d", f];
		UIColor *color = [BRColorPalette colorNamed:colorName];
		
		CGContextSetFillColorWithColor(ctxt, [[color colorWithAlphaComponent:0.3] CGColor]);
		CGContextFillRect(ctxt, rect);
		
		CGContextSetFillColorWithColor(ctxt, [color CGColor]);
		CGContextAddPath(ctxt, flagPath);
		CGContextFillPath(ctxt);
		
		CGPathRelease(flagPath);
	}
	CGFloat y = CGRectGetMaxY(bounds) - (kBandHeight * 4) - 0.5;
	CGContextMoveToPoint(ctxt, 0, y);
	CGContextAddLineToPoint(ctxt, CGRectGetWidth(bounds), y);
	CGContextSetLineWidth(ctxt, 1);
	CGContextSetRGBStrokeColor(ctxt, 0.3, 0.3, 0.3, 1);
	CGContextStrokePath(ctxt);
}


- (CGContextRef)newBitmapContext {
	static const size_t bitsPerComponent = 8;
	static const size_t bytesPerPixel = 4;
	const size_t pixelsWide = CGRectGetWidth(bounds);
	const size_t pixelsHigh = CGRectGetHeight(bounds);
	const size_t bitmapBytesPerRow   = (pixelsWide * bytesPerPixel);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctxt = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, bitsPerComponent, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
	CGColorSpaceRelease(colorSpace);
	
	CGContextTranslateCTM(ctxt, 0, pixelsHigh);
	CGContextScaleCTM(ctxt, 1, -1);
	
	return ctxt;
}


- (void)main {
	[self computePoints];
	
	CGContextRef ctxt = [self newBitmapContext];
	NSAssert(ctxt, @"could not create bitmap context");

	// shaded background to show weekends
	
	CGPathRef weekendsBackgroundPath = [self newWeekendsBackgroundPath];
	if (weekendsBackgroundPath) {
		CGContextAddPath(ctxt, weekendsBackgroundPath);
		CGContextSetRGBFillColor(ctxt, 0.9,0.9,0.9, 1.0);
		CGContextFillPath(ctxt);
		CGPathRelease(weekendsBackgroundPath);
	}
	
	// vertical grid line to indicate start of month
	// horizontal grid lines at weight intervals
	
	CGPathRef gridPath = [self newGridPath];
	CGContextAddPath(ctxt, gridPath);
	CGContextSetRGBStrokeColor(ctxt, 0.8,0.8,0.8, 1.0);
	CGContextStrokePath(ctxt);
	CGPathRelease(gridPath);

	// shade based on BMI
	
	if ([p->regions count] > 0) {
		static const CGFloat clearColorComponents[] = { 0, 0, 0, 0 };
		static const CGFloat gradientLocations[] = { 0, 1 };

		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CFMutableArrayRef colorArray = CFArrayCreateMutable(kCFAllocatorDefault, 2, &kCFTypeArrayCallBacks);
		CGColorRef clearColor = CGColorCreate(colorSpace, clearColorComponents);
		CFArraySetValueAtIndex(colorArray, 0, clearColor);
		CGColorRelease(clearColor);
		
		for (NSArray *region in p->regions) {
			CGRect rect = GraphRegionGetRect(region);
			UIColor *color = GraphRegionGetColor(region);
			
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

	const CGFloat kZoomScale = MIN(p->scaleX / kDayWidth, 1.0f);
	const CGFloat kTrendLineWidth = MAX(2.0f, 3.0f * kZoomScale);
	const CGFloat kMarkLineWidth = MAX(1.0f, 1.5f * kZoomScale);
	const CGFloat kErrorLineWidth = MAX(0.5f, 2.0f * kZoomScale);
	
	if (p->shouldDrawNoDataWarning && [pointData length] == 0) {
		[self drawNoDataWarningInContext:ctxt];
	} else {
		CGContextSaveGState(ctxt);
		
		BOOL drawMarks = (p->scaleX > 3) && ([pointData length] > 0);
		
		if (drawMarks) {
			CGContextSetRGBStrokeColor(ctxt, 0.5,0.5,0.5, 1.0);
			CGContextSetLineWidth(ctxt, kErrorLineWidth);
			CGPathRef errorLinesPath = [self newErrorLinesPath];
			CGContextAddPath(ctxt, errorLinesPath);
			CGContextStrokePath(ctxt);
			CGPathRelease(errorLinesPath);
		}

		// trend line
		if (p->showFatWeight) {
			CGContextSetRGBStrokeColor(ctxt, 0.1,0.1,0.8, 1.0);
		} else {
			CGContextSetRGBStrokeColor(ctxt, 0.8,0.1,0.1, 1.0);
		}
		CGContextSetLineWidth(ctxt, kTrendLineWidth);
		CGPathRef trendPath = [self newTrendPath];
		CGContextAddPath(ctxt, trendPath);
		CGContextStrokePath(ctxt);
		CGPathRelease(trendPath);
		
		static const CGFloat kDashLengths[] = { 6, 3 };
		static const int kDashLengthsCount = 2;
		CGContextSetLineDash(ctxt, 6, kDashLengths, kDashLengthsCount);
		if (showTrajectoryLine) {
			CGPathRef trajPath = [self newTrajectoryPath];
			if (trajPath) {
				CGContextAddPath(ctxt, trajPath);
				CGContextStrokePath(ctxt);
				CGPathRelease(trajPath);
			}
		}
		if (showGoalLine) {
			CGPathRef goalPath = [self newGoalPath];
			if (goalPath) {
				CGContextSetRGBStrokeColor(ctxt, 0.0, 0.6, 0.0, 0.8);
				CGContextAddPath(ctxt, goalPath);
				CGContextStrokePath(ctxt);
				CGPathRelease(goalPath);
			}
		}
		CGContextSetLineDash(ctxt, 0, NULL, 0);
		
		if (drawMarks) {
			CGContextSetLineWidth(ctxt, kMarkLineWidth);
			CGContextSetRGBStrokeColor(ctxt, 0, 0, 0, 1.0);
			CGContextSetRGBFillColor(ctxt, 1.0, 1.0, 1.0, 1.0);
			CGPathRef marksPath = [self newMarksPath];
			CGContextAddPath(ctxt, marksPath);
			CGContextDrawPath(ctxt, kCGPathFillStroke);
			CGPathRelease(marksPath);
		}
		
		CGContextRestoreGState(ctxt);
	}
	
	[self drawFlagBandsInContext:ctxt];
		
    imageRef = CGBitmapContextCreateImage(ctxt);

    CGContextRelease(ctxt);

	BugFixRetainImageDataProvider(imageRef);

#if TARGET_IPHONE_SIMULATOR
	// Simulate iPhone's slow drawing
	[NSThread sleepForTimeInterval:0.5];
#endif
	
	[delegate performSelectorOnMainThread:@selector(drawingOperationComplete:) 
							   withObject:self
							waitUntilDone:NO];
}


#pragma mark Cleanup


- (void)dealloc {
	CGImageRelease(imageRef);
	[pointData release];
	[flagData release];
	[super dealloc];
}


@end
