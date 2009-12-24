//
//  EWTrendButton.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/24/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "EWTrendButton.h"


@implementation EWTrendButton


- (void)awakeFromNib {
	//[self addTarget:self action:@selector(touchEventAction) forControlEvents:UIControlEventAllTouchEvents];
	marginSize = CGSizeMake(10, 4);
}


- (void)setHighlighted:(BOOL)flag {
	[super setHighlighted:flag];
	[self setNeedsDisplay];
}


- (NSMutableDictionary *)infoForPart:(int)part {
	if (part < [partArray count]) {
		return [partArray objectAtIndex:part];
	}
	NSMutableDictionary *info = nil;
	UIColor *color = [UIColor blackColor];
	UIFont *font = [UIFont systemFontOfSize:17];
	if (partArray == nil) {
		partArray = [[NSMutableArray alloc] init];
	}
	while (part >= [partArray count]) {
		info = [[NSMutableDictionary alloc] init];
		[info setObject:font forKey:@"font"];
		[info setObject:color forKey:@"color"];
		[partArray addObject:info];
		[info release];
	}
	return info;
}


#pragma mark Public API


- (void)setText:(NSString *)text forPart:(int)part {
	[[self infoForPart:part] setObject:text forKey:@"text"];
	[self setNeedsDisplay];
}


- (void)setTextColor:(UIColor *)color forPart:(int)part {
	[[self infoForPart:part] setObject:color forKey:@"color"];
	[self setNeedsDisplay];
}


- (void)setFont:(UIFont *)font forPart:(int)part {
	[[self infoForPart:part] setObject:font forKey:@"font"];
	[self setNeedsDisplay];
}


#pragma mark UIView


- (void)drawRect:(CGRect)rect {
	const CGFloat minFontSize = 6.0f;
	
	if (self.highlighted) {
		[[UIColor colorWithRed:0.2 green:0.2 blue:1 alpha:1] setFill];
		UIRectFill(self.bounds);
		[[UIColor whiteColor] setFill]; // for text
	}
	
	CGFloat remainingWidth = CGRectGetWidth(self.bounds) - (2*marginSize.width);
	CGPoint p = CGPointMake(marginSize.width, marginSize.height);
	for (NSDictionary *info in partArray) {
		NSString *text = [info objectForKey:@"text"];
		
		if (text == nil) continue;

		if (! self.highlighted) {
			[[info objectForKey:@"color"] setFill];
		}

		UIFont *font = [info objectForKey:@"font"];
		CGFloat usedFontSize;
		CGSize size = [text sizeWithFont:font
							 minFontSize:minFontSize
						  actualFontSize:&usedFontSize
								forWidth:remainingWidth
						   lineBreakMode:UILineBreakModeClip];
		
		[text drawAtPoint:p
				 forWidth:size.width
				 withFont:font
				 fontSize:usedFontSize
			lineBreakMode:UILineBreakModeClip
	   baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		
		remainingWidth -= size.width;
		p.x += size.width;
	}
}


#pragma mark Cleanup


- (void)dealloc {
	[partArray release];
    [super dealloc];
}


@end
