//
//  BRConfirmationAlert.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/19/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "BRConfirmationAlert.h"
#import "BRInvocationTrap.h"


@interface BRConfirmationAlert ()
- (void)showAlertForInvocation:(NSInvocation *)anInvocation;
@end


@implementation BRConfirmationAlert

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
	[self retain];
	invocation = [anInvocation retain];
	[invocation retainArguments];
	alertView.cancelButtonIndex = [alertView addButtonWithTitle:@"Cancel"];
	[alertView addButtonWithTitle:self.buttonTitle];
	[alertView show];
}


- (void)alertView:(UIAlertView *)anAlertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex != anAlertView.cancelButtonIndex) {
		[invocation invoke];
	}
	[self autorelease];
}


- (void)dealloc {
	[alertView release];
	[invocation release];
	[super dealloc];
}

@end
