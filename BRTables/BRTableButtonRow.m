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


@implementation BRTableButtonRow


@synthesize target, action, disabled;


+ (BRTableButtonRow *)rowWithTitle:(NSString *)aTitle target:(id)aTarget action:(SEL)anAction {
	BRTableButtonRow *row = [[BRTableButtonRow alloc] init];
	row.title = aTitle;
	row.target = aTarget;
	row.action = anAction;
	return [row autorelease];
}


- (NSString *)reuseableCellIdentifier {
	return [NSString stringWithFormat:@"BRTableButtonRowCell:%d", self.cellStyle];
}


- (void)configureCell:(UITableViewCell *)cell {
	[super configureCell:cell];
	cell.textLabel.textColor = self.disabled ? [UIColor grayColor] : self.titleColor;
}


- (BOOL)openThing:(id)thing {
	if ([thing isKindOfClass:[NSArray class]]) {
		for (id subthing in thing) {
			if ([self openThing:subthing]) return YES;
		}
	}
	else if ([thing isKindOfClass:[NSURL class]]) {
		UIApplication *app = [UIApplication sharedApplication];
		if ([app canOpenURL:thing]) {
			BRConfirmationAlert *alert = [[BRConfirmationAlert alloc] init];
			alert.title = self.title;
			if ([[thing scheme] isEqualToString:@"mailto"]) {
				alert.message = @"Would you like to open Mail?";
				alert.buttonTitle = @"Open Mail";
			} else if ([[thing host] isEqualToString:@"itunes.apple.com"]) {
				alert.message = @"Would you like to open in iTunes?";
				alert.buttonTitle = @"Open iTunes";
			} else if ([[thing scheme] isEqualToString:@"http"]) {
				alert.message = @"Would you like to open this website?";
				alert.buttonTitle = @"Open Website";
			} else {
				alert.message = @"Would you like to open this link?";
				alert.buttonTitle = @"Open";
			}
			[[alert confirmBeforeSendingMessageTo:app] openURL:thing];
			[alert release];
			return YES;
		}
	}
	else if ([thing isKindOfClass:[UIViewController class]]) {
		[self.section.controller presentViewController:thing forRow:self];
		return YES;
	}
	return NO;
}


- (void)didSelect {
	[self deselectAnimated:YES];
	if (disabled) return;
	if (self.target) {
		[self.target performSelector:self.action withObject:self];
	} else {
		[self openThing:self.object];
	}
}


@end
