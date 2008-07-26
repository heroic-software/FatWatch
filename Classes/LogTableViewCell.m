//
//  LogTableViewCell.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "LogTableViewCell.h"
#import "EWDate.h"
#import "MonthData.h"
#import "WeightFormatter.h"


NSString *kLogCellReuseIdentifier = @"LogCell";


@interface LogTableViewCellContentView : UIView {
	NSString *day;
	NSString *scaleWeight;
	NSString *trendDelta;
	NSString *note;
	BOOL trendPositive;
	BOOL checked;
}
@property (nonatomic,retain) NSString *day;
@property (nonatomic,retain) NSString *scaleWeight;
@property (nonatomic,retain) NSString *trendDelta;
@property (nonatomic,retain) NSString *note;
@property (nonatomic) BOOL trendPositive;
@property (nonatomic) BOOL checked;
@end


@implementation LogTableViewCell

- (id)init {
    if ([super initWithFrame:CGRectMake(0, 0, 320, 44) reuseIdentifier:kLogCellReuseIdentifier]) {
		logContentView = [[LogTableViewCellContentView alloc] initWithFrame:self.contentView.bounds];
		logContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		logContentView.backgroundColor = [UIColor whiteColor];
		logContentView.opaque = YES;
		[self.contentView addSubview:logContentView];
		[logContentView release];
	}
	return self;
}


- (void)updateWithMonthData:(MonthData *)monthData day:(EWDay)day {
	logContentView.day = [[NSNumber numberWithInt:day] description];
	
	float measuredWeight = [monthData measuredWeightOnDay:day];
	if (measuredWeight == 0) {
		logContentView.scaleWeight = nil;
		logContentView.trendDelta = nil;
	} else {
		WeightFormatter *formatter = [WeightFormatter sharedFormatter];
		
		logContentView.scaleWeight = [formatter stringFromMeasuredWeight:measuredWeight];
		float weightDiff = measuredWeight - [monthData trendWeightOnDay:day];
		logContentView.trendDelta = [formatter stringFromTrendDifference:weightDiff];
		logContentView.trendPositive = (weightDiff > 0);
	}
	
	logContentView.checked = [monthData isFlaggedOnDay:day];
	logContentView.note = [monthData noteOnDay:day];
	[logContentView setNeedsDisplay];
}

@end



@implementation LogTableViewCellContentView


@synthesize day, scaleWeight, trendDelta, note, trendPositive, checked;


- (void)drawRect:(CGRect)rect {
	const CGFloat topMargin = 9;
	const CGFloat numberRowHeight = 33;
	const CGFloat dayRight = 34;
	const CGFloat scaleWeightRight = 174;
	const CGFloat trendDeltaLeft = 178;
	const CGFloat noteY = 28;
	const CGFloat noteRowHeight = 15;
	
	CGFloat cellWidth = CGRectGetWidth(self.bounds);
	
	if (day) {
		[[UIColor blackColor] setFill];
		CGRect dayRect = CGRectMake(0, topMargin, dayRight, numberRowHeight);
		[day drawInRect:dayRect
			   withFont:[UIFont systemFontOfSize:20]
		  lineBreakMode:UILineBreakModeClip 
			  alignment:UITextAlignmentRight];
	}
	
	if (scaleWeight) {
		CGRect scaleWeightRect = CGRectMake(0, topMargin, scaleWeightRight, numberRowHeight); 
		[scaleWeight drawInRect:scaleWeightRect
					   withFont:[UIFont boldSystemFontOfSize:20]
				  lineBreakMode:UILineBreakModeClip
					  alignment:UITextAlignmentRight];
		if (trendPositive) {
			[[UIColor redColor] setFill];
		} else {
			[[UIColor greenColor] setFill];
		}
		CGRect trendDeltaRect = CGRectMake(trendDeltaLeft, topMargin, cellWidth-trendDeltaLeft, numberRowHeight);
		[trendDelta drawInRect:trendDeltaRect
					  withFont:[UIFont systemFontOfSize:20]
				 lineBreakMode:UILineBreakModeClip
					 alignment:UITextAlignmentLeft];
	}
	
	if (note) {
		[[UIColor darkGrayColor] setFill];
		CGRect noteRect = CGRectMake(0, noteY, cellWidth, noteRowHeight);
		[note drawInRect:noteRect
				withFont:[UIFont systemFontOfSize:12]
		   lineBreakMode:UILineBreakModeClip
			   alignment:UITextAlignmentCenter];
	}
	
	if (checked) {
		UIImage *checkImage = [UIImage imageNamed:@"Check.png"];
		[checkImage drawAtPoint:CGPointMake(cellWidth - 30, 10)];
	}
}


@end
