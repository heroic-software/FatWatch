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
	[delegate performSelector:action withObject:anInvocation];
}




@end
