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
	[super drawRect:rect];
	const char *text = [[NSString stringWithFormat:@"%d", month] UTF8String];
	
	CGRect bounds = self.bounds;
	
	CGContextRef ctxt = UIGraphicsGetCurrentContext();

	CGContextSelectFont(ctxt, "Helvetica", 36, kCGEncodingMacRoman);
	CGContextSetRGBStrokeColor(ctxt, 0, 0, 0, 1);
	CGContextMoveToPoint(ctxt, bounds.origin.x, bounds.origin.y);
	CGContextShowText(ctxt, text, strlen(text));
	
	CGPoint measuredPoints[31];
	CGPoint trendPoints[31];
	NSUInteger pointCount = 0;
	
	MonthData *md = [database dataForMonth:month];
	EWDay day;
	NSUInteger dayCount = EWDaysInMonth(month);
	for (day = 1; day <= dayCount; day++) {
		float measured = [md measuredWeightOnDay:day];
		if (measured > 0) {
			float trend = [md trendWeightOnDay:day];
			float x = day * (bounds.size.width / 31);
			measuredPoints[pointCount] = CGPointMake(x, measured);
			trendPoints[pointCount] = CGPointMake(x, trend);
			pointCount++;
		}
	}
	
	CGContextBeginPath(ctxt);
	CGContextAddLines(ctxt, measuredPoints, pointCount);
	CGContextSetLineWidth(ctxt, 1);
	CGContextSetRGBStrokeColor(ctxt, 1, 1, 1, 1);
	CGContextDrawPath(ctxt, kCGPathStroke);

	CGContextBeginPath(ctxt);
	CGContextAddLines(ctxt, trendPoints, pointCount);
	CGContextSetLineWidth(ctxt, 3);
	CGContextSetRGBStrokeColor(ctxt, 0, 0, 0, 1);
	CGContextDrawPath(ctxt, kCGPathStroke);
}

- (void)dealloc
{
	[super dealloc];
}

@end
