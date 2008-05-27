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
        month = m;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	CGRect bounds = self.bounds;
	
	CGContextRef ctxt = UIGraphicsGetCurrentContext();

	// white background
	CGContextSetGrayFillColor(ctxt, 1.0, 1.0);
	CGContextFillRect(ctxt, bounds);
	
	// gray vertical line at the start of the month
	CGContextMoveToPoint(ctxt, 0, CGRectGetMinY(bounds));
	CGContextAddLineToPoint(ctxt, 0, CGRectGetMaxY(bounds));
	CGContextSetGrayFillColor(ctxt, 0.8, 1.0);
	CGContextStrokePath(ctxt);

	// month and year label at the top
	NSDate *date = EWDateFromMonthAndDay(month, 1);
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.formatterBehavior = NSDateFormatterBehavior10_4;
	formatter.dateFormat = NSLocalizedString(@"MONTH_YEAR_DATE_FORMAT", nil);
	[[UIColor blackColor] setFill];
	[[formatter stringFromDate:date] drawAtPoint:CGPointMake(4, 2)
										withFont:[UIFont systemFontOfSize:20]];
	//const char *text = [[formatter stringFromDate:date] UTF8String];
	[formatter release];
	
	// flip coordinate system so that origin is on the bottom left
	CGContextTranslateCTM(ctxt, 0, CGRectGetHeight(bounds));
	CGContextScaleCTM(ctxt, 1.0, -1.0);
	
	CGPoint measuredPoints[31];
	CGPoint trendPoints[31];
	BOOL flags[31];
	NSUInteger pointCount = 0;
	
	Database *database = [Database sharedDatabase];
	float minWeight = [database minimumWeight] - 10.0f;
	float maxWeight = [database maximumWeight] + 10.0f;
	
	// if we change the transformation matrix, we screw up line thickness
	float scaleX = (CGRectGetWidth(bounds) / EWDaysInMonth(month));
	float scaleY = (CGRectGetHeight(bounds) / (maxWeight - minWeight));

	MonthData *md = [database dataForMonth:month];
	EWDay day;
	NSUInteger dayCount = EWDaysInMonth(month);
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
	
	CGContextSetRGBStrokeColor(ctxt, 0, 0, 0, 1);

	CGContextSetLineWidth(ctxt, 3.0f);
	
	CGContextBeginPath(ctxt);
	CGContextAddLines(ctxt, trendPoints, pointCount);
	CGContextSetRGBStrokeColor(ctxt, 0, 0, 0, 1);
	CGContextDrawPath(ctxt, kCGPathStroke);
	
	CGContextSetLineWidth(ctxt, 1);
	int i;
	for (i = 0; i < pointCount; i++) {
		CGRect balloonRect = CGRectMake(measuredPoints[i].x - 2.5, measuredPoints[i].y - 2.5, 5, 5);

		CGContextBeginPath(ctxt);
		CGContextMoveToPoint(ctxt, measuredPoints[i].x, measuredPoints[i].y);
		CGContextAddLineToPoint(ctxt, trendPoints[i].x, trendPoints[i].y);
		CGContextDrawPath(ctxt, kCGPathStroke);

		CGContextSetRGBFillColor(ctxt, 1, 1, flags[i] ? 0 : 1, 1);
		CGContextFillEllipseInRect(ctxt, balloonRect);
		CGContextStrokeEllipseInRect(ctxt, balloonRect);
	}
}


- (void)dealloc {
	[super dealloc];
}

@end
