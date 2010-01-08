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
#import "NSUserDefaults+EWAdditions.h"
#import "EWExporter.h"
#import "CSVExporter.h"


@implementation MoreViewController


- (void)initMoreSection {
	BRTableSection *moreSection = [self addNewSection];
	moreSection.footerTitle = NSLocalizedString(@"Other settings are in the Settings app.", @"More section footer");
	
	BRTableButtonRow *chartRow = [[BRTableButtonRow alloc] init];
	chartRow.title = NSLocalizedString(@"Weight Chart", @"Weight Chart button");
	chartRow.target = self;
	chartRow.action = @selector(showWeightChart:);
	[moreSection addRow:chartRow animated:NO];
	[chartRow release];
	
	BRTableSwitchRow *passcodeRow = [[BRTableSwitchRow alloc] init];
	passcodeRow.title = NSLocalizedString(@"Require Passcode", @"Passcode switch");
	passcodeRow.object = self;
	passcodeRow.key = @"passcodeEnabled";
	[moreSection addRow:passcodeRow animated:NO];
	[passcodeRow release];
	
	BRTableSwitchRow *bmiRow = [[BRTableSwitchRow alloc] init];
	bmiRow.title = NSLocalizedString(@"Monitor BMI", @"BMI switch");
	bmiRow.object = self;
	bmiRow.key = @"displayBMI";
	[moreSection addRow:bmiRow animated:NO];
	[bmiRow release];
}


- (void)initTransferSection {
	BRTableSection *dataSection = [self addNewSection];
	dataSection.headerTitle = NSLocalizedString(@"Data", @"Data section title");
	
	BRTableButtonRow *webServerRow = [[BRTableButtonRow alloc] init];
	webServerRow.title = NSLocalizedString(@"Import/Export via Wi-Fi", @"Wi-Fi button");
	webServerRow.titleAlignment = UITextAlignmentLeft;
	webServerRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	webServerRow.target = self;
	webServerRow.action = @selector(showWiFiAccess:);
	[dataSection addRow:webServerRow animated:NO];
	[webServerRow release];
	
	BRTableButtonRow *emailRow = [[BRTableButtonRow alloc] init];
	emailRow.title = NSLocalizedString(@"Export via Email", @"Export as email attachment button");
	emailRow.disabled = ![MFMailComposeViewController canSendMail];
	emailRow.target = self;
	emailRow.action = @selector(emailExport:);
	[dataSection addRow:emailRow animated:NO];
	[emailRow release];
}


- (void)initSupportSection {
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

	BRTableSection *supportSection = [self addNewSection];
	supportSection.headerTitle = NSLocalizedString(@"Support", @"Support section title");
	supportSection.footerTitle = [infoDictionary objectForKey:@"NSHumanReadableCopyright"];
	
	BRTableButtonRow *webRow = [[BRTableButtonRow alloc] init];
	webRow.title = NSLocalizedString(@"www.fatwatchapp.com", @"Support website button");
	webRow.titleAlignment = UITextAlignmentCenter;
	webRow.object = [NSURL URLWithString:NSLocalizedString(@"http://www.fatwatchapp.com/support/", @"Support website URL")];
	[supportSection addRow:webRow animated:NO];
	[webRow release];
	
	NSString *emailURLFormat = NSLocalizedString(@"mailto:help@fatwatchapp.com?subject=FatWatch%%20%@", @"Support email URL");
	NSString *emailURLString = [NSString stringWithFormat:emailURLFormat, [infoDictionary objectForKey:@"CFBundleShortVersionString"]];
	
	BRTableButtonRow *emailRow = [[BRTableButtonRow alloc] init];
	emailRow.title = NSLocalizedString(@"help@fatwatchapp.com", @"Support email button");
	emailRow.titleAlignment = UITextAlignmentCenter;
	emailRow.object = [NSURL URLWithString:emailURLString];
	[supportSection addRow:emailRow animated:NO];
	[emailRow release];
	
	BRTableButtonRow *reviewRow = [[BRTableButtonRow alloc] init];
	reviewRow.title = NSLocalizedString(@"Write an App Store Review", @"App Store review button");
	reviewRow.titleAlignment = UITextAlignmentCenter;
	reviewRow.object = [NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=285580720&mt=8"];
	[supportSection addRow:reviewRow animated:NO];
	[reviewRow release];
}


- (id)init {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"More", @"More view title");
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
	return [[NSUserDefaults standardUserDefaults] isBMIEnabled];
}


- (void)setDisplayBMI:(BOOL)flag {
	if (flag) {
		UIViewController *controller = [HeightEntryViewController controller];
		[self presentModalViewController:controller animated:YES];
	} else {
		[[NSUserDefaults standardUserDefaults] setBMIEnabled:NO];
	}
}


- (void)showWiFiAccess:(BRTableButtonRow *)sender {
	EWWiFiAccessViewController *controller;
	
	controller = [[EWWiFiAccessViewController alloc] init];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}


- (void)showWeightChart:(BRTableButtonRow *)sender {
	UIAlertView *alert = [[UIAlertView alloc] init];
	alert.title = NSLocalizedString(@"Weight Chart", nil);
	alert.message = NSLocalizedString(@"Rotate the device sideways to see a chart at any time.", @"Weight Chart alert message");
	alert.cancelButtonIndex = [alert addButtonWithTitle:NSLocalizedString(@"Dismiss", nil)];
	[alert show];
	[alert release];
}


- (void)emailExport:(BRTableButtonRow *)sender {
	// TODO: display a progress indicator
	EWExporter *exporter = [[CSVExporter alloc] init];
	
	MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
	
	NSString *fileName = [@"FatWatch-Export" stringByAppendingPathExtension:[exporter fileExtension]];
	
	// TODO: add link to help page (what to do with this file?)
	NSString *body = [NSString stringWithFormat:@"The attached file is weight history exported from <a href=\"http://www.fatwatchapp.com/\">FatWatch</a> on <b>%@</b>.", [[UIDevice currentDevice] name]];
	
	[mail setMailComposeDelegate:self];
	[mail setSubject:@"FatWatch Export"];
	[mail setMessageBody:body isHTML:YES];
	[mail addAttachmentData:[exporter exportedData]
				   mimeType:[exporter contentType]
				   fileName:fileName];
	
	[self presentModalViewController:mail animated:YES];
	[mail release];

	[exporter release];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[controller dismissModalViewControllerAnimated:YES];
}


@end

