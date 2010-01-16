//
//  FlagIconViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/16/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlagTabView;

@interface FlagIconViewController : UIViewController {
	FlagTabView *flagTabView;
	UIScrollView *iconArea;
	UIView *enableLadderView;
	UIView *disableLadderView;
	NSArray *iconPaths;
	int flagIndex;
	UIView *iconView;
}
@property (nonatomic,retain) IBOutlet FlagTabView *flagTabView;
@property (nonatomic,retain) IBOutlet UIScrollView *iconArea;
@property (nonatomic,retain) IBOutlet UIView *enableLadderView;
@property (nonatomic,retain) IBOutlet UIView *disableLadderView;
- (IBAction)flagButtonAction:(UIButton *)sender;
- (IBAction)useLastFlagForLadder:(UIButton *)sender;
- (IBAction)useLastFlagForIcon:(UIButton *)sender;
- (IBAction)explainLadder:(UIButton *)sender;
@end
