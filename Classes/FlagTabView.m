//
//  FlagTabView.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/16/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "FlagTabView.h"


@implementation FlagTabView


- (void)awakeFromNib {
	UIView *view = [self.subviews objectAtIndex:0];
	[self selectTabAroundRect:[view frame]];
}


- (void)selectTabAroundRect:(CGRect)rect {
	tabRect = rect;
	[self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
	CGRect b = self.bounds;
	[[UIColor grayColor] setFill];
	UIRectFill(b);
	[[UIColor whiteColor] setFill];
	UIRectFill(CGRectInset(tabRect, -10, -10));
}


- (void)dealloc {
    [super dealloc];
}


@end
