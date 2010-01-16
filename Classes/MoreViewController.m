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
#import "BRReachability.h"
#import "EWWiFiAccessViewController.h"
#import "NSUserDefaults+EWAdditions.h"
#import "EWExporter.h"
#import "CSVExporter.h"
#import "FlagIconViewController.h"


static const int kSectionOptions = 0;
static const int kSectionData = 1;
static const int kSectionSupport = 2;
static const int kRowExportEmail = 1;


@implementation MoreViewController


#pragma mark Table Row Setup


- (void)initOptionsSection {
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
	
	BRTableButtonRow *markRow = [[BRTableButtonRow alloc] init];
	markRow.title = NSLocalizedString(@"Mark Icons", @"Mark Icons button");
	markRow.target = self;
	markRow.action = @selector(showMarkOptions:);
	markRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[moreSection addRow:markRow animated:NO];
	[markRow release];
}


- (void)initDataSection {
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
	emailRow.accessoryView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
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


#pragma mark NSObject


- (id)init {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"More", @"More view title");
		self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0] autorelease];
	}
	return self;
}


- (void)dealloc {
	[super dealloc];
}


#pragma mark UIViewController


- (void)viewWillAppear:(BOOL)animated {
	if ([self numberOfSections] == 0) {
		[self initOptionsSection];
		[self initDataSection];
		[self initSupportSection];
		[self.tableView reloadData];
	}
}


#pragma mark Properties


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


#pragma mark Utilities


- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] init];
	alert.title = title;
	alert.message = message;
	alert.cancelButtonIndex = 
	[alert addButtonWithTitle:NSLocalizedString(@"Dismiss", nil)];
	[alert show];
	[alert release];
}


#pragma mark Button Actions


- (void)showWiFiAccess:(BRTableButtonRow *)sender {
	EWWiFiAccessViewController *controller;
	
	controller = [[EWWiFiAccessViewController alloc] init];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}


- (void)showWeightChart:(BRTableButtonRow *)sender {
	[self showAlertWithTitle:NSLocalizedString(@"Weight Chart", nil)
					 message:NSLocalizedString(@"Rotate the device sideways to see a chart at any time.", @"Weight Chart alert message")];
}


- (void)showMarkOptions:(BRTableButtonRow *)sender {
	FlagIconViewController *mivc = [[FlagIconViewController alloc] init];
	[self.navigationController pushViewController:mivc animated:YES];
	[mivc release];
}


- (void)emailExport:(BRTableButtonRow *)sender {
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[(UIActivityIndicatorView *)sender.accessoryView startAnimating];
	[NSThread detachNewThreadSelector:@selector(doExport:) toTarget:self withObject:nil];
}


- (void)doExport:(id)arg {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	EWExporter *exporter = [[CSVExporter alloc] init];
	[self performSelectorOnMainThread:@selector(mailExport:)
						   withObject:[NSArray arrayWithObjects:
									   [exporter contentType],
									   [exporter fileExtension],
									   [exporter exportedData],
									   nil]
						waitUntilDone:NO];
	[exporter release];
	[pool release];
}


- (void)mailExport:(NSArray *)args {
	NSString *contentType = [args objectAtIndex:0];
	NSString *fileExtension = [args objectAtIndex:1];
	NSData *data = [args objectAtIndex:2];
	
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	BRTableRow *row = [[self sectionAtIndex:kSectionData] rowAtIndex:kRowExportEmail];
	[(UIActivityIndicatorView *)row.accessoryView stopAnimating];

	NSString *fileName = [@"FatWatch-Export" stringByAppendingPathExtension:fileExtension];
	
	NSString *body = [NSString stringWithFormat:
					  NSLocalizedString(@"ExportEmailBodyFormat", nil),
					  [[UIDevice currentDevice] name]];
	
	MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
	[mail setMailComposeDelegate:self];
	[mail setSubject:@"FatWatch Export"];
	[mail setMessageBody:body isHTML:YES];
	[mail addAttachmentData:data mimeType:contentType fileName:fileName];
	[self presentModalViewController:mail animated:YES];
	[mail release];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[controller dismissModalViewControllerAnimated:YES];
	if (result == MFMailComposeResultFailed) {
		[self showAlertWithTitle:NSLocalizedString(@"Mail Error", nil)
						 message:[error localizedDescription]];
	}
}


@end

