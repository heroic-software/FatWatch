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


@interface EWGoal : NSObject {

}

+ (void)deleteGoal;
+ (EWGoal *)sharedGoal;

@property (readonly) EWGoalState state;
@property (readonly,getter=isDefined) BOOL defined;
@property (readonly,getter=isAttained) BOOL attained;

@property (readonly) float currentWeight;

@property float endWeight;
@property (retain) NSNumber *endWeightNumber;

@property (retain) NSDate *endDate;
@property float weightChangePerDay;

- (NSDate *)endDateWithWeightChangePerDay:(float)weightChangePerDay;

@end
