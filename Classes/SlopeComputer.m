//
//  SlopeComputer.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/18/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "SlopeComputer.h"


@implementation SlopeComputer
{
	double sumX, sumY, sumXsquared, sumXY;
	NSUInteger count;
}

@synthesize count;


- (void)addPoint:(CGPoint)point
{
	sumX += point.x;
	sumY += point.y;
	sumXsquared += point.x * point.x;
	sumXY += point.x * point.y;
	count++;
}


- (float)slope
{
	double Sxx = sumXsquared - sumX * sumX / count;
	double Sxy = sumXY - sumX * sumY / count;
	return (float)(Sxy / Sxx);
}


@end
