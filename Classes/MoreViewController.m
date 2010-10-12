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
#import "AboutViewController.h"
#import "RegistrationViewController.h"
#import "BRColorPalette.h"


enum {
	kSectionAbout,
	kSectionOptions,
	kSectionData,
	kSectionSupport
};


enum {
	kRowExportEmail = 1,
	kRowPasscode = 1,
	kRowBMI = 2
};


static NSString * const kBadgeValueUnregistered = @"!";


@interface MoreViewController ()
- (void)showWeightChart:(BRTableButtonRow *)sender;
- (void)emailExport:(BRTableButtonRow *)sender;
- (void)doExport:(id)arg;
- (void)mailExport:(NSArray *)args;
@end


@implementation MoreViewController


@synthesize database;


- (void)awakeFromNib {
	[super awakeFromNib];
	if ([[NSUserDefaults standardUserDefaults] showRegistrationReminder]) {
		self.parentViewController.tabBarItem.badgeValue = kBadgeValueUnregistered;
	}
}


- (void)dealloc {
	[database release];
	[super dealloc];
}


#pragma mark Table Row Setup


- (void)initAboutSection {
	BRTableSection *aboutSection = [self addNewSection];
	
	BRTableButtonRow *aboutRow = [[BRTableButtonRow alloc] init];
	aboutRow.title = NSLocalizedString(@"About FatWatch", nil);
	aboutRow.object = [[[AboutViewController alloc] init] autorelease];
	aboutRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[aboutSection addRow:aboutRow animated:NO];
	[aboutRow release];

	if ([[NSUserDefaults standardUserDefaults] registration] == nil) {
		BRTableButtonRow *registerRow = [[BRTableButtonRow alloc] init];
		registerRow.title = NSLocalizedString(@"Register Now", nil);
		registerRow.titleColor = [UIColor colorWithRed:0.9f green:0 blue:0 alpha:1];
		registerRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		registerRow.object = [RegistrationViewController sharedController];
		[aboutSection addRow:registerRow animated:NO];
		[registerRow release];
	}
}


- (UIImage *)markRowImage {
	static const CGFloat width = 16;
	static const CGFloat space = 2;
	
	BRColorPalette *palette = [BRColorPalette sharedPalette];

	CGSize imageSize = CGSizeMake(4*width + 3*space, width);
	if (UIGraphicsBeginImageContextWithOptions) {
		UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
	} else {
		UIGraphicsBeginImageContext(imageSize);
	}
	[[UIColor blackColor] setStroke];
	
	CGRect rect = CGRectMake(0, 0, width, width);
	[[palette colorNamed:@"Flag0"] setFill];
	UIRectFill(rect);
	UIRectFrame(rect);

	rect.origin.x += rect.size.width + space;
	[[palette colorNamed:@"Flag1"] setFill];
	UIRectFill(rect);
	UIRectFrame(rect);
	
	rect.origin.x += rect.size.width + space;
	[[palette colorNamed:@"Flag2"] setFill];
	UIRectFill(rect);
	UIRectFrame(rect);
	
	rect.origin.x += rect.size.width + space;
	[[palette colorNamed:@"Flag3"] setFill];
	UIRectFill(rect);
	UIRectFrame(rect);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}


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
	bmiRow.title = NSLocalizedString(@"Compute BMI", @"BMI switch");
	bmiRow.object = self;
	bmiRow.key = @"displayBMI";
	[moreSection addRow:bmiRow animated:NO];
	[bmiRow release];
	
	BRTableButtonRow *markRow = [[BRTableButtonRow alloc] init];
	markRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	markRow.image = [self markRowImage];
	
	UIViewController *controller = [[FlagIconViewController alloc] init];
	markRow.title = controller.title;
	markRow.object = controller;
	[controller release];

	[moreSection addRow:markRow animated:NO];
	[markRow release];
}


- (void)initDataSection {
	BRTableSection *dataSection = [self addNewSection];
	dataSection.headerTitle = NSLocalizedString(@"Data", @"Data section title");
	
	EWWiFiAccessViewController *wifi = [[EWWiFiAccessViewController alloc] init];
	wifi.database = database;
	
	BRTableButtonRow *webServerRow = [[BRTableButtonRow alloc] init];
	webServerRow.title = NSLocalizedString(@"Import/Export via Wi-Fi", @"Wi-Fi button");
	webServerRow.titleAlignment = UITextAlignmentLeft;
	webServerRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	webServerRow.object = wifi;
	[dataSection addRow:webServerRow animated:NO];
	[webServerRow release];
	
	[wifi release];
	
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
	BRTableSection *supportSection = [self addNewSection];
	supportSection.headerTitle = NSLocalizedString(@"Support", @"Support section title");
	
	BRTableButtonRow *webRow = [[BRTableButtonRow alloc] init];
	webRow.title = NSLocalizedString(@"Visit www.fatwatchapp.com", @"Support website button");
	webRow.titleAlignment = UITextAlignmentCenter;
	webRow.object = [NSURL URLWithString:NSLocalizedString(@"http://www.fatwatchapp.com/support/", @"Support website URL")];
	[supportSection addRow:webRow animated:NO];
	[webRow release];
	
	BRTableButtonRow *twitterRow = [[BRTableButtonRow alloc] init];
	twitterRow.title = NSLocalizedString(@"Follow @FatWatch on Twitter", @"Support Twitter button");
	twitterRow.titleAlignment = UITextAlignmentCenter;
	twitterRow.object = [NSArray arrayWithObjects:
						 [NSURL URLWithString:@"tweetie://user?screen_name=FatWatch"],
						 [NSURL URLWithString:@"echofon:///user_timeline?FatWatch"],
						 [NSURL URLWithString:@"x-birdfeed://user?screen_name=FatWatch"],
						 [NSURL URLWithString:@"http://twitter.com/FatWatch"],
						 nil];
	[supportSection addRow:twitterRow animated:NO];
	[twitterRow release];
	
	BRTableButtonRow *emailRow = [[BRTableButtonRow alloc] init];
	emailRow.title = NSLocalizedString(@"Email help@fatwatchapp.com", @"Support email button");
	emailRow.titleAlignment = UITextAlignmentCenter;
	emailRow.object = [NSURL URLWithString:NSLocalizedString(@"mailto:help@fatwatchapp.com?subject=FatWatch", @"Support email URL")];
	[supportSection addRow:emailRow animated:NO];
	[emailRow release];
}


#pragma mark UIViewController


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if ([self numberOfSections] == 0) {
		[self initAboutSection];
		[self initOptionsSection];
		[self initDataSection];
		[self initSupportSection];
		[self.tableView reloadData];
	} else {
		NSArray *rows = [NSArray arrayWithObjects:
						 [NSIndexPath indexPathForRow:kRowPasscode
											inSection:kSectionOptions],
						 [NSIndexPath indexPathForRow:kRowBMI
											inSection:kSectionOptions],
						 nil];
		[self.tableView reloadRowsAtIndexPaths:rows 
							  withRowAnimation:UITableViewRowAnimationNone];
	}
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	BRTableSection *aboutSection = [self sectionAtIndex:kSectionAbout];
	if ([aboutSection numberOfRows] > 1) {
		NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
		if ([userDefs registration]) {
			[aboutSection removeRowAtIndex:1 animated:YES];
		}
		if (![userDefs showRegistrationReminder]) {
			self.parentViewController.tabBarItem.badgeValue = nil;
		}
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


- (void)showWeightChart:(BRTableButtonRow *)sender {
	[self showAlertWithTitle:NSLocalizedString(@"Weight Chart", nil)
					 message:NSLocalizedString(@"Rotate the device sideways to see a chart at any time.", @"Weight Chart alert message")];
}


- (void)emailExport:(BRTableButtonRow *)sender {
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[(UIActivityIndicatorView *)sender.accessoryView startAnimating];
	[NSThread detachNewThreadSelector:@selector(doExport:) toTarget:self withObject:nil];
}


- (void)doExport:(id)arg {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#if TARGET_IPHONE_SIMULATOR
	[NSThread sleepForTimeInterval:3];
#endif
	EWExporter *exporter = [[CSVExporter alloc] init];
	[exporter addBackupFields];
	NSData *data = [exporter dataExportedFromDatabase:database];
	[self performSelectorOnMainThread:@selector(mailExport:)
						   withObject:[NSArray arrayWithObjects:
									   [exporter contentType],
									   [exporter fileExtension],
									   data,
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

	NSDictionary *info = [[NSUserDefaults standardUserDefaults] registration];
	NSString *toRecipient = [info objectForKey:@"email"];
	
	MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
	[mail setMailComposeDelegate:self];
	if (toRecipient) {
		[mail setToRecipients:[NSArray arrayWithObject:toRecipient]];
	}
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

