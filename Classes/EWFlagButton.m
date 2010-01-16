//
//  EWFlagButton.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/15/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "EWFlagButton.h"
#import "BRColorPalette.h"
#import "NSUserDefaults+EWAdditions.h"


static inline CGRect BRRectOfSizeCenteredInRect(CGSize size, CGRect rect) {
	return CGRectMake(CGRectGetMidX(rect) - 0.5f * size.width,
					  CGRectGetMidY(rect) - 0.5f * size.height,
					  size.width, 
					  size.height);
}


@implementation EWFlagButton


- (void)awakeFromNib {
	if (self.tag > 0) {
		[self configureForFlagIndex:(self.tag % 10)];
	}
}


- (UIImage *)backgroundImageWithColor:(UIColor *)color icon:(UIImage *)iconImage {
	CGRect bounds = self.bounds;
	UIGraphicsBeginImageContext(bounds.size);
	[color setFill];
	UIRectFill(bounds);
	[[UIColor blackColor] setStroke];
	UIRectFrame(bounds);
	if (iconImage) {
		CGRect iconRect = BRRectOfSizeCenteredInRect(iconImage.size, bounds);
		[iconImage drawInRect:iconRect blendMode:kCGBlendModeCopy alpha:0.5];
	}
	UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return backgroundImage;
}


- (CGImageRef)newMaskFromImage:(UIImage *)image {
	CGRect bounds = self.bounds;
	CGRect iconRect = BRRectOfSizeCenteredInRect(image.size, bounds);
	size_t width = bounds.size.width;
	size_t height = bounds.size.height;
	size_t bitsPerComponent = 8;
	size_t bytesPerRow = width;
	CGColorSpaceRef graySpace = CGColorSpaceCreateDeviceGray();
	CGContextRef context = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, graySpace, kCGImageAlphaNone);
	
	CGContextSetGrayFillColor(context, 1, 1);
	CGContextFillRect(context, bounds);
	CGContextDrawImage(context, iconRect, [image CGImage]);
	
	CGImageRef maskImageRef = CGBitmapContextCreateImage(context);
	
	CGContextRelease(context);
	CGColorSpaceRelease(graySpace);
	
	return maskImageRef;
}


- (UIImage *)iconImageForIndex:(int)flagIndex {
	if ([[NSUserDefaults standardUserDefaults] isNumericFlag:flagIndex]) return nil;
	NSString *key = [NSString stringWithFormat:@"Flag%dImage", flagIndex];
	NSString *iconName = [[NSUserDefaults standardUserDefaults] stringForKey:key];
	NSString *iconPath = [[NSBundle mainBundle] pathForResource:iconName 
														 ofType:@"png"
													inDirectory:@"MarkIcons"];
	return [[[UIImage alloc] initWithContentsOfFile:iconPath] autorelease];
}


- (void)configureForFlagIndex:(int)flagIndex {
	self.backgroundColor = [UIColor whiteColor];
	
	NSString *colorName = [NSString stringWithFormat:@"Flag%d", flagIndex];
	UIColor *color = [[BRColorPalette sharedPalette] colorNamed:colorName];

	UIImage *iconImage = [self iconImageForIndex:flagIndex];
		
	UIImage *normalImage = [self backgroundImageWithColor:[UIColor whiteColor] icon:iconImage];
	[self setBackgroundImage:normalImage forState:UIControlStateNormal];

	UIImage *backgroundImage = [self backgroundImageWithColor:color icon:nil];
	if (iconImage) {
		CGImageRef maskImageRef = [self newMaskFromImage:iconImage];
		CGImageRef selectedImageRef = CGImageCreateWithMask([backgroundImage CGImage], maskImageRef);
		[self setBackgroundImage:[UIImage imageWithCGImage:selectedImageRef] forState:UIControlStateSelected];
		CGImageRelease(selectedImageRef);
		CGImageRelease(maskImageRef);
	} else {
		[self setBackgroundImage:backgroundImage forState:UIControlStateSelected];
	}
}

@end
