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
	NSArray *iconPaths;
	int flagIndex;
}
@property (nonatomic,retain) IBOutlet FlagTabView *flagTabView;
@property (nonatomic,retain) IBOutlet UIScrollView *iconArea;
- (IBAction)flagButtonAction:(UIButton *)sender;
@end
