//
//  PasscodeEntryViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/22/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PasscodeEntryViewController : UIViewController
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet UIView *digitGroupView;
@property (nonatomic, weak) IBOutlet UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet UILabel *smallLabel;
@property (nonatomic, weak) IBOutlet UIImageView *digit0View;
@property (nonatomic, weak) IBOutlet UIImageView *digit1View;
@property (nonatomic, weak) IBOutlet UIImageView *digit2View;
@property (nonatomic, weak) IBOutlet UIImageView *digit3View;
@property (nonatomic, weak) IBOutlet UITextField *codeField;
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
