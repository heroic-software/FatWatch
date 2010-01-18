//
//  RegistrationViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/17/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RegistrationViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *webView;
	NSError *errorToDisplay;
}
+ (RegistrationViewController *)sharedController;
@end
