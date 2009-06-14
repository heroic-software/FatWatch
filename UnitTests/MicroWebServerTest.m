#import <Foundation/Foundation.h>
#import "MicroWebServer.h"

@interface WebServerTestDelegate : NSObject
{
}
- (void)handleWebConnection:(MicroWebConnection *)connection;
@end

@interface MicroWebConnection (PrivateMethods)
- (id)initWithServer:(MicroWebServer *)server readStream:(CFReadStreamRef)readStream writeStream:(CFWriteStreamRef)writeStream;
- (void)readStreamHasBytesAvailable;
- (void)writeStreamCanAcceptBytes;
@end


int main(int argc, char *argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	MicroWebServer *server = [MicroWebServer sharedServer];
	[server setName:@"WebServerTest"];
	[server setDelegate:[[WebServerTestDelegate alloc] init]];

	/*
	 [server start];
	 */
		
	const char *requestPath = "/Users/benzado/Projects/iPhone/EatWatch/MicroWebServerTest/1070281221.txt";
	CFURLRef fakeRequestURL = CFURLCreateFromFileSystemRepresentation(kCFAllocatorDefault, (UInt8 *)requestPath, strlen(requestPath), false);
	CFReadStreamRef readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, fakeRequestURL);
	CFRelease(fakeRequestURL);
	
	const char *responsePath = "/Users/benzado/Projects/iPhone/EatWatch/MicroWebServerTest/response.txt";
	CFURLRef fakeResponseURL = CFURLCreateFromFileSystemRepresentation(kCFAllocatorDefault, (UInt8 *)responsePath, strlen(responsePath), false);
	CFWriteStreamRef writeStream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, fakeResponseURL);
	CFRelease(fakeResponseURL);
	
	MicroWebConnection *fakeConnection = [[MicroWebConnection alloc] initWithServer:server readStream:readStream writeStream:writeStream];

	CFReadStreamOpen(readStream);

	do {
		NSLog(@"Reading %@ ...", fakeConnection);
		[fakeConnection readStreamHasBytesAvailable];
	} while (CFReadStreamGetStatus(readStream) < kCFStreamStatusClosed);

	do {
		NSLog(@"Writing %@ ...", fakeConnection);
		[fakeConnection writeStreamCanAcceptBytes];
	} while (CFWriteStreamGetStatus(writeStream) < kCFStreamStatusClosed);

	[fakeConnection release];
	
    [pool release];
    return 0;
}


@implementation WebServerTestDelegate

- (void)handleWebConnection:(MicroWebConnection *)connection {
	[connection setResponseStatus:200];
	[connection setValue:@"text/plain" forResponseHeader:@"Content-Type"];
	[connection setResponseBodyString:@"Hello, world."];
	NSLog(@"Got a request for <%@>", [connection requestURL]);
	NSLog(@"Request: %@", [connection parseRequest]);
}

@end
