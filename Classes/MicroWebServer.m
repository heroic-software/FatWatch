//
//  MicroWebServer.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "MicroWebServer.h"

#import <SystemConfiguration/SystemConfiguration.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <ifaddrs.h>


@interface MicroWebConnection ()
- (id)initWithServer:(MicroWebServer *)server readStream:(CFReadStreamRef)readStream writeStream:(CFWriteStreamRef)writeStream;
- (void)readStreamHasBytesAvailable;
- (void)writeStreamCanAcceptBytes;
@end


void MicroReadStreamCallback(CFReadStreamRef stream, CFStreamEventType eventType, void *info) {
	MicroWebConnection *connection = (MicroWebConnection *)info;
	switch (eventType) {
		case kCFStreamEventHasBytesAvailable:
			[connection readStreamHasBytesAvailable];
			break;
		default:
			NSLog(@"unhandled read stream event %d", eventType);
			break;
	}
}


void MicroWriteStreamCallback(CFWriteStreamRef stream, CFStreamEventType eventType, void *info) {
	MicroWebConnection *connection = (MicroWebConnection *)info;
	switch (eventType) {
		case kCFStreamEventCanAcceptBytes:
			[connection writeStreamCanAcceptBytes];
			break;
		default:
			NSLog(@"unhandled write stream event %d", eventType);
			break;
	}
}


void MicroSocketCallback(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info) {
	if (callbackType != kCFSocketAcceptCallBack) return;
	
	CFSocketNativeHandle *nativeHandle = (CFSocketNativeHandle *)data;
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	CFStreamCreatePairWithSocket(kCFAllocatorDefault, *nativeHandle, &readStream, &writeStream);
	CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
	CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);

	MicroWebConnection *connection = [[MicroWebConnection alloc] initWithServer:(MicroWebServer *)info
																	 readStream:readStream 
																	writeStream:writeStream];
	
	CFStreamClientContext context;
	context.version = 0;
	context.info = connection;
	context.retain = NULL;
	context.release = NULL;
	context.copyDescription = NULL;
	
	CFReadStreamSetClient(readStream, 
						  kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred,
						  &MicroReadStreamCallback,
						  &context);
	
	CFWriteStreamSetClient(writeStream,
						   kCFStreamEventCanAcceptBytes | kCFStreamEventErrorOccurred,
						   &MicroWriteStreamCallback, 
						   &context);

	CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
	CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);

	CFReadStreamOpen(readStream);
}


@implementation MicroWebServer


@synthesize delegate;
@synthesize name;
@synthesize running;


- (CFSocketRef)createSocket {
	
	CFSocketContext context;
	context.version = 0;
	context.info = self;
	context.retain = NULL;
	context.release = NULL;
	context.copyDescription = NULL;
	
	CFSocketRef socket = CFSocketCreate(kCFAllocatorDefault, 
										PF_INET, 
										SOCK_STREAM, 
										IPPROTO_TCP, 
										kCFSocketAcceptCallBack, 
										&MicroSocketCallback,
										&context);
	if (socket == NULL) return NULL;
	
	CFRunLoopSourceRef runLoopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socket, 0);
	if (runLoopSource == NULL) {
		CFRelease(socket);
		return NULL;
	}
	CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
	CFRelease(runLoopSource);
	
	struct sockaddr_in addr4;
	memset(&addr4, 0, sizeof(addr4));
	addr4.sin_len = sizeof(addr4);
	addr4.sin_family = AF_INET;
	addr4.sin_port = htons(INADDR_ANY);
	addr4.sin_addr.s_addr = htonl(INADDR_ANY);
	
	// Wrap the native address structure for CFSocketCreate.
	CFDataRef addressData = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8*)&addr4, sizeof(addr4), kCFAllocatorNull);
	if (addressData == NULL) {
		CFRelease(socket);
		return NULL;
	}
	
	CFSocketError err;
	
	// Set the local binding which causes the socket to start listening.
	err = CFSocketSetAddress(socket, addressData);
	CFRelease(addressData);
	if (err != kCFSocketSuccess) {
		CFRelease(socket);
		return NULL;
	}
	
	return socket;
}


- (UInt16)port {
	if (listenSocket == NULL) return 0;
	struct sockaddr_in address;
	CFDataRef addressData = CFSocketCopyAddress(listenSocket);
	CFDataGetBytes(addressData, CFRangeMake(0, sizeof(address)), (UInt8 *)&address);
	CFRelease(addressData);
	return ntohs(address.sin_port);
}


- (NSURL *)url {
	if (listenSocket == NULL) return nil;

	int err;
	struct ifaddrs *ifa = NULL, *ifp;
	
	err = getifaddrs(&ifp);
	if (err < 0) return nil;
	
	for (ifa = ifp; ifa != NULL; ifa = ifa->ifa_next) {
		if (ifa->ifa_addr == NULL) continue;
		if (ifa->ifa_addr->sa_family != AF_INET) continue; // skip non-IP4
		if (strncmp(ifa->ifa_name, "lo", 2) == 0) continue; // skip loopback addresses
		struct sockaddr_in *address = (struct sockaddr_in *)ifa->ifa_addr;
		char *host = inet_ntoa(address->sin_addr);
		freeifaddrs(ifp);
		return [NSURL URLWithString:[NSString stringWithFormat:@"http://%s:%d", host, self.port]];
	}

	freeifaddrs(ifp);
	return nil;
}


- (BOOL)isWiFiAvailable {
	// Can we reach 0.0.0.0?
	struct sockaddr_in zeroAddress;
	SCNetworkReachabilityRef defaultRouteReachability;
	SCNetworkReachabilityFlags flags;
	
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
	BOOL gotFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	CFRelease(defaultRouteReachability);
	
	if (! gotFlags) return NO;

	NSLog(@"SCNetworkReachabilityFlags = 0x%08x", flags);
	
	// If we're using the cell network, then there's no point starting a server.
	if (flags & kSCNetworkReachabilityFlagsIsWWAN) return NO;
	
	// Can we get on the network at all.
	return (flags & kSCNetworkReachabilityFlagsReachable);
}


- (void)start {
	NSAssert(delegate != nil, @"must set delegate");
	NSAssert([delegate respondsToSelector:@selector(handleWebConnection:)], @"delegate must implement handleWebConnection:");
	
	if (running) return; // ignore if already running
	
	if (! [self isWiFiAvailable]) return;
		
	listenSocket = [self createSocket];
	if (listenSocket == NULL) return;

	running = YES;
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MWSPublishNetService"]) {
		netService = [[NSNetService alloc] initWithDomain:@"" 
													 type:@"_http._tcp."
													 name:self.name
													 port:self.port];
		[netService setDelegate:self];
		[netService publish];
	}
}


- (void)stop {
	if (!running) return; // ignore if already stopped
	[netService stop];
	[netService release];
	netService = nil;
	if (listenSocket != NULL) {
		CFSocketInvalidate(listenSocket);
		CFRelease(listenSocket);
		listenSocket = NULL;
	}
	running = NO;
}


- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
	NSLog(@"Didn't publish: %@", errorDict);
}


- (void)netServiceDidPublish:(NSNetService *)sender {
	NSLog(@"Published on port %d", [sender port]);
}


@end


@implementation MicroWebConnection


- (id)initWithServer:(MicroWebServer *)server readStream:(CFReadStreamRef)newReadStream writeStream:(CFWriteStreamRef)newWriteStream {
	if ([super init]) {
		webServer = server;
		readStream = newReadStream;
		writeStream = newWriteStream;
		requestMessage = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, YES);
	}
	return self;
}


- (void)dealloc {
	if (responseData) CFRelease(responseData);
	if (responseMessage) CFRelease(responseMessage);
	CFRelease(requestMessage);
	CFRelease(writeStream);
	CFRelease(readStream);
	[super dealloc];
}


- (NSString *)description {
	if (responseData) {
		return [NSString stringWithFormat:@"MicroWebConnection: %d/%d response bytes remain", 
				responseBytesRemaining, CFDataGetLength(responseData)];
	} else {
		return [NSString stringWithFormat:@"MicroWebConnection: reading"];
	}
}


- (BOOL)readAvailableBytes {
	const CFIndex bufferCapacity = 512;
	UInt8 buffer[bufferCapacity];

	do {
		CFIndex dataLength = CFReadStreamRead(readStream, buffer, bufferCapacity);
		
		if (dataLength > 0) {
			Boolean didSucceed = CFHTTPMessageAppendBytes(requestMessage, buffer, dataLength);
			if (! didSucceed) {
				NSLog(@"error appending bytes");
				return YES;
			}
		} else if (dataLength == 0) {
			NSLog(@"end of read stream");
			return YES;
		} else {
			NSLog(@"error");
			return YES;
		}
	} while (CFReadStreamHasBytesAvailable(readStream));
	
	return NO;
}


- (BOOL)isRequestComplete {
	if (! CFHTTPMessageIsHeaderComplete(requestMessage)) return NO;
	
//	NSString *transferEncodingStr = [self requestHeaderValueForName:@"Transfer-Encoding"];
//	if (transferEncodingStr) {
//		printf("transfer-encoding: %s\n", [transferEncodingStr UTF8String]);
//	}
	
	NSString *contentLengthStr = [self requestHeaderValueForName:@"Content-Length"];
	NSInteger contentLength = [contentLengthStr integerValue];
	if (contentLength > 0) {
		NSData *bodyData = [self requestBodyData];
//		printf("content length is %d and we got %d\n", contentLength, [bodyData length]);
		return [bodyData length] >= contentLength;
	}
	
	return YES; // for all we know, anyway
}


- (void)readStreamHasBytesAvailable {
	BOOL shouldClose = [self readAvailableBytes];

	if ([self isRequestComplete]) {
		[[webServer delegate] handleWebConnection:self];
		NSAssert(responseMessage != nil, @"delegate must call setResponseStatus:");
		CFHTTPMessageSetHeaderFieldValue(responseMessage, CFSTR("Connection"), CFSTR("close"));
		
		responseData = CFHTTPMessageCopySerializedMessage(responseMessage);
		CFRelease(responseMessage); responseMessage = NULL;
		
		responseBytesRemaining = CFDataGetLength(responseData);
		CFWriteStreamOpen(writeStream);
		shouldClose = YES;
	}

	if (shouldClose) {
		CFReadStreamClose(readStream);
	}
}


- (void)writeStreamCanAcceptBytes {
	if (responseBytesRemaining == 0) {
		CFWriteStreamClose(writeStream);
		return;
	}
	
	const UInt8 *buffer = CFDataGetBytePtr(responseData);
	CFIndex bufferLength = CFDataGetLength(responseData);
	
	buffer += (bufferLength - responseBytesRemaining);
	CFIndex bytesWritten = CFWriteStreamWrite(writeStream, buffer, responseBytesRemaining);
	if (bytesWritten == -1) {
		NSLog(@"error");
		return;
	}
	responseBytesRemaining -= bytesWritten;
}


- (NSString *)requestMethod {
	NSString *method = (NSString *)CFHTTPMessageCopyRequestMethod(requestMessage);
	return [method autorelease];
}


- (NSURL *)requestURL {
	NSURL *url = (NSURL *)CFHTTPMessageCopyRequestURL(requestMessage);
	return [url autorelease];
}


- (NSDictionary *)requestHeaders {
	NSDictionary *headers = (NSDictionary *)CFHTTPMessageCopyAllHeaderFields(requestMessage);
	return [headers autorelease];
}


- (NSString *)requestHeaderValueForName:(NSString *)headerName {
	NSString *headerValue = (NSString *)CFHTTPMessageCopyHeaderFieldValue(requestMessage, (CFStringRef)headerName);
	return [headerValue autorelease];
}


- (NSData *)requestBodyData {
	NSData *data = (NSData *)CFHTTPMessageCopyBody(requestMessage);
	return [data autorelease];
}


- (void)setResponseStatus:(CFIndex)statusCode {
	responseMessage = CFHTTPMessageCreateResponse(kCFAllocatorDefault, statusCode, NULL, kCFHTTPVersion1_1);
}


- (void)setValue:(NSString *)value forResponseHeader:(NSString *)header {
	NSAssert(responseMessage != nil, @"must set response status first");
	CFHTTPMessageSetHeaderFieldValue(responseMessage, (CFStringRef)header, (CFStringRef)value);
}


- (void)setResponseBodyString:(NSString *)string {
	NSAssert(responseMessage != nil, @"must set response status first");
	[self setResponseBodyData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}


- (void)setResponseBodyData:(NSData *)data {
	NSAssert(responseMessage != nil, @"must set response status first");
	CFHTTPMessageSetBody(responseMessage, (CFDataRef)data);
	[self setValue:[NSString stringWithFormat:@"%d", [data length]] forResponseHeader:@"Content-Length"];
}

@end
