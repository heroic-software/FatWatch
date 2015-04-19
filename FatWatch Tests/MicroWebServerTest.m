/*
 * MicroWebServerTest.m
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
#import "MicroWebServer.h"

@interface WebServerTestDelegate : NSObject <MicroWebServerDelegate>
- (void)handleWebConnection:(MicroWebConnection *)connection;
@end

@interface MicroWebConnection (PrivateMethods)
- (id)initWithServer:(MicroWebServer *)server readStream:(CFReadStreamRef)readStream writeStream:(CFWriteStreamRef)writeStream;
- (void)readStreamHasBytesAvailable;
- (void)writeStreamCanAcceptBytes;
@end


int main(int argc, char *argv[])
{
	MicroWebServer *server = [[MicroWebServer alloc] init];
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

    return 0;
}


@implementation WebServerTestDelegate

- (void)handleWebConnection:(MicroWebConnection *)connection {
	[connection beginResponseWithStatus:200];
	[connection setValue:@"text/plain" forResponseHeader:@"Content-Type"];
	[connection endResponseWithBodyString:@"Hello, world."];
	NSLog(@"Got a request for <%@>", [connection requestURL]);
}

@end
