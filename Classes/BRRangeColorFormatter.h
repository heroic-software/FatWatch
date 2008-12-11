//
//  BRRangeColorFormatter.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/10/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRTableValueRow.h"

@interface BRRangeColorFormatter : NSObject <BRColorFormatter> {
	float *values;
	NSArray *colors;
}
- (id)initWithColors:(NSArray *)colorArray forValues:(float *)valueArray;
@end
