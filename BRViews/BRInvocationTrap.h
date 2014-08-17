//
//  BRInvocationTrap.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/19/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BRInvocationTrap : NSProxy
+ (id)trapInvocationsForTarget:(id)aTarget forwardingTo:(id)anObject selector:(SEL)aSelector;
@end
