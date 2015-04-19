/*
 * RegistrationViewController.m
 * Created by Benjamin Ragheb on 1/17/10.
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

#import "RegistrationViewController.h"
#import "NSUserDefaults+EWAdditions.h"


#if TARGET_IPHONE_SIMULATOR
#define REGISTRATION_URL_PREFIX @"http://fatwatchapp.test/register/?check="
#else
#define REGISTRATION_URL_PREFIX @"http://www.fatwatchapp.com/register/?check="
#endif


static RegistrationViewController *gSharedController = nil;


@interface RegistrationViewController ()
- (void)refreshAction:(id)sender;
@end


@implementation RegistrationViewController
{
	UIWebView *webView;
	NSError *errorToDisplay;
}

+ (RegistrationViewController *)sharedController {
	if (gSharedController == nil) {
		gSharedController = [[RegistrationViewController alloc] init];
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
	} else {
		item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
	}
	self.navigationItem.rightBarButtonItem = item;
}


- (void)refreshAction:(id)sender {
	NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
	NSString *urlStr = [REGISTRATION_URL_PREFIX stringByAppendingString:udid];
	NSURL *url = [NSURL URLWithString:urlStr];
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
	if (object) dict[key] = object;
}


- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	[self setIsLoading:NO];
	if (errorToDisplay) {
		NSString *script = [NSString stringWithFormat:@"setError(\"%@\");", [[errorToDisplay localizedDescription] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
		[webView stringByEvaluatingJavaScriptFromString:script];
		errorToDisplay = nil;
	} else {
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		NSString *bodyID = [webView stringByEvaluatingJavaScriptFromString:@"document.body.id"];
		if ([@"registrationForm" isEqualToString:bodyID]) {
			NSMutableDictionary *fields = [[NSMutableDictionary alloc] init];
			
			NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
			EWSafeDictionarySet(fields, @"bundle_version", infoDictionary[@"CFBundleVersion"]);

			UIDevice *device = [UIDevice currentDevice];
			EWSafeDictionarySet(fields, @"system_name", [device systemName]);
			EWSafeDictionarySet(fields, @"system_version", [device systemVersion]);
			EWSafeDictionarySet(fields, @"device_model", [device model]);
			EWSafeDictionarySet(fields, @"device_udid", [[device identifierForVendor] UUIDString]);
			
			EWSafeDictionarySet(fields, @"first_launch", [defs firstLaunchDate]);
			EWSafeDictionarySet(fields, @"system_languages", [[defs arrayForKey:@"AppleLanguages"] componentsJoinedByString:@","]);

			for (NSString *key in fields) {
				NSString *js = [NSString stringWithFormat:
								@"document.forms[0].elements[\"rg[%@]\"].value=\"%@\";",
								key, fields[key]];
				[webView stringByEvaluatingJavaScriptFromString:js];
			}
			

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
				info[key] = eval;
			}
			[defs setRegistration:info];
			// Clear the reminder here too in case we are reusing a registration
			// and never see the form.
			[defs setShowRegistrationReminder:NO];
		}
	}
}


- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
	errorToDisplay = error;
	NSString *path = [[NSBundle mainBundle] pathForResource:@"RegistrationError" ofType:@"htm"];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
}


#pragma mark Cleanup


- (void)releaseWebView {
	webView.delegate = nil;
	webView = nil;
}


- (void)viewDidUnload {
	[self releaseWebView];
}


- (void)dealloc {
	if (gSharedController == self) gSharedController = nil;
	[self releaseWebView];
}


@end
