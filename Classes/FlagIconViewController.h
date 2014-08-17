//
//  FlagIconViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/16/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlagTabView;

@interface FlagIconViewController : UIViewController
@property (nonatomic,strong) IBOutlet FlagTabView *flagTabView;
@property (nonatomic,strong) IBOutlet UIScrollView *iconArea;
@property (nonatomic,strong) IBOutlet UIView *enableLadderView;
@property (nonatomic,strong) IBOutlet UIView *disableLadderView;
- (IBAction)flagButtonAction:(UIButton *)sender;
- (IBAction)useLastFlagForLadder:(UIButton *)sender;
- (IBAction)useLastFlagForIcon:(UIButton *)sender;
- (IBAction)explainLadder:(UIButton *)sender;
@end
