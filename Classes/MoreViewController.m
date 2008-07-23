//
//  MoreViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/10/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "MoreViewController.h"
#import "MicroWebServer.h"
#import "WebServerDelegate.h"
#import "PasscodeEntryViewController.h"


@implementation MoreViewController


- (id)init {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"MORE_VIEW_TITLE", nil);
		self.tabBarItem.image = [UIImage imageNamed:@"TabIconMore.png"];
		
		webServerSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
		[webServerSwitch addTarget:self action:@selector(toggleWebServerSwitch:) forControlEvents:UIControlEventValueChanged];
		
		webServer = [[MicroWebServer alloc] init];
		webServer.name = [NSString stringWithFormat:@"FatWatch (%@)", [[UIDevice currentDevice] name]];
		webServer.delegate = [[WebServerDelegate alloc] init];
		
		passcodeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
		[passcodeSwitch addTarget:self action:@selector(togglePasscodeSwitch:) forControlEvents:UIControlEventValueChanged];
		passcodeSwitch.on = [PasscodeEntryViewController authorizationRequired];
	}
	return self;
}


- (void)dealloc {
	[passcodeSwitch release];
	[webServerSwitch release];
	[webServer.delegate release];
	[webServer release];
	[super dealloc];
}


/*
 0/0: Weight Chart
 0/1: Passcode
 1/0: Import/Export
 2/-: "Support"
 2/0: www.fatwatchapp.com
 2/1: support@fatwatchapp.com
 */


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0: return 2;
		case 1: return (webServer.running ? 2 : 1);
		case 2: return 2;
	}
	return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0: return NSLocalizedString(@"MORE_SECTION_TITLE", nil);
		case 1: return NSLocalizedString(@"TRANSFER_SECTION_TITLE", nil);
		case 2: return NSLocalizedString(@"SUPPORT_SECTION_TITLE", nil);
	}
	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
	switch (indexPath.section) {
		case 0:
			if (indexPath.row == 0) {
				cell.text = NSLocalizedString(@"WEIGHT_GRAPH_ROW_TITLE", nil);
			} else {
				cell.text = @"Require Passcode";
				cell.accessoryView = passcodeSwitch;
			}
			break;
		case 1:
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			if (indexPath.row == 0) {
				cell.text = NSLocalizedString(@"WIFI_ROW_TITLE", nil);
				cell.accessoryView = webServerSwitch;
			} else {
				cell.text = [webServer.url description];
				cell.textColor = [UIColor blueColor];
				cell.textAlignment = UITextAlignmentCenter;
			}
			break;
		case 2:
			if (indexPath.row == 0) {
				cell.text = NSLocalizedString(@"SUPPORT_WEBSITE_TITLE", nil);
			} else {
				cell.text = NSLocalizedString(@"SUPPORT_EMAIL_TITLE", nil);
			}
			cell.textAlignment = UITextAlignmentCenter;
			break;
	}
	return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 0: return nil;
		case 1: return nil;
		case 2: return NSLocalizedString(@"COPYRIGHT", nil);
	}
	return nil;
}


- (void)showAlertTitle:(NSString *)title message:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, nil) 
													message:NSLocalizedString(message, nil) 
												   delegate:nil
										  cancelButtonTitle:NSLocalizedString(@"OK_BUTTON", nil)
										  otherButtonTitles:nil];
	[alert show];
	[alert autorelease];
}


- (void)openURLWithString:(NSString *)text {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:text]];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			if (indexPath.row == 0) {
				[self showAlertTitle:@"WEIGHT_GRAPH_ROW_TITLE" message:@"WEIGHT_GRAPH_ROW_MESSAGE"];
			}
			break;
		case 1:
			if (indexPath.row == 1) {
				[self showAlertTitle:@"WIFI_ROW_TITLE" message:@"WIFI_ROW_MESSAGE"];
			}
			break;
		case 2:
			if (indexPath.row == 0) {
				[self openURLWithString:NSLocalizedString(@"SUPPORT_WEBSITE_URL", nil)];
			} else {
				[self openURLWithString:NSLocalizedString(@"SUPPORT_EMAIL_URL", nil)];
			}
			break;
	}
	[[self.tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
}


- (void)toggleWebServerSwitch:(id)sender {
	NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]];
	if (webServerSwitch.on && !webServer.running) {
		[webServer start];
		[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
	} else if (!webServerSwitch.on && webServer.running) {
		[webServer stop];
		[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
	}
}


- (void)togglePasscodeSwitch:(id)sender {
	if (passcodeSwitch.on) {
		PasscodeEntryViewController *controller = [PasscodeEntryViewController controllerForSetCode];
		[self presentModalViewController:controller animated:YES];
	} else {
		[PasscodeEntryViewController removePasscode];
	}
}


@end

