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

@interface MicroWebServer : NSObject {
	NSString *name;
	CFSocketRef listenSocket;
	NSNetService *netService;
	id <MicroWebServerDelegate> delegate;
}
@property (nonatomic,retain) NSString *name;
@property (nonatomic,assign) id <MicroWebServerDelegate> delegate;
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
}
- (NSString *)requestMethod;
- (NSURL *)requestURL;
- (NSDictionary *)requestHeaders;
- (NSString *)requestHeaderValueForName:(NSString *)headerName;
- (NSData *)requestBodyData;
- (void)setResponseStatus:(CFIndex)statusCode;
- (void)setValue:(NSString *)value forResponseHeader:(NSString *)header;
- (void)setResponseBodyString:(NSString *)string;
- (void)setResponseBodyData:(NSData *)data;
@end


@protocol MicroWebServerDelegate <NSObject>
@required
- (void)handleWebConnection:(MicroWebConnection *)connection;
@end
