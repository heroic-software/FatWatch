#!/usr/bin/python
from Quartz import *
import math

imageWidth = 42
imageHeight = 42

def create(imageName,t,rgb):
	cs = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGB )
	c = CGBitmapContextCreate(None, imageWidth, imageHeight, 8, imageWidth*4, cs, kCGImageAlphaPremultipliedLast )
	rect = CGRectMake(0,0,imageWidth,imageHeight)

	# Color Border
	if (t > 0):
		# Color Background
		CGContextSetRGBFillColor(c,rgb[0],rgb[1],rgb[2],1)
		CGContextFillRect(c, rect)
	else:
		# White Background
		CGContextSetRGBFillColor(c,1,1,1,1)
		CGContextFillRect(c, rect)
		# Color Border
		CGContextSetLineWidth(c, 2)
		CGContextSetRGBStrokeColor(c,rgb[0],rgb[1],rgb[2],1)
		CGContextStrokeRect(c, CGRectInset(rect, 2, 2))

	# Black Border
	CGContextSetRGBStrokeColor(c,0,0,0,1)
	CGContextSetLineWidth(c,1)
	CGContextStrokeRect(c, CGRectInset(rect,0.5,0.5))

	print "Writing " + imageName
	img = CGBitmapContextCreateImage(c);
	url = CFURLCreateWithFileSystemPath(None, imageName, kCFURLPOSIXPathStyle, False)
	dest = CGImageDestinationCreateWithURL(url, "public.png", 1, None)
	CGImageDestinationAddImage(dest, img, None)
	CGImageDestinationFinalize(dest)


colors = [
	(0.404,0.164,0.159),
	(0.176,0.250,0.438),
	(0.237,0.436,0.166),
	(0.441,0.422,0.173)
];
for i in range(4):
	create("Flag" + str(i+1) + "Button0.png", 0, colors[i]);
	create("Flag" + str(i+1) + "Button1.png", 1, colors[i]);
