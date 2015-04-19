/*
 * BRRangeColorFormatter.m
 * Created by Benjamin Ragheb on 12/10/08.
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

#import "BRRangeColorFormatter.h"


@implementation BRRangeColorFormatter
{
	float *values;
	NSArray *colors;
}

- (id)initWithColors:(NSArray *)colorArray forValues:(float *)valueArray {
	if ((self = [super init])) {
		colors = [colorArray copy];
		size_t size = ([colors count] - 1) * sizeof(float);
		values = malloc(size);
		bcopy(valueArray, values, size);
	}
	return self;
}

- (UIColor *)colorForObjectValue:(id)anObject {
	float v = [anObject floatValue];
	
	NSInteger n = [colors count] - 1;
	for (int i = 0; i < n; i++) {
		if (v < values[i]) return colors[i];
	}
	
	return [colors lastObject];
}

@end
