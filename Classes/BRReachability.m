//
//  BRReachability.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 6/21/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "BRReachability.h"

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <ifaddrs.h>


void BRReachabilityCallback(SCNetworkReachabilityRef target,
							SCNetworkReachabilityFlags flags,
							void *info) {
	BRReachability *reachability = (__bridge BRReachability *)info;
	[reachability.delegate reachability:reachability didUpdateFlags:flags];
}


@implementation BRReachability


@synthesize monitoring;
@synthesize delegate;


- (id)init {
	if ((self = [super init])) {
		struct sockaddr_in zeroAddress;

		bzero(&zeroAddress, sizeof(zeroAddress));
		zeroAddress.sin_len = sizeof(zeroAddress);
		zeroAddress.sin_family = AF_INET;

		reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (struct sockaddr *)&zeroAddress);
		
		SCNetworkReachabilityContext context;
		bzero(&context, sizeof(SCNetworkReachabilityContext));
		context.version = 0;
		context.info = (__bridge void *)(self);
		SCNetworkReachabilitySetCallback(reachabilityRef, BRReachabilityCallback, &context);
	}
	return self;
}


- (void)dealloc {
	[self stopMonitoring];
	CFRelease(reachabilityRef);
}


- (void)startMonitoring {
	if (monitoring) return;
	SCNetworkReachabilityFlags flags;
	
	SCNetworkReachabilityGetFlags(reachabilityRef, &flags);
	BRReachabilityCallback(reachabilityRef, flags, (__bridge void *)(self));
	
	monitoring = SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef,
														  CFRunLoopGetCurrent(), 
														  kCFRunLoopDefaultMode);
}


- (void)stopMonitoring {
	if (!monitoring) return;
	monitoring = !SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, 
															 CFRunLoopGetCurrent(), 
															 kCFRunLoopDefaultMode);
}


@end
