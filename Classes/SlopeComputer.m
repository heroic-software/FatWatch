//
//  SlopeComputer.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/18/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "SlopeComputer.h"


@implementation SlopeComputer

- (void)addPointAtX:(float)x y:(float)y
{
	sumX += x;
	sumY += y;
	sumXsquared += x * x;
	sumXY += x * y;
	count++;
}

- (float)computeSlope
{
	double Sxx = sumXsquared - sumX * sumX / count;
	double Sxy = sumXY - sumX * sumY / count;
	return Sxy / Sxx;
}

@end
