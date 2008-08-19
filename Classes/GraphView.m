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

@implementation GraphView

- (id)initWithMonth:(EWMonth)m {
    if (self = [super initWithFrame:CGRectZero]) {
		NSLog(@"new graph view for month %d", m);
        month = m;
		self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)setMonth:(EWMonth)m {
	NSLog(@"recycled graph view for month %d", m);
	month = m;
	[self setNeedsDisplay];
}


- (void)drawDate {
	// month and year label at the top
	NSDate *date = EWDateFromMonthAndDay(month, 1);
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.formatterBehavior = NSDateFormatterBehavior10_4;
	formatter.dateFormat = NSLocalizedString(@"MONTH_YEAR_DATE_FORMAT", nil);
	[[UIColor blackColor] setFill];
	[[formatter stringFromDate:date] drawAtPoint:CGPointMake(4, 2) withFont:[UIFont systemFontOfSize:20]];
	[formatter release];
}


- (void)drawRect:(CGRect)rect {
	CGRect bounds = self.bounds;
	
	CGContextRef ctxt = UIGraphicsGetCurrentContext();
	
	Database *database = [Database sharedDatabase];
	const float minWeight = [database minimumWeight] - 10.0f;
	const float maxWeight = [database maximumWeight] + 10.0f;
	const float scaleX = (CGRectGetWidth(bounds) / EWDaysInMonth(month));
	const float scaleY = (CGRectGetHeight(bounds) / (maxWeight - minWeight));

	EWDay day;
	NSUInteger dayCount = EWDaysInMonth(month);

	// draw shaded bars to show weekends
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HighlightWeekends"]) {
		for (day = 1; day <= dayCount; day++) {
			if (EWMonthAndDayIsWeekend(month, day)) {
				CGRect dayRect = CGRectMake((day - 1) * scaleX, 0, scaleX, CGRectGetHeight(bounds));
				CGContextSetGrayFillColor(ctxt, 0.9, 1.0);
				CGContextFillRect(ctxt, dayRect);
			}
		}
	}
	
	// gray vertical line at the start of the month
	CGContextMoveToPoint(ctxt, 0, CGRectGetMinY(bounds));
	CGContextAddLineToPoint(ctxt, 0, CGRectGetMaxY(bounds));
	CGContextSetGrayFillColor(ctxt, 0.7, 1.0);
	CGContextStrokePath(ctxt);
	
	[self drawDate];

	// 33 = 31 days + 1 day last month + 1 day next month
	CGPoint measuredPoints[33];
	CGPoint trendPoints[33];
	BOOL flags[33];
	NSUInteger pointCount = 0;
	
	BOOL hasHead = NO;
	BOOL hasTail = NO;
	
	MonthData *md;
	
	if (month > [database earliestMonth]) {
		md = [database dataForMonth:(month - 1)];
		day = [md lastDayWithWeight];
		if (day > 0) {
			float trend = [md trendWeightOnDay:day];
			float x = (day - 0.5 - EWDaysInMonth(month - 1)) * scaleX;
			float ty = (trend - minWeight) * scaleY;
			trendPoints[pointCount] = CGPointMake(x, ty);
			pointCount++;
			hasHead = YES;
		}
	}
	
	md = [database dataForMonth:month];
	for (day = 1; day <= dayCount; day++) {
		float measured = [md measuredWeightOnDay:day];
		if (measured > 0) {
			float trend = [md trendWeightOnDay:day];
			float x = (day - 0.5) * scaleX;
			float my = (measured - minWeight) * scaleY;
			float ty = (trend - minWeight) * scaleY;
			
			measuredPoints[pointCount] = CGPointMake(x, my);
			trendPoints[pointCount] = CGPointMake(x, ty);
			flags[pointCount] = [md isFlaggedOnDay:day];
			pointCount++;
		}
	}
	
	if (month < [database latestMonth]) {
		md = [database dataForMonth:(month + 1)];
		day = [md firstDayWithWeight];
		if (day > 0) {
			float trend = [md trendWeightOnDay:day];
			float x = (dayCount + day - 0.5) * scaleX;
			float ty = (trend - minWeight) * scaleY;
			trendPoints[pointCount] = CGPointMake(x, ty);
			pointCount++;
			hasTail = YES;
		}
	}
	
	// flip coordinate system so that origin is on the bottom left
	CGContextTranslateCTM(ctxt, 0, CGRectGetHeight(bounds));
	CGContextScaleCTM(ctxt, 1.0, -1.0);
	CGContextSetRGBStrokeColor(ctxt, 0, 0, 0, 1);

	// draw trend line
	CGContextSetLineWidth(ctxt, 3.0f);
	CGContextBeginPath(ctxt);
	CGContextAddLines(ctxt, trendPoints, pointCount);
	CGContextDrawPath(ctxt, kCGPathStroke);
	
	// draw floaters/sinkers
	CGContextSetLineWidth(ctxt, 1);
	int i;
	int start = hasHead ? 1 : 0;
	int count = hasTail ? pointCount - 1 : pointCount;
	for (i = start; i < count; i++) {
		// draw line from trend line to scale weight
		CGContextBeginPath(ctxt);
		CGContextMoveToPoint(ctxt, measuredPoints[i].x, measuredPoints[i].y);
		CGContextAddLineToPoint(ctxt, trendPoints[i].x, trendPoints[i].y);
		CGContextDrawPath(ctxt, kCGPathStroke);

		// draw circle at scale weight, colored if date is checked
		CGRect balloonRect = CGRectMake(measuredPoints[i].x - 2.5, measuredPoints[i].y - 2.5, 5, 5);
		if (flags[i]) {
			CGContextSetRGBFillColor(ctxt, 1, 1, 0, 1.0);
		} else {
			CGContextSetGrayFillColor(ctxt, 1, 1.0);
		}
		CGContextBeginPath(ctxt);
		CGContextAddEllipseInRect(ctxt, balloonRect);
		CGContextDrawPath(ctxt, kCGPathFillStroke);
	}
}


- (void)dealloc {
	[super dealloc];
}

@end
