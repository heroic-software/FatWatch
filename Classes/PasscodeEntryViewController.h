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
	IBOutlet UITextField *digit0Field;
	IBOutlet UITextField *digit1Field;
	IBOutlet UITextField *digit2Field;
	IBOutlet UITextField *digit3Field;
	IBOutlet UITextField *codeField;
	UITextField *digitFields[4];
	BOOL shouldDismissView;
}
+ (BOOL)authorizationRequired;
+ (void)removePasscode;
+ (PasscodeEntryViewController *)controllerForSettingCode;
+ (PasscodeEntryViewController *)controllerForAuthorization;
- (IBAction)codeFieldEditingChanged:(id)sender;
- (void)dismissView;
- (IBAction)cancelAction;
@end
