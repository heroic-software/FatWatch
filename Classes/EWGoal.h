//
//  EWGoal.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 8/19/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWDate.h"


extern NSString * const EWGoalDidChangeNotification;
extern float gGoalBandHeight;
extern float gGoalBandHalfHeight;


typedef enum {
	EWGoalStateUndefined,
	EWGoalStateFixedDate,
	EWGoalStateFixedRate,
	EWGoalStateInvalid = -1
} EWGoalState;


@class EWDatabase;


@interface EWGoal : NSObject

+ (void)deleteGoal;

@property (readonly) EWGoalState state;
@property (readonly,getter=isDefined) BOOL defined;

@property (readonly) float currentWeight;

@property float endWeight;
@property (strong) NSNumber *endWeightNumber;

@property (strong) NSDate *endDate;
@property float weightChangePerDay;

- (id)initWithDatabase:(EWDatabase *)db;
- (NSDate *)endDateWithWeightChangePerDay:(float)weightChangePerDay;

@end
