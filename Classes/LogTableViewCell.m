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
@synthesize note;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
		dayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		dayLabel.textAlignment = UITextAlignmentRight;
		dayLabel.font = [UIFont systemFontOfSize:24];
		dayLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:dayLabel];
		
		measuredWeightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		measuredWeightLabel.textAlignment = UITextAlignmentRight;
		measuredWeightLabel.font = [UIFont boldSystemFontOfSize:36];
		measuredWeightLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:measuredWeightLabel];
		
		trendWeightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		trendWeightLabel.textAlignment = UITextAlignmentLeft;
		trendWeightLabel.font = [UIFont systemFontOfSize:24];
		trendWeightLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:trendWeightLabel];
		
		flaggedLabel = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		[self addSubview:flaggedLabel];
		
		noteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		noteLabel.textAlignment = UITextAlignmentCenter;
		noteLabel.font = [UIFont italicSystemFontOfSize:12];
		noteLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:noteLabel];
		
    }
    return self;
}

- (void)layoutSubviews 
{
	[super layoutSubviews];
    if (!self.editing) {
		dayLabel.frame = CGRectInset(CGRectMake(0, 0, 44, 44), 4, 4);
		measuredWeightLabel.frame = CGRectInset(CGRectMake(44, 0, 144, 44), 4, 4);
		trendWeightLabel.frame = CGRectInset(CGRectMake(188, 0, 88, 44), 4, 4);
		flaggedLabel.frame = CGRectInset(CGRectMake(276, 0, 44, 44), 4, 4);
		noteLabel.frame = CGRectMake(0, 40, 320, 20);
	}
}

- (void)dealloc
{
	[note release];
	[noteLabel release];
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
	[flaggedLabel setTitle:(flagged ? @"X" : @" ") forStates:UIControlStateNormal];

	CGRect frame = self.frame;
	if (note) {
		noteLabel.text = note;
		frame.size.height = 64;
		[noteLabel setHidden:NO];
	} else {
		frame.size.height = 44;
		[noteLabel setHidden:YES];
	}
	self.frame = frame;
}

@end
