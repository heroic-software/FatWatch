//
//  UpgradeViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/8/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "UpgradeViewController.h"
#import "EWDatabase.h"
#import "EatWatchAppDelegate.h"


@implementation UpgradeViewController


@synthesize titleLabel;
@synthesize activityView;
@synthesize dismissButton;


- (id)initWithDatabase:(EWDatabase *)db {
    if (self = [super initWithNibName:@"UpgradeView" bundle:nil]) {
        database = [db retain];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	titleLabel.text = NSLocalizedString(@"Upgrading...", @"Upgrade in progress title");
}


- (void)viewDidAppear:(BOOL)animated {
	[NSThread detachNewThreadSelector:@selector(doUpgrade:) toTarget:self withObject:nil];
	[activityView startAnimating];
}


- (void)doUpgrade:(id)nothing {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[database upgrade];
#if TARGET_IPHONE_SIMULATOR
	[NSThread sleepForTimeInterval:5];
#endif
	[self performSelectorOnMainThread:@selector(didUpgrade) withObject:nil waitUntilDone:NO];
	[pool release];
}


- (void)didUpgrade {
	[database upgrade];
	titleLabel.text = NSLocalizedString(@"Upgrade Complete", @"Upgrade complete title");
	[activityView stopAnimating];
	dismissButton.hidden = NO;
}


- (IBAction)dismissView {
	[EWDatabase setSharedDatabase:database];
	id appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate removeLaunchViewWithTransitionType:kCATransitionReveal
											subType:kCATransitionFromTop];
}


- (void)dealloc {
	[database release];
    [super dealloc];
}


@end
