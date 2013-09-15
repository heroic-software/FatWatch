//
//  GraphSegment.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 9/15/13.
//
//

#import <Foundation/Foundation.h>

#import "EWDate.h"

@class GraphView;
@class GraphDrawingOperation;

@interface GraphSegment : NSObject
@property (nonatomic) EWMonthDay beginMonthDay;
@property (nonatomic) EWMonthDay endMonthDay;
@property (nonatomic) CGFloat offsetX;
@property (nonatomic) CGFloat width;
@property (nonatomic, strong) GraphView *view;
@property (nonatomic) CGImageRef imageRef;
@property (nonatomic, strong) GraphDrawingOperation *operation;
@end
