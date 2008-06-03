//
//  DataViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/25/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataViewController : UIViewController {
	UILabel *messageView;
	UIView *dataView;
}
@property (nonatomic,readonly) UIView *dataView;
- (NSString *)message;
- (UIView *)loadDataView;
- (BOOL)hasEnoughData;
- (void)dataChanged;
@end
