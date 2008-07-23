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


@implementation PasscodeEntryViewController


+ (BOOL)authorizationRequired {
	return [[[NSUserDefaults standardUserDefaults] stringForKey:@"Passcode"] length] == 4;
}


+ (void)removePasscode {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Passcode"];
}


+ (PasscodeEntryViewController *)controllerForSetCode {
	PasscodeEntryViewController *controller = [[PasscodeEntryViewController alloc] init];
	controller->mode = ControllerModeSetCode;
	return controller;
}


- (id)init {
	if ([super initWithNibName:@"PasscodeView" bundle:nil]) {
		// Initialization code
		attemptsRemaining = 3;
	}
	return self;
}


- (void)dealloc {
	[newCode release];
	[super dealloc];
}


- (void)viewDidLoad {
	digitFields[0] = digit0Field;
	digitFields[1] = digit1Field;
	digitFields[2] = digit2Field;
	digitFields[3] = digit3Field;
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
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


- (void)viewWillAppear:(BOOL)animated {
	[codeField becomeFirstResponder];
}


- (void)viewDidAppear:(BOOL)animated {
	if (! [codeField isFirstResponder]) [codeField becomeFirstResponder];
}


- (void)codeEntered:(NSString *)userCode {
	if (mode == ControllerModeAuthorize) {
		NSString *secretCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"Passcode"];
		if ([secretCode isEqualToString:userCode]) {
			promptLabel.text = @"Authorized";
			smallLabel.hidden = YES;
			mode = ControllerModeAuthorizeSuccess;
		} else {
			attemptsRemaining -= 1;
			smallLabel.hidden = NO;
			smallLabel.text = [NSString stringWithFormat:@"Incorrect! %d attempts remaining.", attemptsRemaining];
			if (attemptsRemaining == 0) {
				mode = ControllerModeAuthorizeFailure;
			}
		}
	} else if (mode == ControllerModeSetCode) {
		promptLabel.text = @"Re-enter your passcode";
		newCode = [userCode retain];
		mode = ControllerModeVerifyCode;
	} else if (mode == ControllerModeVerifyCode) {
		if ([newCode isEqualToString:userCode]) {
			promptLabel.text = @"Passcode set";
			smallLabel.hidden = YES;
			[[NSUserDefaults standardUserDefaults] setObject:newCode forKey:@"Passcode"];
			mode = ControllerModeVerifySuccess;
		} else {
			smallLabel.hidden = NO;
			smallLabel.text = @"Passcodes do not match. Try again.";
		}
	}
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[self performSelector:@selector(messageDelayDidEnd:) withObject:nil afterDelay:0.8];
}


- (void)messageDelayDidEnd:(id)sender {
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	if (mode == ControllerModeAuthorizeFailure) {
		exit(0);
	} else if (mode == ControllerModeAuthorizeSuccess) {
		[self dismissView];
	} else if (mode == ControllerModeVerifySuccess) {
		[self dismissModalViewControllerAnimated:YES];
	} else {
		codeField.text = @"";
		[self updateDigitFields];
	}
}


- (IBAction)codeFieldEditingChanged:(id)sender {
	NSString *code = codeField.text;
	[self updateDigitFields];
	if ([code length] == 4) {
		[self codeEntered:code];
	}
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return (textField == codeField);
}


- (void)dismissView {
	EatWatchAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	UIView *window = self.view.superview;
	
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionReveal];
	[animation setSubtype:kCATransitionFromTop];
	[animation setDuration:0.8];
	
	[self.view removeFromSuperview];
	[appDelegate setupRootView];
	
	[[window layer] addAnimation:animation forKey:nil];
	
	[self autorelease];
}


@end
