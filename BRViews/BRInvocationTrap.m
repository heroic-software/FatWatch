/*
 * BRInvocationTrap.m
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
