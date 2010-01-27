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


@interface GoalViewController : BRTableViewController <UIActionSheetDelegate> {
	BOOL isSetupForGoal, isSetupForBMI;
	BOOL needsReload;
}
@end
