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


NSString *kPasscodeKey = @"Passcode";


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
	return [[[NSUserDefaults standardUserDefaults] stringForKey:kPasscodeKey] length] == 4;
}


+ (void)removePasscode {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kPasscodeKey];
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
	digitViews[0] = digit0View;
	digitViews[1] = digit1View;
	digitViews[2] = digit2View;
	digitViews[3] = digit3View;
}


- (void)updateDigitViews {
	int i;
	UIImage *img0 = [UIImage imageNamed:@"Passcode0.png"];
	UIImage *img1 = [UIImage imageNamed:@"Passcode1.png"];
	
	for (i = 0; i < 4; i++) {
		UIImageView *digitView = digitViews[i];
		digitView.image = ([codeField.text length] > i) ? img1 : img0;
	}
}


- (IBAction)codeFieldEditingChanged:(id)sender {
	NSString *code = codeField.text;
	[self updateDigitViews];
	if ([code length] == 4) {
		BOOL dismissView = [self shouldDismissEnteredCode:code];
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		[self performSelector:@selector(messageDelayDidEnd:) 
				   withObject:[NSNumber numberWithBool:dismissView]
				   afterDelay:0.8];
	}
}


- (void)messageDelayDidEnd:(NSNumber *)shouldDismiss {
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	if ([shouldDismiss boolValue]) {
		[self dismissView];
	} else {
		codeField.text = @"";
		[self updateDigitViews];
	}
}


#pragma mark Abstract Methods


- (BOOL)shouldDismissEnteredCode:(NSString *)userCode {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (void)dismissView {
	[self doesNotRecognizeSelector:_cmd];
}

- (IBAction)cancelAction {
	[self doesNotRecognizeSelector:_cmd];
}


@end


@implementation SettingCodeController


- (void)dealloc {
	[newCode release];
	[super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {
	navBar.hidden = NO;
	digitGroupView.frame = CGRectMake(0, 88, 320, 79);
	[codeField becomeFirstResponder];
}


- (BOOL)shouldDismissEnteredCode:(NSString *)userCode {
	if (newCode == nil) {
		newCode = [userCode retain];
		promptLabel.text = NSLocalizedString(@"PASSCODE_SET_2", nil);
		smallLabel.hidden = YES;
		return NO;
	}
	
	if ([newCode isEqualToString:userCode]) {
		[[NSUserDefaults standardUserDefaults] setObject:newCode forKey:kPasscodeKey];
		promptLabel.text = NSLocalizedString(@"PASSCODE_SET_DONE", nil);
		smallLabel.hidden = YES;
		return YES;
	}
	
	promptLabel.text = NSLocalizedString(@"PASSCODE_SET_1", nil);
	smallLabel.hidden = NO;
	smallLabel.text = NSLocalizedString(@"PASSCODE_NO_MATCH", nil);
	[newCode release];
	newCode = nil;
	return NO;
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
	digitGroupView.frame = CGRectMake(0, 69, 320, 79);
	[codeField becomeFirstResponder];
}


- (BOOL)shouldDismissEnteredCode:(NSString *)userCode {
	NSString *secretCode = [[NSUserDefaults standardUserDefaults] stringForKey:kPasscodeKey];
	if ([secretCode isEqualToString:userCode]) {
		promptLabel.text = NSLocalizedString(@"PASSCODE_AUTH_DONE", nil);
		smallLabel.hidden = YES;
		isAuthorized = YES;
		return YES;
	} else {
		attemptsRemaining -= 1;
		smallLabel.hidden = NO;
		NSString *format = NSLocalizedString(@"PASSCODE_AUTH_WRONG", nil);
		smallLabel.text = [NSString stringWithFormat:format, attemptsRemaining];
		return (attemptsRemaining == 0);
	}
}


- (void)dismissView {
	if (! isAuthorized) {
		[codeField resignFirstResponder];
		codeField.hidden = YES;
		promptLabel.text = NSLocalizedString(@"PASSCODE_AUTH_FAIL", nil);
		smallLabel.hidden = YES;
		return;
	}
	
	EatWatchAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate removeLaunchView:self.view transitionType:kCATransitionReveal subType:kCATransitionFromTop];
	[self autorelease];
}


@end
