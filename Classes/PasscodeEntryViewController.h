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
@property (nonatomic,strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic,strong) IBOutlet UIView *digitGroupView;
@property (nonatomic,strong) IBOutlet UILabel *promptLabel;
@property (nonatomic,strong) IBOutlet UILabel *smallLabel;
@property (nonatomic,strong) IBOutlet UIImageView *digit0View;
@property (nonatomic,strong) IBOutlet UIImageView *digit1View;
@property (nonatomic,strong) IBOutlet UIImageView *digit2View;
@property (nonatomic,strong) IBOutlet UIImageView *digit3View;
@property (nonatomic,strong) IBOutlet UITextField *codeField;
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
