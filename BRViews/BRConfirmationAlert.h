//
//  BRConfirmationAlert.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/19/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BRConfirmationAlert : NSObject <UIAlertViewDelegate> {
	UIAlertView *alertView;
	NSInvocation *invocation;
	NSString *buttonTitle;
}
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *message;
@property (nonatomic,copy) NSString *buttonTitle;
- (id)confirmBeforeSendingMessageTo:(id)target;
@end
