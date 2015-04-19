/*
 * UpgradeViewController.m
 * Created by Benjamin Ragheb on 1/8/10.
 * Copyright 2015 Heroic Software Inc
 *
 * This file is part of FatWatch.
 *
 * FatWatch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FatWatch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "UpgradeViewController.h"
#import "EWDatabase.h"
#import "EatWatchAppDelegate.h"


@interface UpgradeViewController ()
- (void)doUpgrade:(id)nothing;
- (void)didUpgrade;
@end



@implementation UpgradeViewController
{
	EWDatabase *database;
	UIActivityIndicatorView *activityView;
	UIButton *dismissButton;
	UILabel *titleLabel;
}

@synthesize titleLabel;
@synthesize activityView;
@synthesize dismissButton;


- (id)initWithDatabase:(EWDatabase *)db {
    if ((self = [super initWithNibName:@"UpgradeView" bundle:nil])) {
        database = db;
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
	@autoreleasepool {
		[database upgrade];
#if TARGET_IPHONE_SIMULATOR
		[NSThread sleepForTimeInterval:5];
#endif
		[self performSelectorOnMainThread:@selector(didUpgrade) withObject:nil waitUntilDone:NO];
	}
}


- (void)didUpgrade {
	titleLabel.text = NSLocalizedString(@"Upgrade Complete", @"Upgrade complete title");
	[activityView stopAnimating];
	dismissButton.hidden = NO;
}


- (IBAction)dismissView {
	[(id)[[UIApplication sharedApplication] delegate] continueLaunchSequence];
}




@end
