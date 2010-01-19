//
//  BookViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/18/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "BookViewController.h"

enum {
	kToolbarItemTagBack = 1,
	kToolbarItemTagForward = 2
};


#if TARGET_IPHONE_SIMULATOR
#define BOOK_SCRIPT_URL @"http://fatwatchapp.test/app/mobile.js"
#define BOOK_COVER_URL @"http://fatwatchapp.test/app/book-cover"
#define BOOK_INDEX_URL @"http://fatwatchapp.test/app/book-index"
#else
#define BOOK_SCRIPT_URL @"http://www.fatwatchapp.com/app/mobile.js"
#define BOOK_COVER_URL @"http://www.fatwatchapp.com/app/book-cover"
#define BOOK_INDEX_URL @"http://www.fatwatchapp.com/app/book-index"
#endif


static NSString * const BookURLKey = @"BookURL";
static NSString * const BookScrollKey = @"BookYOffset";


@implementation BookViewController


@synthesize webView;
@synthesize goBackItem;
@synthesize goForwardItem;


- (id)init {
    if (self = [super initWithNibName:@"BookView" bundle:nil]) {
		self.title = NSLocalizedString(@"Browser", nil);
		self.hidesBottomBarWhenPushed = YES;

		UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
		self.navigationItem.rightBarButtonItem = activityItem;
		[activityItem release];
		[activityView release];

	}
    return self;
}


- (IBAction)goCover {
	NSURL *url = [NSURL URLWithString:BOOK_COVER_URL];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[webView loadRequest:request];
}


- (IBAction)goIndex {
	NSURL *url = [NSURL URLWithString:BOOK_INDEX_URL];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[webView loadRequest:request];
}


- (UIActivityIndicatorView *)activityView {
	return (id)self.navigationItem.rightBarButtonItem.customView;
}


#pragma mark UIViewController


- (void)viewWillAppear:(BOOL)animated {
	if (webView.request == nil) {
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		NSString *lastString = [defs stringForKey:BookURLKey];
		if (lastString) {
			scrollToYOffset = [defs integerForKey:BookScrollKey];
			NSURL *lastURL = [NSURL URLWithString:lastString];
			[webView loadRequest:[NSURLRequest requestWithURL:lastURL]];
		} else {
			[self goCover];
		}
	}
}


- (void)viewWillDisappear:(BOOL)animated {
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs setObject:[[webView.request URL] absoluteString] forKey:BookURLKey];
	int pageYOffset = [[webView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
	[defs setInteger:pageYOffset forKey:BookScrollKey];
}


#pragma mark UIWebViewDelegate


- (void)webViewDidStartLoad:(UIWebView *)aWebView {
	[[self activityView] startAnimating];
}


- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	[[self activityView] stopAnimating];
	
	NSString *documentTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	if ([documentTitle length] > 0) {
		self.navigationItem.title = documentTitle;
	} else {
		self.navigationItem.title = self.title;
	}
	
	if (errorToDisplay) {
		NSString *script = [NSString stringWithFormat:@"setError(\"%@\");", [[errorToDisplay localizedDescription] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
		[webView stringByEvaluatingJavaScriptFromString:script];
		[errorToDisplay release];
		errorToDisplay = nil;
	} else {
		NSString *script;

		// always set the variable, even if 0
		script = [NSString stringWithFormat:@"var scrollToY = %d;", scrollToYOffset];
		[webView stringByEvaluatingJavaScriptFromString:script];
		scrollToYOffset = 0;

		// inject mobile stylesheet
		script =
		(
		 @"var e = document.createElement('script');"
		 @"e.setAttribute('type','text/javascript');"
		 @"e.setAttribute('src','" BOOK_SCRIPT_URL @"');"
		 @"document.getElementsByTagName('head')[0].appendChild(e);"
		 );
		[webView stringByEvaluatingJavaScriptFromString:script];
	}
	
	goBackItem.enabled = [webView canGoBack];
	goForwardItem.enabled = [webView canGoForward];
}


- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
	[errorToDisplay release];
	errorToDisplay = [error retain];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"RegistrationError" ofType:@"html"];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
	[url release];
}


#pragma mark Cleanup


- (void)releaseWebView {
	webView.delegate = nil;
	self.webView = nil;
}


- (void)viewDidUnload {
	[self releaseWebView];
	self.goBackItem = nil;
	self.goForwardItem = nil;
}


- (void)dealloc {
	[self releaseWebView];
	[goBackItem release];
	[goForwardItem release];
	[errorToDisplay release];
    [super dealloc];
}


@end
