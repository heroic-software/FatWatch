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
#import "WeightFormatters.h"


NSString *kLogCellReuseIdentifier = @"LogCell";


@interface LogTableViewCellContentView : UIView {
	NSString *day;
	NSString *weekday;
	NSString *scaleWeight;
	NSString *trendDelta;
	NSString *note;
	BOOL trendPositive;
	BOOL checked;
}
@property (nonatomic,retain) NSString *day;
@property (nonatomic,retain) NSString *weekday;
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
		logContentView.opaque = YES;
		[self.contentView addSubview:logContentView];
		[logContentView release];
		
		highlightWeekends = [[NSUserDefaults standardUserDefaults] boolForKey:@"HighlightWeekends"];
	}
	return self;
}


- (void)updateWithMonthData:(MonthData *)monthData day:(EWDay)day {
	logContentView.day = [[NSNumber numberWithInt:day] description];

	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"EEE"];
	logContentView.weekday = [df stringFromDate:EWDateFromMonthAndDay(monthData.month, day)];
	[df release];
	
	if (highlightWeekends && EWMonthAndDayIsWeekend(monthData.month, day)) {
		logContentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
	} else {
		logContentView.backgroundColor = [UIColor whiteColor];
	}
	
	float measuredWeight = [monthData measuredWeightOnDay:day];
	if (measuredWeight == 0) {
		logContentView.scaleWeight = nil;
		logContentView.trendDelta = nil;
		logContentView.backgroundColor = [UIColor whiteColor];
	} else {
		logContentView.scaleWeight = [WeightFormatters stringForWeight:measuredWeight];
		float trendWeight = [monthData trendWeightOnDay:day];
		float weightDiff = measuredWeight - trendWeight;
		logContentView.trendDelta = [WeightFormatters stringForWeightChange:weightDiff];
		logContentView.trendPositive = (weightDiff > 0);
		logContentView.backgroundColor = [WeightFormatters backgroundColorForWeight:measuredWeight];
	}

	logContentView.checked = [monthData isFlaggedOnDay:day];
	logContentView.note = [monthData noteOnDay:day];
	
	[logContentView setNeedsDisplay];
}

@end



@implementation LogTableViewCellContentView


@synthesize day, weekday, scaleWeight, trendDelta, note, trendPositive, checked;


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
		CGRect weekdayRect = CGRectMake(0, noteY, dayRight, noteRowHeight);
		[weekday drawInRect:weekdayRect
				   withFont:[UIFont systemFontOfSize:12]
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
			[[WeightFormatters badColor] setFill];
		} else {
			[[WeightFormatters goodColor] setFill];
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
