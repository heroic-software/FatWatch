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


static NSString * const EWFlagButtonIconDidChangeNotification = @"EWFlagButtonIconDidChange";


static inline CGRect BRRectOfSizeCenteredInRect(CGSize size, CGRect rect) {
	return CGRectMake(roundf(CGRectGetMidX(rect) - 0.5f * size.width),
					  roundf(CGRectGetMidY(rect) - 0.5f * size.height),
					  size.width, 
					  size.height);
}


@implementation EWFlagButton


+ (void)updateIconName:(NSString *)name forFlagIndex:(int)flagIndex {
	if (name) {
		NSString *key = [NSString stringWithFormat:@"Flag%dImage", flagIndex];
		[[NSUserDefaults standardUserDefaults] setObject:name forKey:key];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:EWFlagButtonIconDidChangeNotification object:[NSNumber numberWithInt:flagIndex]];
}


+ (NSString *)iconNameForFlagIndex:(int)flagIndex {
	if ([[NSUserDefaults standardUserDefaults] isNumericFlag:flagIndex]) {
		return @"300-ladder";
	}
	NSString *key = [NSString stringWithFormat:@"Flag%dImage", flagIndex];
	return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}


- (void)awakeFromNib {
	if (self.tag > 0) {
		int flagIndex = self.tag % 10;
		[self configureForFlagIndex:flagIndex];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flagIconDidChange:) name:EWFlagButtonIconDidChangeNotification object:[NSNumber numberWithInt:flagIndex]];
		self.backgroundColor = [UIColor whiteColor];
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


- (UIImage *)iconImageForFlagIndex:(int)flagIndex {
	NSString *iconName = [EWFlagButton iconNameForFlagIndex:flagIndex];
	NSString *iconPath = [[NSBundle mainBundle] pathForResource:iconName 
														 ofType:@"png"
													inDirectory:@"FlagIcons"];
	return [[[UIImage alloc] initWithContentsOfFile:iconPath] autorelease];
}


- (void)configureForFlagIndex:(int)flagIndex {
	NSString *colorName = [NSString stringWithFormat:@"Flag%d", flagIndex];
	UIColor *color = [[BRColorPalette sharedPalette] colorNamed:colorName];
	
	UIImage *iconImage;
	
	if ([[self titleForState:UIControlStateNormal] length] > 0) {
		iconImage = nil;
	} else {
		iconImage = [self iconImageForFlagIndex:flagIndex];
	}

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


- (void)setTitle:(NSString *)title forState:(UIControlState)state {
	NSString *oldTitle = [self titleForState:state];
	[super setTitle:title forState:state];
	if (([oldTitle length] > 0) != ([title length] > 0)) {
		[self configureForFlagIndex:(self.tag % 10)];
	}
}


- (void)flagIconDidChange:(NSNotification *)notification {
	[self configureForFlagIndex:[[notification object] intValue]];
}


#pragma mark Cleanup


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


@end
