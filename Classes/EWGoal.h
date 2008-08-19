//
//  EWGoal.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 8/19/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWDate.h"


@interface EWGoal : NSObject {

}
+ (void)deleteGoal;
+ (EWGoal *)sharedGoal;
@property (nonatomic,retain) NSDate *startDate;
@property (nonatomic) float endWeight;
@property (nonatomic) float weightChangePerDay;

@property (nonatomic,readonly,getter=isDefined) BOOL defined;

@property (nonatomic,readonly) EWMonthDay startMonthDay;
@property (nonatomic,readonly) float startWeight;
@property (nonatomic,readonly) NSDate *endDate;
@end
