//
//  GraphDrawingOperation.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 9/4/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWDate.h"


@class EWDatabase;


@interface GraphViewParameters : NSObject
@property (nonatomic) float minWeight;
@property (nonatomic) float maxWeight;
@property (nonatomic) float scaleX;
@property (nonatomic) float scaleY;
@property (nonatomic) float gridMinWeight;
@property (nonatomic) float gridIncrement;
@property (nonatomic) CGAffineTransform t;
@property (nonatomic, strong) NSArray *regions;
@property (nonatomic) EWMonthDay mdEarliest;
@property (nonatomic) EWMonthDay mdLatest;
@property (nonatomic) BOOL shouldDrawNoDataWarning;
@property (nonatomic) BOOL showFatWeight;
@end


typedef struct {
	CGPoint scale;
	CGPoint trend;
} GraphPoint;


typedef struct {
	CGFloat x;
	unsigned char bits;
} FlagPoint;


#define kDayWidth 8.0f


@interface GraphDrawingOperation : NSOperation {
	id delegate;
	unsigned int index;
	EWDatabase *database;
	EWMonthDay beginMonthDay;
	EWMonthDay endMonthDay;
	GraphViewParameters *p;
	CGRect bounds;
	CGFloat scale;
	CGImageRef imageRef;
	NSMutableData *pointData;
	NSMutableData *flagData;
	NSUInteger dayCount;
	CGPoint headPoint;
	CGPoint tailPoint;
	BOOL showGoalLine;
	BOOL showTrajectoryLine;
	BOOL showFatWeight;
}
+ (void)prepareGraphViewInfo:(GraphViewParameters *)gp forSize:(CGSize)size numberOfDays:(NSUInteger)numberOfDays database:(EWDatabase *)db;
@property (nonatomic,retain) EWDatabase *database;
@property (nonatomic) EWMonthDay beginMonthDay;
@property (nonatomic) EWMonthDay endMonthDay;
@property (nonatomic,assign) id delegate;
@property (nonatomic) unsigned int index;
@property (nonatomic,strong) GraphViewParameters *p;
@property (nonatomic) CGRect bounds;
@property (nonatomic) BOOL showGoalLine;
@property (nonatomic) BOOL showTrajectoryLine;
@property (nonatomic,readonly) CGImageRef imageRef;
+ (void)flushQueue;
- (void)enqueue;
@end


@interface NSObject (GraphDrawingOperationDelegate)
- (void)drawingOperationComplete:(GraphDrawingOperation *)operation;
@end
