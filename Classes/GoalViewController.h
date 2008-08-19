//
//  GoalViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTableViewController.h"
#import "EWDate.h"


@interface GoalViewController : BRTableViewController {
	EWMonthDay startMonthDay;
	float startWeight;
	EWMonthDay endMonthDay;
	float goalWeight;
	float weightChangePerDay;
	BOOL isComputing;
}
@property (nonatomic,retain) NSDate *startDate;
@property (nonatomic) float startWeight;
@property (nonatomic,retain) NSDate *endDate;
@property (nonatomic) float goalWeight;
@property (nonatomic) float weightChangePerDay;
@end
