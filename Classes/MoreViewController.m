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


@implementation MoreViewController


- (id)init {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"MORE_VIEW_TITLE", nil);
		self.tabBarItem.image = [UIImage imageNamed:@"TabIconMore.png"];
		webServerSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
		[webServerSwitch addTarget:self action:@selector(toggleWebServerSwitch:) forControlEvents:UIControlEventValueChanged];
		webServer = [[MicroWebServer alloc] init];
		webServer.name = @"FatWatch";
		webServer.delegate = [[WebServerDelegate alloc] init];
	}
	return self;
}


- (void)dealloc {
	[webServerSwitch release];
	[webServer.delegate release];
	[webServer release];
	[super dealloc];
}


/*
 0/0: View Graph
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
		case 0: return 1;
		case 1: return (webServer.running ? 2 : 1);
		case 2: return 2;
	}
	return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0: return @"More";
		case 1: return @"Transfer";
		case 2: return @"Support";
	}
	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
	switch (indexPath.section) {
		case 0:
			cell.text = @"Weight Graph";
			break;
		case 1:
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			if (indexPath.row == 0) {
				cell.text = @"Wi-Fi Import/Export";
				cell.accessoryView = webServerSwitch;
			} else {
				cell.text = [webServer.url description];
				cell.textColor = [UIColor blueColor];
				cell.textAlignment = UITextAlignmentCenter;
			}
			break;
		case 2:
			if (indexPath.row == 0) {
				cell.text = @"www.fatwatchapp.com";
			} else {
				cell.text = @"support@fatwatchapp.com";
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
		case 2: return @"FatWatch™ ©2008 Benjamin Ragheb";
	}
	return nil;
}


- (void)showAlertTitle:(NSString *)title message:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert autorelease];
}


- (void)openURLWithString:(NSString *)text {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:text]];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			[self showAlertTitle:@"Weight Graph" message:@"Rotate iPhone at any time to see a graph of your weight."];
			break;
		case 1:
			if (indexPath.row == 1) {
				[self showAlertTitle:@"Import/Export" message:@"Enter this address into your computer's web browser to transfer weight data to and from FatWatch."];
			}
			break;
		case 2:
			if (indexPath.row == 0) {
				[self openURLWithString:@"http://www.fatwatchapp.com/"];
			} else {
				[self openURLWithString:@"mailto:support@fatwatchapp.com"];
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


@end

