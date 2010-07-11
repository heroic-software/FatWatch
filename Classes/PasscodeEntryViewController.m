//
//  PasscodeEntryViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/22/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

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


@synthesize navBar;
@synthesize digitGroupView;
@synthesize promptLabel;
@synthesize smallLabel;
@synthesize digit0View;
@synthesize digit1View;
@synthesize digit2View;
@synthesize digit3View;
@synthesize codeField;


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
	return [[[AuthorizationController alloc] init] autorelease];
}


- (id)init {
	return [super initWithNibName:@"PasscodeView" bundle:nil];
}


- (void)dealloc {
	[navBar release];
	[digitGroupView release];
	[promptLabel release];
	[smallLabel release];
	[digit0View release];
	[digit1View release];
	[digit2View release];
	[digit3View release];
	[codeField release];
	[super dealloc];
}


- (void)viewDidLoad {
	digitViews[0] = digit0View;
	digitViews[1] = digit1View;
	digitViews[2] = digit2View;
	digitViews[3] = digit3View;
	codeField.hidden = YES;
}


- (void)updateDigitViews {
	UIImage *img0 = [UIImage imageNamed:@"Passcode0"];
	UIImage *img1 = [UIImage imageNamed:@"Passcode1"];
	
	for (int i = 0; i < 4; i++) {
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
	[super viewWillAppear:animated];
	navBar.hidden = NO;
	digitGroupView.frame = CGRectMake(0, 88, 320, 79);
	[codeField becomeFirstResponder];
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[codeField becomeFirstResponder];
}


- (BOOL)shouldDismissEnteredCode:(NSString *)userCode {
	if (newCode == nil) {
		newCode = [userCode retain];
		promptLabel.text = NSLocalizedString(@"Re-enter your passcode", @"Passcode re-entry");
		smallLabel.hidden = YES;
		return NO;
	}
	
	if ([newCode isEqualToString:userCode]) {
		[[NSUserDefaults standardUserDefaults] setObject:newCode forKey:kPasscodeKey];
		promptLabel.text = NSLocalizedString(@"Passcode set", @"Passcode set");
		smallLabel.hidden = YES;
		return YES;
	}
	
	promptLabel.text = NSLocalizedString(@"Enter a passcode", @"Enter a passcode");
	smallLabel.hidden = NO;
	smallLabel.text = NSLocalizedString(@"Passcodes did not match. Try again.", @"Passcode mismatch");
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
	[super viewWillAppear:animated];
	navBar.hidden = NO;
	UINavigationItem *item = [navBar topItem];
	item.leftBarButtonItem = nil;
	item.title = @"FatWatch";
	navBar.tintColor = [UIColor colorWithRed:0.894 green:0 blue:0.02 alpha:1];
	digitGroupView.frame = CGRectMake(0, 88, 320, 79);
	[codeField becomeFirstResponder];
}


- (BOOL)shouldDismissEnteredCode:(NSString *)userCode {
	NSString *secretCode = [[NSUserDefaults standardUserDefaults] stringForKey:kPasscodeKey];
	if ([secretCode isEqualToString:userCode]) {
		promptLabel.text = NSLocalizedString(@"Authorized", @"Passcode authorized");
		smallLabel.hidden = YES;
		isAuthorized = YES;
		return YES;
	} else {
		attemptsRemaining -= 1;
		smallLabel.hidden = NO;
		NSString *format = NSLocalizedString(@"Incorrect. %d attempts remaining.", @"Passcode wrong, count remaining attempts");
		smallLabel.text = [NSString stringWithFormat:format, attemptsRemaining];
		return (attemptsRemaining == 0);
	}
}


- (void)dismissView {
	if (! isAuthorized) {
		[codeField resignFirstResponder];
		promptLabel.text = NSLocalizedString(@"Authorization failed", @"Passcode failed");
		smallLabel.hidden = YES;
		return;
	}
	
	id appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate removeLaunchViewWithTransitionType:kCATransitionReveal 
											subType:kCATransitionFromTop];
}


@end
