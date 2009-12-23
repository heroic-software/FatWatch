//
//  EWWiFiAccessViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 6/21/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MicroWebServer.h"
#import "EWImporter.h"


@class BRReachability;
@class MicroWebServer;


#define kEWReadyAddressTag 101
#define kEWReadyNameTag 102

#define kEWProgressTitleTag 401
#define kEWProgressDetailTag 402
#define kEWProgressButtonTag 403


@interface EWWiFiAccessViewController : UIViewController <MicroWebServerDelegate,EWImporterDelegate> {
	UILabel *statusLabel;
	UIActivityIndicatorView *activityView;
	UIView *detailView;
	UIView *inactiveDetailView;
	UIView *activeDetailView;
	UIView *progressDetailView;
	UIProgressView *progressView;
	UILabel *lastImportLabel;
	UILabel *lastExportLabel;
	// Not NIB Stuff
	BRReachability *reachability;
	MicroWebServer *webServer;
	NSDictionary *webResources;
	NSMutableDictionary *exportDefaults;
	// Import State
	EWImporter *importer;
}
@property (nonatomic,retain) IBOutlet UILabel *statusLabel;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic,retain) IBOutlet UIView *detailView;
@property (nonatomic,retain) IBOutlet UIView *inactiveDetailView;
@property (nonatomic,retain) IBOutlet UIView *activeDetailView;
@property (nonatomic,retain) IBOutlet UIView *progressDetailView;
@property (nonatomic,retain) IBOutlet UIProgressView *progressView;
@property (nonatomic,retain) IBOutlet UILabel *lastImportLabel;
@property (nonatomic,retain) IBOutlet UILabel *lastExportLabel;
- (IBAction)dismissProgressView;
@end
