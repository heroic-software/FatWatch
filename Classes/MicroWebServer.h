//
//  MicroWebServer.h
//
//  Created by Benjamin Ragheb on 4/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <CFNetwork/CFNetwork.h>
#endif

@protocol MicroWebServerDelegate;

@interface MicroWebServer : NSObject <NSNetServiceDelegate> {
	NSString *name;
	CFSocketRef listenSocket;
	NSNetService *netService;
	id <MicroWebServerDelegate> __weak delegate;
	BOOL running;
}
@property (nonatomic,strong) NSString *name;
@property (nonatomic,weak) id <MicroWebServerDelegate> delegate;
@property (nonatomic,readonly,getter=isRunning) BOOL running;
@property (nonatomic,readonly) UInt16 port;
@property (weak, nonatomic,readonly) NSURL *rootURL;
- (void)start;
- (void)stop;
@end


@interface MicroWebConnection : NSObject {
	MicroWebServer *webServer;
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	CFHTTPMessageRef requestMessage;
	CFHTTPMessageRef responseMessage;
	CFDataRef responseData;
	CFIndex responseBytesRemaining;
	NSArray *httpDateFormatterArray;
}
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
