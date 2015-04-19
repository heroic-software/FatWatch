/*
 * GraphDrawingOperation.h
 * Created by Benjamin Ragheb on 9/4/08.
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


@interface GraphDrawingOperation : NSOperation
+ (void)prepareGraphViewInfo:(GraphViewParameters *)gp forSize:(CGSize)size numberOfDays:(NSUInteger)numberOfDays database:(EWDatabase *)db;
@property (nonatomic,strong) EWDatabase *database;
@property (nonatomic) EWMonthDay beginMonthDay;
@property (nonatomic) EWMonthDay endMonthDay;
@property (nonatomic,weak) id delegate;
@property (nonatomic) NSUInteger index;
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
