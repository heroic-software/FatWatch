//
//  BookViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/18/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BookViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *webView;
	NSError *errorToDisplay;
	UIBarButtonItem *goBackItem;
	UIBarButtonItem *goForwardItem;
	int scrollToYOffset;
}
@property (nonatomic,retain) IBOutlet UIWebView *webView;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *goBackItem;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *goForwardItem;
- (IBAction)goCover;
- (IBAction)goIndex;
@end
