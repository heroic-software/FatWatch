/*
 * BRReachability.h
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

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>


@interface BRReachability : NSObject
@property (nonatomic,readonly,getter=isMonitoring) BOOL monitoring;
@property (nonatomic,weak) id delegate;
- (void)startMonitoring;
- (void)stopMonitoring;
@end


@protocol BRReachabilityDelegate
- (void)reachability:(BRReachability *)reachability didUpdateFlags:(SCNetworkReachabilityFlags)flags;
@end
