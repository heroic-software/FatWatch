//
//  UpgradeViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/8/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EWDatabase;

@interface UpgradeViewController : UIViewController {
	EWDatabase *database;
	UIActivityIndicatorView *activityView;
	UIButton *dismissButton;
	UILabel *titleLabel;
}
@property (nonatomic,retain) IBOutlet UILabel *titleLabel;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic,retain) IBOutlet UIButton *dismissButton;
- (id)initWithDatabase:(EWDatabase *)db;
- (IBAction)dismissView;
@end