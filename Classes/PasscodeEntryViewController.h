//
//  PasscodeEntryViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/22/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PasscodeEntryViewController : UIViewController {
	UINavigationBar *navBar;
	UIView *digitGroupView;
	UILabel *promptLabel;
	UILabel *smallLabel;
	UIImageView *digit0View;
	UIImageView *digit1View;
	UIImageView *digit2View;
	UIImageView *digit3View;
	UITextField *codeField;
	UIImageView *digitViews[4];
}
@property (nonatomic,retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic,retain) IBOutlet UIView *digitGroupView;
@property (nonatomic,retain) IBOutlet UILabel *promptLabel;
@property (nonatomic,retain) IBOutlet UILabel *smallLabel;
@property (nonatomic,retain) IBOutlet UIImageView *digit0View;
@property (nonatomic,retain) IBOutlet UIImageView *digit1View;
@property (nonatomic,retain) IBOutlet UIImageView *digit2View;
@property (nonatomic,retain) IBOutlet UIImageView *digit3View;
@property (nonatomic,retain) IBOutlet UITextField *codeField;
+ (BOOL)authorizationRequired;
+ (void)removePasscode;
+ (PasscodeEntryViewController *)controllerForSettingCode;
+ (PasscodeEntryViewController *)controllerForAuthorization;
- (IBAction)codeFieldEditingChanged:(id)sender;
// Abstract:
- (BOOL)shouldDismissEnteredCode:(NSString *)userCode;
- (void)dismissView;
- (IBAction)cancelAction;
@end
