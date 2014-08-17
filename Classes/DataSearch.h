//
//  NSDataSearching.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/15/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DataSearch : NSObject
- (id)initWithData:(NSData *)haystackData patternData:(NSData *)needleData;
- (NSUInteger)nextIndex;
@end
