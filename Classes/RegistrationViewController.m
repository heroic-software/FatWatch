//
//  RegistrationViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/17/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "RegistrationViewController.h"
#import "NSUserDefaults+EWAdditions.h"


#if TARGET_IPHONE_SIMULATOR
#define REGISTRATION_URL @"http://fatwatchapp.test/register/"
#else
#define REGISTRATION_URL @"http://www.fatwatchapp.com/register/"
#endif


static RegistrationViewController *gSharedController = nil;


@interface RegistrationViewController ()
- (void)refreshAction:(id)sender;
@end


@implementation RegistrationViewController


+ (RegistrationViewController *)sharedController {
	if (gSharedController == nil) {
		gSharedController = [[[RegistrationViewController alloc] init] autorelease];
	}
	return gSharedController;
}


- (id)init {
    if ((self = [super initWithNibName:nil bundle:nil])) {
		self.title = NSLocalizedString(@"Product Registration", nil);
		self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}


- (void)setIsLoading:(BOOL)flag {
	UIBarButtonItem *item;
	if (flag) {
		UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		item = [[UIBarButtonItem alloc] initWithCustomView:activityView];
		[activityView startAnimating];
		[activityView release];
	} else {
		item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
	}
	self.navigationItem.rightBarButtonItem = item;
	[item release];
}


- (void)refreshAction:(id)sender {
	NSURL *url = [NSURL URLWithString:REGISTRATION_URL];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[webView loadRequest:request];
}


- (void)loadView {
	CGRect frame = CGRectMake(0, 0, 320, 200);
	
	UIView *view = [[UIView alloc] initWithFrame:frame];
	view.autoresizingMask = (UIViewAutoresizingFlexibleWidth |	
							 UIViewAutoresizingFlexibleHeight);

	webView = [[UIWebView alloc] initWithFrame:frame];
	webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |	
								UIViewAutoresizingFlexibleHeight);
	webView.delegate = self;

	[view addSubview:webView];
	[self setView:view];
	[view release];
}


- (void)viewDidAppear:(BOOL)animated {
	if (webView.request == nil) {
		[self refreshAction:nil];
	}
}


#pragma mark UIWebViewDelegate


- (void)webViewDidStartLoad:(UIWebView *)aWebView {
	[self setIsLoading:YES];
}


void EWSafeDictionarySet(NSMutableDictionary *dict, id key, id object) {
	if (object) [dict setObject:object forKey:key];
}


- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	[self setIsLoading:NO];
	if (errorToDisplay) {
		NSString *script = [NSString stringWithFormat:@"setError(\"%@\");", [[errorToDisplay localizedDescription] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
		[webView stringByEvaluatingJavaScriptFromString:script];
		[errorToDisplay release];
		errorToDisplay = nil;
	} else {
		NSString *bodyID = [webView stringByEvaluatingJavaScriptFromString:@"document.body.id"];
		if ([@"registrationForm" isEqualToString:bodyID]) {
			NSMutableDictionary *fields = [[NSMutableDictionary alloc] init];
			
			NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
			EWSafeDictionarySet(fields, @"bundle_version", [infoDictionary objectForKey:@"CFBundleVersion"]);

			UIDevice *device = [UIDevice currentDevice];
			EWSafeDictionarySet(fields, @"system_name", [device systemName]);
			EWSafeDictionarySet(fields, @"system_version", [device systemVersion]);
			EWSafeDictionarySet(fields, @"device_model", [device model]);
			EWSafeDictionarySet(fields, @"device_udid", [device uniqueIdentifier]);
			
			NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
			EWSafeDictionarySet(fields, @"first_launch", [defs firstLaunchDate]);
			EWSafeDictionarySet(fields, @"system_languages", [[defs arrayForKey:@"AppleLanguages"] componentsJoinedByString:@","]);

			for (NSString *key in fields) {
				NSString *js = [NSString stringWithFormat:
								@"document.forms[0].elements[\"rg[%@]\"].value=\"%@\";",
								key, [fields objectForKey:key]];
				[webView stringByEvaluatingJavaScriptFromString:js];
			}
			
			[fields release];

			[defs setShowRegistrationReminder:NO];
		}
		else if ([@"registrationComplete" isEqualToString:bodyID]) {
			NSString *keyString = [webView stringByEvaluatingJavaScriptFromString:
								   @"z = [];"
								   @"for (k in registration) { z.push(k); };"
								   @"z.join(\"\\0\");"
								   ];
			NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
			for (NSString *key in [keyString componentsSeparatedByString:@"\0"]) {
				NSString *keyPath = [@"registration." stringByAppendingString:key];
				NSString *eval = [webView stringByEvaluatingJavaScriptFromString:keyPath];
				[info setObject:eval forKey:key];
			}
			[[NSUserDefaults standardUserDefaults] setRegistration:info];
			[info release];
		}
	}
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
	[webView release];
	webView = nil;
}


- (void)viewDidUnload {
	[self releaseWebView];
}


- (void)dealloc {
	if (gSharedController == self) gSharedController = nil;
	[self releaseWebView];
    [super dealloc];
}


@end
