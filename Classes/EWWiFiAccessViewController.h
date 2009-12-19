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
@class CSVReader;


#define kEWReadyAddressTag 101
#define kEWReadyNameTag 102

#define kEWProgressTitleTag 401
#define kEWProgressDetailTag 402
#define kEWProgressButtonTag 403


@interface EWWiFiAccessViewController : UIViewController <MicroWebServerDelegate> {
	UILabel *statusLabel;
	UIActivityIndicatorView *activityView;
	UIView *detailView;
	UIView *inactiveDetailView;
	UIView *activeDetailView;
	UIView *promptDetailView;
	UIView *progressDetailView;
	UIProgressView *progressView;
	UILabel *lastImportLabel;
	UILabel *lastExportLabel;
	// Not NIB Stuff
	BRReachability *reachability;
	MicroWebServer *webServer;
	// Import State
	NSData *importData;
	NSStringEncoding importEncoding;
	CSVReader *reader;
	NSInteger lineCount, importCount;
	NSDictionary *webResources;
}
@property (nonatomic,retain) IBOutlet UILabel *statusLabel;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic,retain) IBOutlet UIView *detailView;
@property (nonatomic,retain) IBOutlet UIView *inactiveDetailView;
@property (nonatomic,retain) IBOutlet UIView *activeDetailView;
@property (nonatomic,retain) IBOutlet UIView *promptDetailView;
@property (nonatomic,retain) IBOutlet UIView *progressDetailView;
@property (nonatomic,retain) IBOutlet UIProgressView *progressView;
@property (nonatomic,retain) IBOutlet UILabel *lastImportLabel;
@property (nonatomic,retain) IBOutlet UILabel *lastExportLabel;
- (IBAction)performMergeImport;
- (IBAction)performReplaceImport;
- (IBAction)cancelImport;
- (IBAction)dismissProgressView;
@end
