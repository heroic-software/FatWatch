//
//  EWGoal.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 8/19/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWDate.h"


#define SecondsPerDay 86400


@interface EWGoal : NSObject {

}

+ (void)deleteGoal;
+ (EWGoal *)sharedGoal;

@property (retain) NSDate *startDate;
@property (readonly) EWMonthDay startMonthDay;
@property (readonly,getter=isDefined) BOOL defined;
@property (readonly,getter=isAttained) BOOL attained;
@property (readonly) float startWeight;

@property (retain) NSDate *endDate;
@property float endWeight;
@property (retain) NSNumber *endWeightNumber;

@property float weightChangePerDay;

- (float)weightOnDate:(NSDate *)date;
- (NSDate *)endDateFromStartDate:(NSDate *)date atWeightChangePerDay:(float)weightChangePerDay;

@end
