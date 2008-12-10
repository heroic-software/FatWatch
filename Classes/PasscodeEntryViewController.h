//
//  PasscodeEntryViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/22/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PasscodeEntryViewController : UIViewController {
	IBOutlet UINavigationBar *navBar;
	IBOutlet UIView *digitGroupView;
	IBOutlet UILabel *promptLabel;
	IBOutlet UILabel *smallLabel;
	IBOutlet UIImageView *digit0View;
	IBOutlet UIImageView *digit1View;
	IBOutlet UIImageView *digit2View;
	IBOutlet UIImageView *digit3View;
	IBOutlet UITextField *codeField;
	UIImageView *digitViews[4];
}
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
