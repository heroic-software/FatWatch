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
		webServer.delegate = self;
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
	[webServer release];
    [super dealloc];
}


- (void)viewDidLoad {
	activeDetailView.alpha = 0;
	inactiveDetailView.alpha = 0;
	[detailView addSubview:activeDetailView];
	[detailView addSubview:inactiveDetailView];
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


#pragma mark MicroWebServerDelegate


- (void)webConnectionWillReceiveRequest:(MicroWebConnection *)connection {
	[activityView startAnimating];
	statusLabel.text = @"Receiving";
}


- (void)webConnectionDidReceiveRequest:(MicroWebConnection *)connection {
	statusLabel.text = @"Processing";
}


- (void)webConnectionWillSendResponse:(MicroWebConnection *)connection {
	statusLabel.text = @"Sending";
}


- (void)webConnectionDidSendResponse:(MicroWebConnection *)connection {
	[activityView stopAnimating];
	statusLabel.text = @"Ready";
}


- (void)handleWebConnection:(MicroWebConnection *)connection {
	// TODO: CHANGE THIS
	WebServerDelegate *wsd = [[WebServerDelegate alloc] init];
	[wsd handleWebConnection:connection];
	[wsd release];
}


#pragma mark BRReachabilityDelegate


- (void)reachability:(BRReachability *)reachability didUpdateFlags:(SCNetworkReachabilityFlags)flags {
	BOOL networkAvailable = ((flags & kSCNetworkReachabilityFlagsReachable) &&
							 !(flags & kSCNetworkReachabilityFlagsIsWWAN));
		
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	if (networkAvailable && !webServer.running) {
		// Start it up
		[webServer start];
		if (webServer.running) {
			statusLabel.text = @"Ready";
			addressLabel.text = [webServer.url description];
			nameLabel.text = webServer.name;
			activeDetailView.alpha = 1;
			inactiveDetailView.alpha = 0;
		} else {
			statusLabel.text = @"Failed to Start";
			activeDetailView.alpha = 0;
			inactiveDetailView.alpha = 1;
		}
	} else if (!networkAvailable) {
		// Shut it down
		if (webServer.running) {
			[webServer stop];
		}
		statusLabel.text = @"Off";
		activeDetailView.alpha = 0;
		inactiveDetailView.alpha = 1;
	}
	[UIView commitAnimations];
}


@end
