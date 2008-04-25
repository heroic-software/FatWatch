//
//  DataViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/25/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataViewController : UIViewController {
	NSUInteger dbChangeCount;
	UILabel *messageView;
	UIView *dataView;
}
@property (nonatomic,readonly) UIView *dataView;
@end
