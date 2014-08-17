//
//  SlopeComputer.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/18/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SlopeComputer : NSObject
- (void)addPoint:(CGPoint)point;
@property (nonatomic,readonly) NSUInteger count;
@property (nonatomic,readonly) float slope;
@end
