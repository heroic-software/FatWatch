//
//  EWWiFiAccessViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 6/21/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MicroWebServer.h"

@class BRReachability;
@class MicroWebServer;


@interface EWWiFiAccessViewController : UIViewController <MicroWebServerDelegate> {
	UILabel *statusLabel;
	UIActivityIndicatorView *activityView;
	UIView *detailView;
	UIView *inactiveDetailView;
	UIView *activeDetailView;
	UILabel *addressLabel;
	UILabel *nameLabel;
	UILabel *lastImportLabel;
	UILabel *lastExportLabel;
	// Not NIB Stuff
	BRReachability *reachability;
	MicroWebServer *webServer;
}
@property (nonatomic,retain) IBOutlet UILabel *statusLabel;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic,retain) IBOutlet UIView *detailView;
@property (nonatomic,retain) IBOutlet UIView *inactiveDetailView;
@property (nonatomic,retain) IBOutlet UIView *activeDetailView;
@property (nonatomic,retain) IBOutlet UILabel *addressLabel;
@property (nonatomic,retain) IBOutlet UILabel *nameLabel;
@property (nonatomic,retain) IBOutlet UILabel *lastImportLabel;
@property (nonatomic,retain) IBOutlet UILabel *lastExportLabel;
@end
