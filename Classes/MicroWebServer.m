//
//  MicroWebServer.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "MicroWebServer.h"

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <ifaddrs.h>


@interface MicroWebServer ()
- (void)sendOptionalDelegateMessage:(SEL)msg withObject:(id)object;
@end


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
			NSLog(@"WARNING: Unhandled read stream event %d", eventType);
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
			NSLog(@"WARNING: Unhandled write stream event %d", eventType);
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

	MicroWebServer *webServer = (MicroWebServer *)info;
	MicroWebConnection *webConnection;
	
	webConnection = [[MicroWebConnection alloc] initWithServer:webServer
													readStream:readStream 
												   writeStream:writeStream];
	
	[webServer sendOptionalDelegateMessage:@selector(webConnectionWillReceiveRequest:) 
								withObject:webConnection];
	
	CFStreamClientContext context;
	context.version = 0;
	context.info = webConnection;
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


- (CFSocketRef)newSocket {
	
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


- (NSURL *)rootURL {
	if (listenSocket == NULL) return nil;

	struct ifaddrs *ifa = NULL, *ifList, *ifBest = NULL;
	
	int err = getifaddrs(&ifList);
	if (err < 0) return nil;
	
	for (ifa = ifList; ifa != NULL; ifa = ifa->ifa_next) {
		if (ifa->ifa_addr == NULL) continue;
		if (ifa->ifa_addr->sa_family != AF_INET) continue; // skip non-IP4
		ifBest = ifa;
		// Stop searching unless this is just a loopback address
		if (strncmp(ifa->ifa_name, "lo", 2) != 0) break;
	}
	
	NSURL *theURL;
	
	if (ifBest) {
		struct sockaddr_in *address = (struct sockaddr_in *)ifa->ifa_addr;
		char *host = inet_ntoa(address->sin_addr);
		NSString *string = [NSString stringWithFormat:@"http://%s:%d", host, self.port];
		theURL = [NSURL URLWithString:string];
	}
	
	freeifaddrs(ifList);
	
	return theURL;
}


- (void)start {
	NSAssert(delegate != nil, @"must set delegate");
	NSAssert([delegate respondsToSelector:@selector(handleWebConnection:)], @"delegate must implement handleWebConnection:");
	
	if (running) return; // ignore if already running
			
	listenSocket = [self newSocket];
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


#pragma mark NSNetServiceDelegate


- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
	NSLog(@"Did not publish service: %@", errorDict);
}


#pragma mark Private Methods


- (void)sendOptionalDelegateMessage:(SEL)msg withObject:(id)object {
	if ([delegate respondsToSelector:msg]) {
		[delegate performSelector:msg withObject:object];
	}
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
	[httpDateFormatterArray release];
	if (responseData) CFRelease(responseData);
	if (responseMessage) CFRelease(responseMessage);
	CFRelease(requestMessage);
	CFRelease(writeStream);
	CFRelease(readStream);
	[super dealloc];
}


- (NSString *)description {
	if (responseData) {
		return [NSString stringWithFormat:@"MicroWebConnection<%p> (%d/%d response bytes remain)", self, responseBytesRemaining, CFDataGetLength(responseData)];
	} else {
		return [NSString stringWithFormat:@"MicroWebConnection<%p>: reading", self];
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
				NSLog(@"CFHTTPMessageAppendBytes: returned false");
				return YES;
			}
		} else if (dataLength == 0) {
			return YES; // end of stream
		} else {
			NSLog(@"CFReadStreamRead: returned %d", dataLength);
			return YES;
		}
	} while (CFReadStreamHasBytesAvailable(readStream));
	
	return NO;
}


- (BOOL)isRequestComplete {
	if (! CFHTTPMessageIsHeaderComplete(requestMessage)) return NO;
	
//	NSString *transferEncodingStr = [self stringForRequestHeader:@"Transfer-Encoding"];
//	if (transferEncodingStr) {
//		NSLog(@"transfer-encoding: %@", transferEncodingStr);
//	}
	
	NSString *contentLengthStr = [self stringForRequestHeader:@"Content-Length"];
	NSInteger contentLength = [contentLengthStr integerValue];
	if (contentLength > 0) {
		NSData *bodyData = [self requestBodyData];
//		NSLog(@"content length is %d and we got %d", contentLength, [bodyData length]);
		return [bodyData length] >= contentLength;
	}
	
	return YES; // for all we know, anyway
}


- (void)readStreamHasBytesAvailable {
	BOOL shouldClose = [self readAvailableBytes];

	if ([self isRequestComplete]) {
		[webServer sendOptionalDelegateMessage:@selector(webConnectionDidReceiveRequest:) withObject:self];
		[(id)webServer.delegate performSelector:@selector(handleWebConnection:) withObject:self afterDelay:0];
		shouldClose = YES;
	}

	if (shouldClose) {
		CFReadStreamClose(readStream);
	}
}


- (void)writeStreamCanAcceptBytes {
	if (responseBytesRemaining == 0) {
		CFWriteStreamClose(writeStream);
		[webServer sendOptionalDelegateMessage:@selector(webConnectionDidSendResponse:) withObject:self];
		return;
	}
	
	const UInt8 *buffer = CFDataGetBytePtr(responseData);
	CFIndex bufferLength = CFDataGetLength(responseData);
	
	buffer += (bufferLength - responseBytesRemaining);
	CFIndex bytesWritten = CFWriteStreamWrite(writeStream, buffer, responseBytesRemaining);
	if (bytesWritten < 0) {
		NSLog(@"CFWriteStreamWrite: returned %d", bytesWritten);
		return;
	}
	responseBytesRemaining -= bytesWritten;
}


- (NSDateFormatter *)httpDateFormatter {
	// Thanks http://blog.mro.name/2009/08/nsdateformatter-http-header/
	if (httpDateFormatterArray == nil) {
		NSDateFormatter *rfc1123 = [[NSDateFormatter alloc] init];
		rfc1123.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
		rfc1123.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
		rfc1123.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
		
		NSDateFormatter *rfc850 = [[NSDateFormatter alloc] init];
		rfc850.timeZone = rfc1123.timeZone;
		rfc850.locale = rfc1123.locale;
		rfc850.dateFormat = @"EEEE',' dd'-'MMM'-'yy HH':'mm':'ss z";
		
		NSDateFormatter *asctime = [[NSDateFormatter alloc] init];
		asctime.timeZone = rfc1123.timeZone;
		asctime.locale = rfc1123.locale;
		asctime.dateFormat = @"EEE MMM d HH':'mm':'ss yyyy";
		
		httpDateFormatterArray = [[NSArray alloc] initWithObjects:rfc1123, rfc850, asctime, nil];
		
		[rfc1123 release];
		[rfc850 release];
		[asctime release];
	}
	return [httpDateFormatterArray objectAtIndex:0];
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


- (NSString *)stringForRequestHeader:(NSString *)headerName {
	NSString *headerValue = (NSString *)CFHTTPMessageCopyHeaderFieldValue(requestMessage, (CFStringRef)headerName);
	return [headerValue autorelease];
}


- (NSDate *)dateForRequestHeader:(NSString *)headerName {
	NSString *string = [self stringForRequestHeader:headerName];
	if (string == nil) return nil;
	[self httpDateFormatter];
	for (NSDateFormatter *df in httpDateFormatterArray) {
		NSDate *date = [df dateFromString:string];
		if (date) return date;
	}
	return nil;
}


- (NSData *)requestBodyData {
	NSData *data = (NSData *)CFHTTPMessageCopyBody(requestMessage);
	return [data autorelease];
}


- (void)beginResponseWithStatus:(CFIndex)statusCode {
	responseMessage = CFHTTPMessageCreateResponse(kCFAllocatorDefault, statusCode, NULL, kCFHTTPVersion1_1);
}


- (void)setValue:(id)value forResponseHeader:(NSString *)header {
	NSAssert(responseMessage != nil, @"must call beginResponseWithStatus: first");
	NSString *string;
	
	if ([value isKindOfClass:[NSDate class]]) {
		string = [[self httpDateFormatter] stringFromDate:value];
	}
	else {
		string = [value description];
	}
	
	CFHTTPMessageSetHeaderFieldValue(responseMessage, (CFStringRef)header, (CFStringRef)string);
}


- (void)endResponseWithBodyString:(NSString *)string {
	NSAssert(responseMessage != nil, @"must call beginResponseWithStatus: first");
	[self endResponseWithBodyData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}


- (void)endResponseWithBodyData:(NSData *)data {
	NSAssert(responseMessage != nil, @"must call beginResponseWithStatus: first");
	CFHTTPMessageSetBody(responseMessage, (CFDataRef)data);

	NSString *lenstr = [NSString stringWithFormat:@"%d", [data length]];
	CFHTTPMessageSetHeaderFieldValue(responseMessage, CFSTR("Content-Length"), (CFStringRef)lenstr);
	
	// Sorry, we don't support Keep Alive.
	CFHTTPMessageSetHeaderFieldValue(responseMessage, CFSTR("Connection"), CFSTR("close"));
	
	[webServer sendOptionalDelegateMessage:@selector(webConnectionWillSendResponse:) withObject:self];

	responseData = CFHTTPMessageCopySerializedMessage(responseMessage);
	CFRelease(responseMessage); responseMessage = NULL;
	
	responseBytesRemaining = CFDataGetLength(responseData);
	CFWriteStreamOpen(writeStream);
}


- (void)respondWithErrorMessage:(NSString *)message {
	[self beginResponseWithStatus:500];
	[self setValue:@"text/plain; charset=utf-8" forResponseHeader:@"Content-Type"];
	[self endResponseWithBodyString:message];
}


- (void)respondWithRedirectToURL:(NSURL *)url {
	[self beginResponseWithStatus:301];
	[self setValue:[url absoluteString] forResponseHeader:@"Location"];
	[self endResponseWithBodyData:[NSData data]];
}


- (void)respondWithRedirectToPath:(NSString *)path {
	NSURL *rootURL = webServer.rootURL;
	NSAssert(rootURL, @"Must have a root URL");
	NSURL *url = [NSURL URLWithString:path relativeToURL:rootURL];
	[self respondWithRedirectToURL:url];
}


@end
