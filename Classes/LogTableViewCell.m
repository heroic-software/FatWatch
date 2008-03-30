//
//  LogTableViewCell.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "LogTableViewCell.h"


@implementation LogTableViewCell

@synthesize day;
@synthesize measuredWeight;
@synthesize trendWeight;
@synthesize flagged;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
		dayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[dayLabel setTextAlignment:UITextAlignmentRight];
		[dayLabel setFont:[UIFont systemFontOfSize:22]];
		[dayLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:dayLabel];
		
		measuredWeightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[measuredWeightLabel setTextAlignment:UITextAlignmentCenter];
		[measuredWeightLabel setFont:[UIFont boldSystemFontOfSize:24]];
		measuredWeightLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:measuredWeightLabel];
		
		trendWeightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[trendWeightLabel setTextAlignment:UITextAlignmentCenter];
		[trendWeightLabel setFont:[UIFont systemFontOfSize:22]];
		trendWeightLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:trendWeightLabel];
		
		flaggedLabel = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		[self addSubview:flaggedLabel];
    }
    return self;
}

// 300
// 30 + 120 + 100 + 50
// [25][188.3][-2.0][X]

- (void)layoutSubviews 
{
	[super layoutSubviews];
    if (!self.editing) {
		CGRect contentRect = [self contentRectForBounds:self.bounds];
		dayLabel.frame = CGRectMake(0, contentRect.origin.y, 30, contentRect.size.height);
		measuredWeightLabel.frame = CGRectMake(30, contentRect.origin.y, 120, contentRect.size.height);
		trendWeightLabel.frame = CGRectMake(150, contentRect.origin.y, 100, contentRect.size.height);
		flaggedLabel.frame = CGRectMake(250, contentRect.origin.y, 50, contentRect.size.height);
	}
}

- (void)dealloc
{
	[flaggedLabel release];
	[trendWeightLabel release];
	[measuredWeightLabel release];
	[dayLabel release];
    [super dealloc];
}

- (void)updateLabels
{
	[dayLabel setText:[NSString stringWithFormat:@"%d", day]];
	if (measuredWeight == 0) {
		[measuredWeightLabel setText:@"—"];
		[trendWeightLabel setText:@""];
	} else {
		[measuredWeightLabel setText:[NSString stringWithFormat:@"%.1f", measuredWeight]];
		float weightDiff = trendWeight - measuredWeight;
		[trendWeightLabel setText:[NSString stringWithFormat:@"%+.1f", weightDiff]];
		if (weightDiff > 0) {
			[trendWeightLabel setTextColor:[UIColor redColor]];
		} else {
			[trendWeightLabel setTextColor:[UIColor greenColor]];
		}
	}
	[flaggedLabel setTitle:(flagged ? @"On" : @"Off") forStates:UIControlStateNormal];
}

@end
