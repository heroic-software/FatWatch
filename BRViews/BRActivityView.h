//
//  BRActivityView.h
//  MetroCard
//
//  Created by Benjamin Ragheb on 7/23/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BRActivityView : UIView {

}
@property (nonatomic,copy) NSString *message;
- (void)showInView:(UIView *)view;
- (void)dismiss;
@end
