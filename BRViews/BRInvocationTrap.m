//
//  BRInvocationTrap.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/19/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "BRInvocationTrap.h"


@interface BRInvocationTrap ()
- (id)initWithTarget:(id)aTarget delegate:(id)aDelegate selector:(SEL)aSelector;
@end


@implementation BRInvocationTrap
{
	id target;
	id delegate;
	SEL action;
}


+ (id)trapInvocationsForTarget:(id)aTarget forwardingTo:(id)anObject selector:(SEL)aSelector {
	return [[BRInvocationTrap alloc] initWithTarget:aTarget delegate:anObject selector:aSelector];
}


- (id)initWithTarget:(id)aTarget delegate:(id)aDelegate selector:(SEL)aSelector {
	NSParameterAssert(aTarget);
	NSParameterAssert(aDelegate);
	NSParameterAssert(aSelector);
	target = aTarget;
	delegate = aDelegate;
	action = aSelector;
	return self;
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	return [target methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	[anInvocation setTarget:target];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[delegate performSelector:action withObject:anInvocation];
#pragma clang diagnostic pop
}

@end
