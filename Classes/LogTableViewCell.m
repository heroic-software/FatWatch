//
//  LogTableViewCell.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "LogTableViewCell.h"

NSString *kLogCellReuseIdentifier = @"LogCell";

@implementation LogTableViewCell

@synthesize day;
@synthesize measuredWeight;
@synthesize trendWeight;
@synthesize flagged;
@synthesize note;

- (id)init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, 320, 44) reuseIdentifier:kLogCellReuseIdentifier]) {
		self.backgroundColor = [UIColor orangeColor];
		
		dayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		dayLabel.frame = CGRectInset(CGRectMake(0, 0, 44, 44), 4, 0);
		dayLabel.textAlignment = UITextAlignmentRight;
		dayLabel.font = [UIFont systemFontOfSize:24];
		dayLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:dayLabel];
		
		measuredWeightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		measuredWeightLabel.frame = CGRectInset(CGRectMake(44, 0, 144, 44), 4, 0);
		measuredWeightLabel.textAlignment = UITextAlignmentRight;
		measuredWeightLabel.font = [UIFont boldSystemFontOfSize:36];
		measuredWeightLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:measuredWeightLabel];
		
		trendWeightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		trendWeightLabel.frame = CGRectInset(CGRectMake(188, 14, 88, 16), 4, 0);
		trendWeightLabel.textAlignment = UITextAlignmentLeft;
		trendWeightLabel.font = [UIFont systemFontOfSize:14];
		trendWeightLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:trendWeightLabel];
				
		noteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		noteLabel.frame = CGRectInset(CGRectMake(188, 30, 132, 14), 4, 0);
		noteLabel.textAlignment = UITextAlignmentLeft;
		noteLabel.font = [UIFont italicSystemFontOfSize:10];
		noteLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:noteLabel];
    }
    return self;
}

- (void)dealloc
{
	[note release];
	[noteLabel release];
	[trendWeightLabel release];
	[measuredWeightLabel release];
	[dayLabel release];
    [super dealloc];
}

- (void)updateLabels
{
	[dayLabel setText:[NSString stringWithFormat:@"%d", day]];
	
	if (measuredWeight == 0) {
		measuredWeightLabel.text = @"—";
		trendWeightLabel.hidden = YES;
	} else {
		measuredWeightLabel.text = [NSString stringWithFormat:@"%.1f", measuredWeight];
		float weightDiff = measuredWeight - trendWeight;
		trendWeightLabel.hidden = NO;
		trendWeightLabel.text = [NSString stringWithFormat:@"%+.1f", weightDiff];
		trendWeightLabel.textColor = (weightDiff > 0) ? [UIColor redColor] : [UIColor greenColor];
	}
	
	self.accessoryType = flagged ? UITableViewCellAccessoryCheckmark 
								 : UITableViewCellAccessoryNone;

	if (note) {
		noteLabel.hidden = NO;
		noteLabel.text = note;
	} else {
		noteLabel.hidden = YES;
	}
}

/*
 - (void)touchesChangedWithEvent:(UIEvent*)event
{
    UITouch *touch = [[event touchesForView:self] anyObject];
	if (touch.phase == UITouchPhaseEnded) {
		if (touch.info & UITouchInfoSwipedRight) {
			flagged = ! flagged;
			[self updateLabels];
			[self setNeedsDisplay];
			return;
		}
		NSLog(@"Touch: %@", touch);
	}
	[self.nextResponder touchesChangedWithEvent:event];
}
*/

@end
