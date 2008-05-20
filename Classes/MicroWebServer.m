//
//  MicroWebServer.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "MicroWebServer.h"

#if TARGET_OS_IPHONE
#import <CFNetwork/CFNetwork.h>
#endif

#include <sys/socket.h>
#include <netinet/in.h>


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
			printf("unhandled read stream event %d\n", eventType);
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
			printf("unhandled write stream event %d\n", eventType);
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


+ (MicroWebServer *)sharedServer {
	static MicroWebServer *instance = nil;
	if (instance == nil) {
		instance = [[MicroWebServer alloc] init];
	}
	return instance;
}


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


- (UInt16)portFromSocket:(CFSocketRef)socket {
	struct sockaddr_in address;
	CFDataRef addressData = CFSocketCopyAddress(socket);
	CFDataGetBytes(addressData, CFRangeMake(0, sizeof(address)), (UInt8 *)&address);
	CFRelease(addressData);
	return ntohs(address.sin_port);
}


- (void)start {
	NSAssert(delegate != nil, @"must set delegate");
	NSAssert([delegate respondsToSelector:@selector(handleWebConnection:)], @"delegate must implement handleWebConnection:");
	
	listenSocket = [self createSocket];
	if (listenSocket == NULL) {
		printf("Failed to create socket!\n");
		return;
	}
	netService = [[NSNetService alloc] initWithDomain:@"" 
												 type:@"_http._tcp."
												 name:self.name
												 port:[self portFromSocket:listenSocket]];
	[netService setDelegate:self];
	[netService publish];
}


- (void)stop {
	[netService stop];
	[netService release];
	CFSocketInvalidate(listenSocket);
	CFRelease(listenSocket);
}


- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
	printf("did not publish!\n");
}


- (void)netServiceDidPublish:(NSNetService *)sender {
	printf("did publish on port %d!\n", [sender port]);
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
				printf("error appending bytes\n");
				return YES;
			}
		} else if (dataLength == 0) {
			printf("end of read stream\n");
			return YES;
		} else {
			printf("error\n");
			return YES;
		}
	} while (CFReadStreamHasBytesAvailable(readStream));
	
	return NO;
}


- (BOOL)isRequestComplete {
	if (! CFHTTPMessageIsHeaderComplete(requestMessage)) return NO;
	
	NSString *transferEncodingStr = [self requestHeaderValueForName:@"Transfer-Encoding"];
	if (transferEncodingStr) {
		printf("transfer-encoding: %s\n", [transferEncodingStr UTF8String]);
	}
	
	NSString *contentLengthStr = [self requestHeaderValueForName:@"Content-Length"];
	NSInteger contentLength = [contentLengthStr integerValue];
	if (contentLength > 0) {
		NSData *bodyData = [self requestBodyData];
		printf("content length is %d and we got %d\n", contentLength, [bodyData length]);
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
		printf("error\n");
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
