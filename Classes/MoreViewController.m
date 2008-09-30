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
#import "BRTableButtonRow.h"
#import "BRTableSwitchRow.h"


@implementation MoreViewController


- (void)initMoreSection {
	BRTableSection *moreSection = [[BRTableSection alloc] init];
	moreSection.headerTitle = NSLocalizedString(@"MORE_SECTION_TITLE", nil);
	
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
	
	[self addSection:moreSection animated:NO];
	[moreSection release];
}


- (void)initTransferSection {
	BRTableSection *dataSection = [[BRTableSection alloc] init];
	dataSection.headerTitle = NSLocalizedString(@"TRANSFER_SECTION_TITLE", nil);
	
	BRTableSwitchRow *webServerRow = [[BRTableSwitchRow alloc] init];
	webServerRow.title = NSLocalizedString(@"WIFI_ROW_TITLE", nil);
	webServerRow.object = self;
	webServerRow.key = @"webServerEnabled";
	[dataSection addRow:webServerRow animated:NO];
	[webServerRow release];
	
	[self addSection:dataSection animated:NO];
	[dataSection release];
}


- (void)initSupportSection {
	BRTableSection *supportSection = [[BRTableSection alloc] init];
	supportSection.headerTitle = NSLocalizedString(@"SUPPORT_SECTION_TITLE", nil);

	NSString *footerFormat = NSLocalizedString(@"COPYRIGHT", nil);
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	supportSection.footerTitle = [NSString stringWithFormat:footerFormat, version];
	
	BRTableButtonRow *webRow = [[BRTableButtonRow alloc] init];
	webRow.title = NSLocalizedString(@"SUPPORT_WEBSITE_TITLE", nil);
	webRow.titleAlignment = UITextAlignmentCenter;
	webRow.object = [NSURL URLWithString:NSLocalizedString(@"SUPPORT_WEBSITE_URL", nil)];
	[supportSection addRow:webRow animated:NO];
	[webRow release];
	
	NSString *emailURLFormat = NSLocalizedString(@"SUPPORT_EMAIL_URL", nil);
	NSString *emailURLString = [NSString stringWithFormat:emailURLFormat, version];
	
	BRTableButtonRow *emailRow = [[BRTableButtonRow alloc] init];
	emailRow.title = NSLocalizedString(@"SUPPORT_EMAIL_TITLE", nil);
	emailRow.titleAlignment = UITextAlignmentCenter;
	emailRow.object = [NSURL URLWithString:emailURLString];
	[supportSection addRow:emailRow animated:NO];
	[emailRow release];
	
	[self addSection:supportSection animated:NO];
	[supportSection release];
}


- (id)init {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"MORE_VIEW_TITLE", nil);
		UITabBarItem *item = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0];
		self.tabBarItem = item;
		[item release];
		
		webServer = [[MicroWebServer alloc] init];
		webServer.name = [NSString stringWithFormat:@"FatWatch (%@)", [[UIDevice currentDevice] name]];
		webServer.delegate = [[WebServerDelegate alloc] init];

		[self initMoreSection];
		[self initTransferSection];
		[self initSupportSection];
	}
	return self;
}


- (void)dealloc {
	[webServer.delegate release];
	[webServer release];
	[super dealloc];
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


- (BOOL)webServerEnabled {
	return webServer.running;
}


- (void)setWebServerEnabled:(BOOL)flag {
	BRTableSection *transferSection = [self sectionAtIndex:1];
	
	if (flag && !webServer.running) {
		[webServer start];
		BRTableButtonRow *addressRow = [[BRTableButtonRow alloc] init];
		addressRow.title = [webServer.url description];
		addressRow.target = self;
		addressRow.action = @selector(showWebAddress:);
		addressRow.titleColor = [UIColor blueColor];
		addressRow.titleAlignment = UITextAlignmentCenter;
		
		[transferSection addRow:addressRow animated:YES];
	} else if (!flag && webServer.running) {
		[webServer stop];
		[transferSection removeRowAtIndex:1 animated:YES];
	}
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


- (void)showWeightChart:(BRTableButtonRow *)sender {
	[self showAlertTitle:@"WEIGHT_GRAPH_ROW_TITLE" message:@"WEIGHT_GRAPH_ROW_MESSAGE"];
}


- (void)showWebAddress:(BRTableButtonRow *)sender {
	[self showAlertTitle:@"WIFI_ROW_TITLE" message:@"WIFI_ROW_MESSAGE"];
}


- (void)openURLWithString:(NSString *)text {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:text]];
}


@end

