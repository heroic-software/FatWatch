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

- (id)initWithDatabase:(Database *)db month:(EWMonth)m {
    if (self = [super initWithFrame:CGRectZero]) {
		database = db;
        month = m;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGRect bounds = self.bounds;
	
	CGContextRef ctxt = UIGraphicsGetCurrentContext();

	// flip coordinate system
	CGContextTranslateCTM(ctxt, 0, self.bounds.size.height);
	CGContextScaleCTM(ctxt, 1.0, -1.0);
	
	CGFloat gray = (month % 2) ? 0.6f : 0.5f;
	CGContextSetRGBFillColor(ctxt, gray, gray, gray, 1.0f);
	CGContextFillRect(ctxt, bounds);

	NSDate *date = NSDateFromEWMonthAndDay(month, 1);
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.formatterBehavior = NSDateFormatterBehavior10_4;
	formatter.dateFormat = @"MMMM yyyy";
	const char *text = [[formatter stringFromDate:date] UTF8String];
	[formatter release];
	
	CGContextSelectFont(ctxt, "Helvetica", 20, kCGEncodingMacRoman);
	CGContextSetRGBFillColor(ctxt, 0, 0, 0, 1.0f);
	CGContextShowTextAtPoint(ctxt, 4, 4, text, strlen(text));
	
	CGPoint measuredPoints[31];
	CGPoint trendPoints[31];
	BOOL flags[31];
	NSUInteger pointCount = 0;
	
	float minWeight = [database minimumWeight] - 10.0f;
	float maxWeight = [database maximumWeight] + 10.0f;
	
	// if we change the transformation matrix, we screw up line thickness
	float scaleX = (bounds.size.width / EWDaysInMonth(month));
	float scaleY = (bounds.size.height / (maxWeight - minWeight));

	MonthData *md = [database dataForMonth:month];
	EWDay day;
	NSUInteger dayCount = EWDaysInMonth(month);
	for (day = 1; day <= dayCount; day++) {
		float measured = [md measuredWeightOnDay:day];
		if (measured > 0) {
			float trend = [md trendWeightOnDay:day];
			float x = (day - 1) * scaleX;
			float my = (measured - minWeight) * scaleY;
			float ty = (trend - minWeight) * scaleY;
			
			measuredPoints[pointCount] = CGPointMake(x, my);
			trendPoints[pointCount] = CGPointMake(x, ty);
			flags[pointCount] = [md isFlaggedOnDay:day];
			pointCount++;
		}
	}
	
	CGContextSetLineWidth(ctxt, 1.0f);

	int i;
	for (i = 0; i < pointCount; i++) {
		CGContextBeginPath(ctxt);
		CGContextMoveToPoint(ctxt, measuredPoints[i].x, measuredPoints[i].y);
		CGContextAddLineToPoint(ctxt, trendPoints[i].x, trendPoints[i].y);
		CGContextSetRGBStrokeColor(ctxt, 1, 1, flags[i] ? 0 : 1, 1);
		CGContextDrawPath(ctxt, kCGPathStroke);
	}

	CGContextBeginPath(ctxt);
	CGContextAddLines(ctxt, trendPoints, pointCount);
	CGContextSetRGBStrokeColor(ctxt, 0, 0, 0, 1);
	CGContextDrawPath(ctxt, kCGPathStroke);
}

- (void)dealloc
{
	[super dealloc];
}

@end
