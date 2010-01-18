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


@implementation AboutViewController


- (id)init {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"About", @"About view title");
	}
	return self;
}


- (void)updateRegistrationInfo {
	NSDictionary *info = [[NSUserDefaults standardUserDefaults] registration];
	if (info && !isShowingRegistrationInfo) {
		BRTableSection *section = [self sectionAtIndex:1];
		BRTableButtonRow *row = (id)[section rowAtIndex:0];
		row.cellStyle = UITableViewCellStyleSubtitle;
		row.title = [info objectForKey:@"name"];
		row.detail = [info objectForKey:@"email"];
		row.object = nil;
		row.accessoryType = UITableViewCellAccessoryNone;

		isShowingRegistrationInfo = YES;
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[row indexPath]]
							  withRowAnimation:UITableViewRowAnimationNone];
   }
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

	BRTableSection *verSection = [self addNewSection];
	verSection.footerTitle = [infoDictionary objectForKey:@"NSHumanReadableCopyright"];
	
	BRTableRow *versionRow = [[BRTableRow alloc] init];
	versionRow.cellStyle = UITableViewCellStyleValue1;
//	versionRow.selectionStyle = UITableViewCellSelectionStyleNone;
	versionRow.title = [infoDictionary objectForKey:@"CFBundleDisplayName"];
	versionRow.detail = [NSString stringWithFormat:@"%@ (%@)",
						 [infoDictionary objectForKey:@"CFBundleShortVersionString"],
						 [infoDictionary objectForKey:@"CFBundleVersion"],
						 nil];
	[verSection addRow:versionRow animated:NO];
	[versionRow release];
	
	BRTableSection *section;
	BRTableButtonRow *row;
	
	section = [self addNewSection];
	section.headerTitle = @"Registered to";
	
	row = [[BRTableButtonRow alloc] init];
	row.title = @"Unregistered";
	row.object = [RegistrationViewController sharedController];
	row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[section addRow:row animated:NO];
	[row release];
	
	section = [self addNewSection];
	section.headerTitle = @"Brought to you by";
	
	row = [[BRTableButtonRow alloc] init];
	row.cellStyle = UITableViewCellStyleSubtitle;
	row.title = @"Benjamin Ragheb";
	row.detail = @"Design & Development";
	row.object = [NSURL URLWithString:@"http://www.benzado.com/"];
	[section addRow:row animated:NO];
	[row release];
	
	section = [self addNewSection];
	section.headerTitle = @"Thanks to";
	
	row = [[BRTableButtonRow alloc] init];
	row.cellStyle = UITableViewCellStyleSubtitle;
	row.title = @"Steve Dressler";
	row.detail = @"Icon Design";
	row.object = [NSURL URLWithString:@"http://stevedressler.wordpress.com/"];
	[section addRow:row animated:NO];
	[row release];
	
	row = [[BRTableButtonRow alloc] init];
	row.cellStyle = UITableViewCellStyleSubtitle;
	row.title = @"Joseph Wain";
	row.detail = @"Glyphish Icons";
	row.object = [NSURL URLWithString:@"http://glyphish.com/"];
	[section addRow:row animated:NO];
	[row release];
	
	row = [[BRTableButtonRow alloc] init];
	row.cellStyle = UITableViewCellStyleSubtitle;
	row.title = @"John Walker";
	row.detail = @"Author of The Hacker's Diet";
	row.object = [NSURL URLWithString:@"http://fourmilab.ch/hackdiet/"];
	[section addRow:row animated:NO];
	[row release];
}


- (void)viewWillAppear:(BOOL)animated {
	[self updateRegistrationInfo];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	[super viewDidUnload];
	[self removeAllSections];
}


- (void)dealloc {
    [super dealloc];
}


@end
