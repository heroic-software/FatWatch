//
//  LogTableViewCell.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *kLogCellReuseIdentifier;

@interface LogTableViewCell : UITableViewCell {

	unsigned day;
	float measuredWeight;
	float trendWeight;
	BOOL flagged;
	NSString *note;

	UILabel *dayLabel;
	UILabel *measuredWeightLabel;
	UILabel *trendWeightLabel;
	UILabel *noteLabel;

}

@property (nonatomic) unsigned day;
@property (nonatomic) float measuredWeight;
@property (nonatomic) float trendWeight;
@property (nonatomic) BOOL flagged;
@property (nonatomic,retain) NSString *note;

- (void)updateLabels;

@end
