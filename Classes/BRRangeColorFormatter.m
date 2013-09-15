//
//  BRRangeColorFormatter.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/10/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRRangeColorFormatter.h"


@implementation BRRangeColorFormatter

- (id)initWithColors:(NSArray *)colorArray forValues:(float *)valueArray {
	if ([super init]) {
		colors = [colorArray copy];
		size_t size = ([colors count] - 1) * sizeof(float);
		values = malloc(size);
		bcopy(valueArray, values, size);
	}
	return self;
}

- (UIColor *)colorForObjectValue:(id)anObject {
	float v = [anObject floatValue];
	
	int n = [colors count] - 1;
	for (int i = 0; i < n; i++) {
		if (v < values[i]) return colors[i];
	}
	
	return [colors lastObject];
}

@end
