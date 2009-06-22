//
//  EWWiFiAccessViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 6/21/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "EWWiFiAccessViewController.h"

#import "RootViewController.h"
#import "BRReachability.h"
#import "MicroWebServer.h"
#import "WebServerDelegate.h"


// TODO: Disable Weight Chart while view is visible.
// TODO: Store Last Import, Last Export Dates
// TODO: Show Activity during import/export.


@implementation EWWiFiAccessViewController


@synthesize statusLabel;
@synthesize activityView;
@synthesize detailView;
@synthesize inactiveDetailView;
@synthesize activeDetailView;
@synthesize addressLabel;
@synthesize nameLabel;
@synthesize lastImportLabel;
@synthesize lastExportLabel;


- (id)init {
    if (self = [super initWithNibName:@"EWWiFiAccessView" bundle:nil]) {
		self.title = @"Wi-Fi Import/Export";
		self.hidesBottomBarWhenPushed = YES;
		
		reachability = [[BRReachability alloc] init];
		reachability.delegate = self;
		
		webServer = [[MicroWebServer alloc] init];
		NSString *devName = [[UIDevice currentDevice] name];
		webServer.name = [NSString stringWithFormat:@"FatWatch (%@)", devName];
		webServer.delegate = [[WebServerDelegate alloc] init];
    }
    return self;
}


- (void)dealloc {
	[statusLabel release];
	[activityView release];
	[detailView release];
	[inactiveDetailView release];
	[activeDetailView release];
	[addressLabel release];
	[nameLabel release];
	[lastImportLabel release];
	[lastExportLabel release];
	[reachability release];
	[webServer.delegate release];
	[webServer release];
    [super dealloc];
}


- (void)viewDidAppear:(BOOL)animated {
	[RootViewController setAutorotationEnabled:NO];
	[reachability startMonitoring];
}


- (void)viewWillDisappear:(BOOL)animated {
	[reachability stopMonitoring];
	[webServer stop];
	[RootViewController setAutorotationEnabled:YES];
}


#pragma mark BRReachabilityDelegate


- (void)reachability:(BRReachability *)reachability didUpdateFlags:(SCNetworkReachabilityFlags)flags {
	BOOL networkAvailable = ((flags & kSCNetworkReachabilityFlagsReachable) &&
							 !(flags & kSCNetworkReachabilityFlagsIsWWAN));
	
	if (networkAvailable && !webServer.running) {
		// Start it up
		[webServer start];
		if (webServer.running) {
			statusLabel.text = @"Ready";
			addressLabel.text = [webServer.url description];
			nameLabel.text = webServer.name;
			[inactiveDetailView removeFromSuperview];
			[detailView addSubview:activeDetailView];
		} else {
			statusLabel.text = @"Failed to Start";
			[detailView addSubview:inactiveDetailView];
		}
	} else if (!networkAvailable) {
		// Shut it down
		if (webServer.running) {
			[webServer stop];
		}
		statusLabel.text = @"Off";
		[activeDetailView removeFromSuperview];
		[detailView addSubview:inactiveDetailView];
	}
}


@end
