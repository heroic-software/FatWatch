//
//  AboutViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/17/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "AboutViewController.h"
#import "BRTableButtonRow.h"
#import "RegistrationViewController.h"
#import "NSUserDefaults+EWAdditions.h"


#define BOOK_WELCOME_URL @"http://www.fatwatchapp.com/goto/hackdiet"


@implementation AboutViewController
{
	BOOL isShowingRegistrationInfo;
}

- (id)init {
	if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
		self.title = NSLocalizedString(@"About", @"About view title");
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}


- (void)updateRegistrationInfo {
	NSDictionary *info = [[NSUserDefaults standardUserDefaults] registration];
	if (info && !isShowingRegistrationInfo) {
		BRTableSection *section = [self sectionAtIndex:1];
		BRTableButtonRow *row = (id)[section rowAtIndex:0];
		row.cellStyle = UITableViewCellStyleSubtitle;
		row.title = info[@"name"];
		row.titleColor = [UIColor blackColor];
		row.detail = info[@"email"];
		row.object = nil;
		row.accessoryType = UITableViewCellAccessoryNone;

		isShowingRegistrationInfo = YES;
		[self.tableView reloadRowsAtIndexPaths:@[[row indexPath]]
							  withRowAnimation:UITableViewRowAnimationNone];
   }
}


- (void)viewDidLoad {
    [super viewDidLoad];
		
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

	BRTableSection *verSection = [self addNewSection];
	verSection.footerTitle = infoDictionary[@"NSHumanReadableCopyright"];
	
	BRTableRow *versionRow = [[BRTableRow alloc] init];
	versionRow.cellStyle = UITableViewCellStyleValue1;
	versionRow.selectionStyle = UITableViewCellSelectionStyleNone;
	versionRow.title = infoDictionary[@"CFBundleDisplayName"];
	versionRow.detail = [NSString stringWithFormat:@"%@ (%@)",
						 infoDictionary[@"CFBundleShortVersionString"],
						 infoDictionary[@"CFBundleVersion"],
						 nil];
	[verSection addRow:versionRow animated:NO];
	
	BRTableButtonRow *reviewRow = [[BRTableButtonRow alloc] init];
	reviewRow.title = NSLocalizedString(@"Write an App Store Review", @"App Store review button");
	reviewRow.titleAlignment = NSTextAlignmentCenter;
	reviewRow.object = [NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=285580720"];
	[verSection addRow:reviewRow animated:NO];

	BRTableSection *section;
	BRTableButtonRow *row;
	
	section = [self addNewSection];
	section.headerTitle = @"Registered to";
	
	row = [[BRTableButtonRow alloc] init];
	row.title = @"Unregistered";
	row.titleColor = [UIColor colorWithRed:0.9f green:0 blue:0 alpha:1];
	row.object = [RegistrationViewController sharedController];
	row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[section addRow:row animated:NO];
	
	section = [self addNewSection];
	section.headerTitle = @"Brought to you by";
	
	row = [[BRTableButtonRow alloc] init];
	row.cellStyle = UITableViewCellStyleSubtitle;
	row.title = @"Benjamin Ragheb";
	row.detail = @"Design & Engineering";
	row.object = [NSURL URLWithString:@"http://www.benzado.com/"];
	row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[section addRow:row animated:NO];
	
	section = [self addNewSection];
	section.headerTitle = @"Also by";
	
	row = [[BRTableButtonRow alloc] init];
	row.cellStyle = UITableViewCellStyleSubtitle;
	row.title = @"Steve Dressler";
	row.detail = @"Icon Design";
	row.object = [NSURL URLWithString:@"http://stevedressler.wordpress.com/"];
	row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[section addRow:row animated:NO];
		
	section = [self addNewSection];
	section.headerTitle = @"Thanks to";

	row = [[BRTableButtonRow alloc] init];
	row.cellStyle = UITableViewCellStyleSubtitle;
	row.title = @"Joseph Wain";
	row.detail = @"Glyphish Icon Collection";
	row.object = [NSURL URLWithString:@"http://glyphish.com/"];
	row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[section addRow:row animated:NO];

	row = [[BRTableButtonRow alloc] init];
	row.cellStyle = UITableViewCellStyleSubtitle;
	row.title = @"John Walker";
	row.detail = @"The Hacker\xe2\x80\x99s Diet";
	row.object = [NSURL URLWithString:BOOK_WELCOME_URL];
	row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[section addRow:row animated:NO];
}


- (void)viewWillAppear:(BOOL)animated {
	[self updateRegistrationInfo];
}


- (void)viewDidUnload {
	[super viewDidUnload];
	[self removeAllSections];
}




@end
