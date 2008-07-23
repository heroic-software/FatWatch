//
//  PasscodeEntryViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/22/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PasscodeEntryViewController : UIViewController {
	IBOutlet UILabel *promptLabel;
	IBOutlet UILabel *smallLabel;
	IBOutlet UITextField *digit0Field;
	IBOutlet UITextField *digit1Field;
	IBOutlet UITextField *digit2Field;
	IBOutlet UITextField *digit3Field;
	IBOutlet UITextField *codeField;
	UITextField *digitFields[4];
	NSUInteger attemptsRemaining;
	int mode;
	NSString *newCode;
}
+ (BOOL)authorizationRequired;
+ (void)removePasscode;
+ (PasscodeEntryViewController *)controllerForSetCode;
- (IBAction)codeFieldEditingChanged:(id)sender;
- (void)dismissView;
@end
