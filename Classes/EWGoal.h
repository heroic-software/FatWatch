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


@interface EWGoal : NSObject {

}

+ (void)deleteGoal;
+ (EWGoal *)sharedGoal;

@property (readonly,getter=isDefined) BOOL defined;
@property (readonly,getter=isAttained) BOOL attained;

@property (readonly) float currentWeight;

@property (retain) NSDate *endDate;
@property float endWeight;
@property (retain) NSNumber *endWeightNumber;

@property float weightChangePerDay;

- (NSDate *)endDateWithWeightChangePerDay:(float)weightChangePerDay;

@end
