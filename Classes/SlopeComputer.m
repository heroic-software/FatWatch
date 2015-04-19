/*
 * SlopeComputer.m
 * Created by Benjamin Ragheb on 4/18/08.
 * Copyright 2015 Heroic Software Inc
 *
 * This file is part of FatWatch.
 *
 * FatWatch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FatWatch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
 */

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
