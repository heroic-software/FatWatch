//
//  PasscodeEntryViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/22/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PasscodeEntryViewController.h"
#import "EatWatchAppDelegate.h"


enum {
	ControllerModeAuthorize,
	ControllerModeAuthorizeSuccess,
	ControllerModeAuthorizeFailure,
	ControllerModeSetCode,
	ControllerModeVerifyCode,
	ControllerModeVerifySuccess
};


@interface SettingCodeController : PasscodeEntryViewController {
	NSString *newCode;
}
@end


@interface AuthorizationController : PasscodeEntryViewController {
	NSUInteger attemptsRemaining;
	BOOL isAuthorized;
}
@end


@implementation PasscodeEntryViewController


+ (BOOL)authorizationRequired {
	return [[[NSUserDefaults standardUserDefaults] stringForKey:@"Passcode"] length] == 4;
}


+ (void)removePasscode {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Passcode"];
}


+ (PasscodeEntryViewController *)controllerForSettingCode {
	return [[[SettingCodeController alloc] init] autorelease];
}


+ (PasscodeEntryViewController *)controllerForAuthorization {
	return [[AuthorizationController alloc] init]; // don't autorelease, instance is retaining itself
}


- (id)init {
	return [super initWithNibName:@"PasscodeView" bundle:nil];
}


- (void)viewDidLoad {
	digitFields[0] = digit0Field;
	digitFields[1] = digit1Field;
	digitFields[2] = digit2Field;
	digitFields[3] = digit3Field;
}


- (void)updateDigitFields {
	int i;
	for (i = 0; i < 4; i++) {
		UITextField *digitField = digitFields[i];
		if ([codeField.text length] > i) {
			digitField.text = @"X";
		} else {
			digitField.text = @"";
		}
	}
}


- (void)codeEntered:(NSString *)userCode {
	NSAssert(NO, @"Must override.");
}


- (void)dismissView {
	NSAssert(NO, @"Must override.");
}


- (IBAction)codeFieldEditingChanged:(id)sender {
	NSString *code = codeField.text;
	[self updateDigitFields];
	if ([code length] == 4) {
		[self codeEntered:code];
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		[self performSelector:@selector(messageDelayDidEnd:) withObject:nil afterDelay:0.8];
	}
}


- (void)messageDelayDidEnd:(id)sender {
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	if (shouldDismissView) {
		[self dismissView];
	} else {
		codeField.text = @"";
		[self updateDigitFields];
	}
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return (textField == codeField);
}


- (IBAction)cancelAction {
}


@end


@implementation SettingCodeController


- (void)dealloc {
	[newCode release];
	[super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {
	navBar.hidden = NO;
	digitGroupView.frame = CGRectMake(0, 76, 320, 100);
	[codeField becomeFirstResponder];
}


- (void)codeEntered:(NSString *)userCode {
	if (newCode == nil) {
		newCode = [userCode retain];
		promptLabel.text = @"Re-enter your passcode";
	} else {
		if ([newCode isEqualToString:userCode]) {
			[[NSUserDefaults standardUserDefaults] setObject:newCode forKey:@"Passcode"];
			promptLabel.text = @"Passcode set";
			smallLabel.hidden = YES;
			shouldDismissView = YES;
		} else {
			smallLabel.hidden = NO;
			smallLabel.text = @"Passcodes do not match. Try again.";
		}
	}
}


- (void)dismissView {
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)cancelAction {
	[self dismissView];
}


@end


@implementation AuthorizationController


- (id)init {
	if ([super init]) {
		attemptsRemaining = 4;
	}
	return self;
}


- (void)viewWillAppear:(BOOL)animated {
	navBar.hidden = YES;
	digitGroupView.frame = CGRectMake(0, 57, 320, 100);
	[codeField becomeFirstResponder];
}


- (void)codeEntered:(NSString *)userCode {
	NSString *secretCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"Passcode"];
	if ([secretCode isEqualToString:userCode]) {
		promptLabel.text = @"Authorized";
		smallLabel.hidden = YES;
		isAuthorized = YES;
		shouldDismissView = YES;
	} else {
		attemptsRemaining -= 1;
		smallLabel.hidden = NO;
		smallLabel.text = [NSString stringWithFormat:@"Incorrect. %d attempts remaining.", attemptsRemaining];
		if (attemptsRemaining == 0) {
			shouldDismissView = YES;
		}
	}
}


- (void)dismissView {
	if (! isAuthorized) {
		[codeField resignFirstResponder];
		promptLabel.text = @"Authorization Failed";
		smallLabel.hidden = YES;
		return;
	}
	
	EatWatchAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate removeLaunchView:self.view transitionType:kCATransitionReveal subType:kCATransitionFromTop];
	[self autorelease];
}


@end
