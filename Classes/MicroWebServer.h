/*
 * MicroWebServer.h
 * Created by Benjamin Ragheb on 4/29/08.
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

@protocol MicroWebServerDelegate;

@interface MicroWebServer : NSObject <NSNetServiceDelegate>
@property (nonatomic,strong) NSString *name;
@property (nonatomic,weak) id <MicroWebServerDelegate> delegate;
@property (nonatomic,readonly,getter=isRunning) BOOL running;
@property (nonatomic,readonly) UInt16 port;
@property (weak, nonatomic,readonly) NSURL *rootURL;
- (void)start;
- (void)stop;
@end


@interface MicroWebConnection : NSObject
- (NSDateFormatter *)httpDateFormatter;
- (NSString *)requestMethod;
- (NSURL *)requestURL;
- (NSDictionary *)requestHeaders;
- (NSString *)stringForRequestHeader:(NSString *)headerName;
- (NSDate *)dateForRequestHeader:(NSString *)headerName;
- (NSData *)requestBodyData;
- (void)beginResponseWithStatus:(CFIndex)statusCode;
- (void)setValue:(id)value forResponseHeader:(NSString *)header;
- (void)endResponseWithBodyString:(NSString *)string;
- (void)endResponseWithBodyData:(NSData *)data;
- (void)respondWithErrorMessage:(NSString *)message;
- (void)respondWithRedirectToURL:(NSURL *)url;
- (void)respondWithRedirectToPath:(NSString *)path;
@end


@protocol MicroWebServerDelegate <NSObject>
@required
- (void)handleWebConnection:(MicroWebConnection *)connection;
@optional
- (void)webConnectionWillReceiveRequest:(MicroWebConnection *)connection;
- (void)webConnectionDidReceiveRequest:(MicroWebConnection *)connection;
- (void)webConnectionWillSendResponse:(MicroWebConnection *)connection;
- (void)webConnectionDidSendResponse:(MicroWebConnection *)connection;
@end
