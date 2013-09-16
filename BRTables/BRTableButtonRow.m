//
//  BRTableButtonRow.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/25/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTableButtonRow.h"
#import "BRTableSection.h"
#import "BRTableViewController.h"
#import "BRConfirmationAlert.h"
#import "BRActivityView.h"


static BRActivityView *gLoadingView = nil;


@implementation BRTableButtonRow


@synthesize target;
@synthesize action;
@synthesize disabled;
@synthesize followURLRedirects;


+ (BRTableButtonRow *)rowWithTitle:(NSString *)aTitle target:(id)aTarget action:(SEL)anAction {
	BRTableButtonRow *row = [[BRTableButtonRow alloc] init];
	row.title = aTitle;
	row.target = aTarget;
	row.action = anAction;
	return row;
}


- (void)showActivityView {
	if (gLoadingView) return;
	gLoadingView = [[BRActivityView alloc] init];
	gLoadingView.message = @"Loading";
	[gLoadingView showInView:self.section.controller.view.window];
}


- (void)hideActivityView {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showActivityView) object:nil];
	[gLoadingView dismiss];
	gLoadingView = nil;
}


- (BOOL)openURL:(NSURL *)url {
	if (self.followURLRedirects) {
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		[NSURLConnection connectionWithRequest:request delegate:self];
		[self performSelector:@selector(showActivityView) withObject:nil afterDelay:0.2];
		return YES;
	} else {
		return [[UIApplication sharedApplication] openURL:url];
	}
}


- (BRConfirmationAlert *)confirmationAlertForURL:(NSURL *)url {
	BRConfirmationAlert *alert = [[BRConfirmationAlert alloc] init];
	alert.title = [url host];
	if ([[url scheme] isEqualToString:@"mailto"]) {
		alert.message = @"Would you like to open Mail?";
		alert.buttonTitle = @"Mail";
	} else if ([[url scheme] isEqualToString:@"itms-apps"]) {
		alert.message = @"Would you like to open the App Store?";
		alert.buttonTitle = @"App Store";
	} else if ([[url scheme] hasPrefix:@"http"]) {
		alert.message = @"Would you like to open this website?";
		alert.buttonTitle = @"Website";
	} else {
		alert.message = @"Would you like to open this link?";
		alert.buttonTitle = @"Open";
	}
	return alert;
}


- (BOOL)openThing:(id)thing {
	if ([thing isKindOfClass:[NSArray class]]) {
		for (id subthing in thing) {
			if ([self openThing:subthing]) return YES;
		}
	}
	else if ([thing isKindOfClass:[NSURL class]]) {
		if ([[UIApplication sharedApplication] canOpenURL:thing]) {
			BRConfirmationAlert *alert = [self confirmationAlertForURL:thing];
			[[alert confirmBeforeSendingMessageTo:self] openURL:thing];
			return YES;
		}
	}
	else if ([thing isKindOfClass:[UIViewController class]]) {
		[self.section.controller presentViewController:thing forRow:self];
		return YES;
	}
	return NO;
}


#pragma mark BRTableRow


- (void)configureCell:(UITableViewCell *)cell {
	[super configureCell:cell];
	cell.textLabel.textColor = self.disabled ? [UIColor grayColor] : self.titleColor;
}


- (void)didSelect {
	[self deselectAnimated:YES];
	if (disabled) return;
	if (self.target) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.action withObject:self];
#pragma clang diagnostic pop
	} else {
		if (! [self openThing:self.object]) {
			NSLog(@"Warning: nothing on device to open row object %@",
				  self.object);
		}
	}
}


#pragma mark NSURLConnection
// http://developer.apple.com/iphone/library/qa/qa2008/qa1629.html


// If the URL resulted in a redirect, update target to be the new URL.
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
	if ([response URL]) {
		self.object = [response URL];
		NSLog(@"Updating URL for \"%@\" to %@", self.title, self.object);
	}
    return request;
}


// The URL successfully loaded, so pass it along to the system.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self hideActivityView];
    [[UIApplication sharedApplication] openURL:self.object];
}


// The URL failed to load.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self hideActivityView];
	UIAlertView *alert = [[UIAlertView alloc] init];
	alert.title = self.title;
	alert.message = [NSString stringWithFormat:@"Cannot open URL (%@).",
					 [error localizedDescription]];
	[alert addButtonWithTitle:@"Dismiss"];
	[alert show];
}


@end
