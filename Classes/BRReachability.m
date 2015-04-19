/*
 * BRReachability.m
 * Created by Benjamin Ragheb on 6/21/09.
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
{
	SCNetworkReachabilityRef reachabilityRef;
	BOOL monitoring;
	id __weak delegate;
}

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
