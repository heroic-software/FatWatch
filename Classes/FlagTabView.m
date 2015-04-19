/*
 * FlagTabView.m
 * Created by Benjamin Ragheb on 1/16/10.
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

#import "FlagTabView.h"


@implementation FlagTabView
{
	CGRect tabRect;
}

- (void)awakeFromNib {
	UIView *view = (self.subviews)[0];
	[self selectTabAroundRect:[view frame]];
}


- (void)selectTabAroundRect:(CGRect)rect {
	tabRect = rect;
	[self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
	CGRect b = self.bounds;
	[[UIColor whiteColor] setFill];
	UIRectFill(CGRectInset(tabRect, -10, -10));
	[[UIColor grayColor] setStroke];
	CGContextRef context = UIGraphicsGetCurrentContext();

	const CGFloat xL = CGRectGetMinX(tabRect)-10.5f;
	const CGFloat xR = CGRectGetMaxX(tabRect)+10.5f;
	const CGFloat yT = CGRectGetMinY(tabRect)-10.5f;
	const CGFloat yB = CGRectGetMaxY(b)-0.5f;
	
	CGContextMoveToPoint(context, CGRectGetMinX(b), yB);
	CGContextAddLineToPoint(context, xL, yB);
	CGContextAddLineToPoint(context, xL, yT);
	CGContextAddLineToPoint(context, xR, yT);
	CGContextAddLineToPoint(context, xR, yB);
	CGContextAddLineToPoint(context, CGRectGetMaxX(b), yB);
	CGContextStrokePath(context);
}




@end
