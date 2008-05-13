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

NSString *kLogCellReuseIdentifier = @"LogCell";

static NSNumberFormatter *dayFormatter = nil;
static NSNumberFormatter *measuredFormatter = nil;
static NSNumberFormatter *trendFormatter = nil;

@implementation LogTableViewCell

- (id)init
{
    if ([super initWithFrame:CGRectMake(0, 0, 320, 44) reuseIdentifier:kLogCellReuseIdentifier]) {
		
		if (dayFormatter == nil) {
			dayFormatter = [[NSNumberFormatter alloc] init];
			measuredFormatter = [[NSNumberFormatter alloc] init];
			[measuredFormatter setMinimumFractionDigits:1];
			trendFormatter = [[NSNumberFormatter alloc] init];
			[trendFormatter setPositivePrefix:@"+"];
			[trendFormatter setNegativePrefix:@"−"];
			[trendFormatter setMinimumIntegerDigits:1];
			[trendFormatter setMinimumFractionDigits:1];
		}
		
		dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
		dayLabel.textAlignment = UITextAlignmentRight;
		dayLabel.font = [UIFont systemFontOfSize:20];
		dayLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:dayLabel];
		
		measuredWeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 14, 120, 16)];
		measuredWeightLabel.textAlignment = UITextAlignmentRight;
		measuredWeightLabel.font = [UIFont boldSystemFontOfSize:20];
		measuredWeightLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:measuredWeightLabel];
		
		trendWeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(168, 14, 108, 16)];
		trendWeightLabel.textAlignment = UITextAlignmentLeft;
		trendWeightLabel.font = [UIFont systemFontOfSize:20];
		trendWeightLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:trendWeightLabel];
				
		noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 30, 242, 14)];
		noteLabel.textAlignment = UITextAlignmentCenter;
		noteLabel.font = [UIFont systemFontOfSize:12];
		noteLabel.textColor = [UIColor darkGrayColor];
		noteLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:noteLabel];
    }
    return self;
}

- (void)dealloc
{
	[noteLabel release];
	[trendWeightLabel release];
	[measuredWeightLabel release];
	[dayLabel release];
    [super dealloc];
}

- (void)updateWithMonthData:(MonthData *)monthData day:(EWDay)day;
{
	dayLabel.text = [dayFormatter stringFromNumber:[NSNumber numberWithInt:day]];
	
	float measuredWeight = [monthData measuredWeightOnDay:day];
	if (measuredWeight == 0) {
		measuredWeightLabel.hidden = YES;
		trendWeightLabel.hidden = YES;
	} else {
		measuredWeightLabel.hidden = NO;
		measuredWeightLabel.text = [measuredFormatter stringFromNumber:[NSNumber numberWithFloat:measuredWeight]];
		float weightDiff = measuredWeight - [monthData trendWeightOnDay:day];
		trendWeightLabel.hidden = NO;
		trendWeightLabel.text = [trendFormatter stringFromNumber:[NSNumber numberWithFloat:weightDiff]];
		trendWeightLabel.textColor = (weightDiff > 0) ? [UIColor redColor] : [UIColor greenColor];
	}
	
	self.accessoryType = [monthData isFlaggedOnDay:day] ? UITableViewCellAccessoryCheckmark 
														: UITableViewCellAccessoryNone;

	NSString *note = [monthData noteOnDay:day];
	if (note == nil) {
		noteLabel.hidden = YES;
	} else {
		noteLabel.hidden = NO;
		noteLabel.text = note;
	}
}

@end
