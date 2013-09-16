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

@class EWDatabase;
@class EWGoal;

@interface GoalViewController : BRTableViewController <UIActionSheetDelegate> {
	EWDatabase *database;
	EWGoal *goal;
	BOOL isSetupForGoal, isSetupForBMI;
	BOOL needsReload;
}
@property (nonatomic,strong) IBOutlet EWDatabase *database;
- (IBAction)clearGoal:(id)sender;
@end
