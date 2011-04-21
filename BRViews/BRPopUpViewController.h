//
//  BRPopUpViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/13/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BRPopUpViewController : NSObject {
	UIView *view;
	UIView *superview;
    UIButton *screenButton;
}
@property (nonatomic,readonly,getter=isVisible) BOOL visible;
@property (nonatomic,retain) IBOutlet UIView *view;
@property (nonatomic,retain) IBOutlet UIView *superview;
- (IBAction)show:(id)sender;
- (IBAction)hide:(id)sender;
- (IBAction)toggle:(id)sender;
- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;
- (BOOL)canHide;
- (void)willShow;
- (void)didHide;
@end
