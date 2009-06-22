//
//  MoreViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/10/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "MoreViewController.h"
#import "MicroWebServer.h"
#import "PasscodeEntryViewController.h"
#import "BRTableButtonRow.h"
#import "BRTableSwitchRow.h"
#import "HeightEntryViewController.h"
#import "EWGoal.h"
#import "BRReachability.h"
#import "EWWiFiAccessViewController.h"


@implementation MoreViewController


- (void)initMoreSection {
	BRTableSection *moreSection = [self addNewSection];
	moreSection.footerTitle = NSLocalizedString(@"MORE_SECTION_FOOTER", nil);
	
	BRTableButtonRow *chartRow = [[BRTableButtonRow alloc] init];
	chartRow.title = NSLocalizedString(@"WEIGHT_GRAPH_ROW_TITLE", nil);
	chartRow.target = self;
	chartRow.action = @selector(showWeightChart:);
	[moreSection addRow:chartRow animated:NO];
	[chartRow release];
	
	BRTableSwitchRow *passcodeRow = [[BRTableSwitchRow alloc] init];
	passcodeRow.title = NSLocalizedString(@"PASSCODE_ROW_TITLE", nil);
	passcodeRow.object = self;
	passcodeRow.key = @"passcodeEnabled";
	[moreSection addRow:passcodeRow animated:NO];
	[passcodeRow release];
	
	BRTableSwitchRow *bmiRow = [[BRTableSwitchRow alloc] init];
	bmiRow.title = NSLocalizedString(@"BMI_ROW_TITLE", nil);
	bmiRow.object = self;
	bmiRow.key = @"displayBMI";
	[moreSection addRow:bmiRow animated:NO];
	[bmiRow release];
}


- (void)initTransferSection {
	BRTableSection *dataSection = [self addNewSection];
	
	BRTableButtonRow *webServerRow = [[BRTableButtonRow alloc] init];
	webServerRow.title = NSLocalizedString(@"WIFI_ROW_TITLE", nil);
	webServerRow.titleAlignment = UITextAlignmentLeft;
	webServerRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	webServerRow.target = self;
	webServerRow.action = @selector(showWiFiAccess:);
	[dataSection addRow:webServerRow animated:NO];
	[webServerRow release];
}


- (void)initSupportSection {
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

	BRTableSection *supportSection = [self addNewSection];
	supportSection.headerTitle = NSLocalizedString(@"SUPPORT_SECTION_TITLE", nil);
	supportSection.footerTitle = [infoDictionary objectForKey:@"NSHumanReadableCopyright"];
	
	BRTableButtonRow *webRow = [[BRTableButtonRow alloc] init];
	webRow.title = NSLocalizedString(@"SUPPORT_WEBSITE_TITLE", nil);
	webRow.titleAlignment = UITextAlignmentCenter;
	webRow.object = [NSURL URLWithString:NSLocalizedString(@"SUPPORT_WEBSITE_URL", nil)];
	[supportSection addRow:webRow animated:NO];
	[webRow release];
	
	NSString *emailURLFormat = NSLocalizedString(@"SUPPORT_EMAIL_URL", nil);
	NSString *emailURLString = [NSString stringWithFormat:emailURLFormat, [infoDictionary objectForKey:@"CFBundleShortVersionString"]];
	
	BRTableButtonRow *emailRow = [[BRTableButtonRow alloc] init];
	emailRow.title = NSLocalizedString(@"SUPPORT_EMAIL_TITLE", nil);
	emailRow.titleAlignment = UITextAlignmentCenter;
	emailRow.object = [NSURL URLWithString:emailURLString];
	[supportSection addRow:emailRow animated:NO];
	[emailRow release];
	
	BRTableButtonRow *reviewRow = [[BRTableButtonRow alloc] init];
	reviewRow.title = NSLocalizedString(@"WRITE_A_REVIEW", nil);
	reviewRow.titleAlignment = UITextAlignmentCenter;
	reviewRow.object = [NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=285580720&mt=8"];
	[supportSection addRow:reviewRow animated:NO];
	[reviewRow release];
}


- (id)init {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"MORE_VIEW_TITLE", nil);
		UITabBarItem *item = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0];
		self.tabBarItem = item;
		[item release];
	}
	return self;
}


- (void)dealloc {
	[super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {
	if ([self numberOfSections] == 0) {
		[self initMoreSection];
		[self initTransferSection];
		[self initSupportSection];
	}
	[self.tableView reloadData];
}


- (BOOL)passcodeEnabled {
	return [PasscodeEntryViewController authorizationRequired];
}


- (void)setPasscodeEnabled:(BOOL)flag {
	if (flag) {
		UIViewController *controller = [PasscodeEntryViewController controllerForSettingCode];
		[self presentModalViewController:controller animated:YES];
	} else {
		[PasscodeEntryViewController removePasscode];
	}	
}


- (BOOL)displayBMI {
	return [EWGoal isBMIEnabled];
}


- (void)setDisplayBMI:(BOOL)flag {
	if (flag) {
		UIViewController *controller = [HeightEntryViewController controller];
		[self presentModalViewController:controller animated:YES];
	} else {
		[EWGoal setBMIEnabled:NO];
	}
}


- (void)showWiFiAccess:(BRTableButtonRow *)sender {
	EWWiFiAccessViewController *controller;
	
	controller = [[EWWiFiAccessViewController alloc] init];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}


- (void)showAlertTitle:(NSString *)title message:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, nil) 
													message:NSLocalizedString(message, nil) 
												   delegate:nil
										  cancelButtonTitle:NSLocalizedString(@"OK_BUTTON", nil)
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}


- (void)showWeightChart:(BRTableButtonRow *)sender {
	[self showAlertTitle:@"WEIGHT_GRAPH_ROW_TITLE" message:@"WEIGHT_GRAPH_ROW_MESSAGE"];
}


- (void)showWebAddress:(BRTableButtonRow *)sender {
	[self showAlertTitle:@"WIFI_ROW_TITLE" message:@"WIFI_ROW_MESSAGE"];
}


- (void)showWiFiRequiredMessage:(BRTableButtonRow *)sender {
	[self showAlertTitle:@"WIFI_ROW_TITLE" message:@"WIFI_REQUIRED_MESSAGE"];
}


- (void)openURLWithString:(NSString *)text {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:text]];
}


@end

