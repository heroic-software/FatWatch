//
//  RootViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/12/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RootViewController : UIViewController {
	UIViewController *portraitViewController;
	UIViewController *landscapeViewController;
	UIViewController *currentViewController;
}
@property (nonatomic,retain) UIViewController *portraitViewController;
@property (nonatomic,retain) UIViewController *landscapeViewController;
@end
