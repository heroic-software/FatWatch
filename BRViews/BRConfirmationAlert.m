/*
 * BRConfirmationAlert.m
 * Created by Benjamin Ragheb on 3/19/10.
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

#import "BRConfirmationAlert.h"
#import "BRInvocationTrap.h"


@interface BRConfirmationAlert ()
- (void)showAlertForInvocation:(NSInvocation *)anInvocation;
@end


@implementation BRConfirmationAlert
{
	UIAlertView *alertView;
	NSInvocation *invocation;
	NSString *buttonTitle;
}

- (id)init {
	if ((self = [super init])) {
		alertView = [[UIAlertView alloc] init];
		alertView.delegate = self;
	}
	return self;
}


- (NSString *)title {
	return alertView.title;
}


- (void)setTitle:(NSString *)title {
	alertView.title = title;
}


- (NSString *)message {
	return alertView.message;
}


- (void)setMessage:(NSString *)message {
	alertView.message = message;
}


@synthesize buttonTitle;


- (id)confirmBeforeSendingMessageTo:(id)target {
	return [BRInvocationTrap trapInvocationsForTarget:target forwardingTo:self selector:@selector(showAlertForInvocation:)];
}


- (void)showAlertForInvocation:(NSInvocation *)anInvocation {
	invocation = anInvocation;
	[invocation retainArguments];
	alertView.cancelButtonIndex = [alertView addButtonWithTitle:@"Cancel"];
	[alertView addButtonWithTitle:self.buttonTitle];
	[alertView show];
}


- (void)alertView:(UIAlertView *)anAlertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex != anAlertView.cancelButtonIndex) {
		[invocation invoke];
	}
}



@end
