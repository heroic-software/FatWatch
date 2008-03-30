//
//  LogTableViewCell.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LogTableViewCell : UITableViewCell {
	
	unsigned day;
	float measuredWeight;
	float trendWeight;
	BOOL flagged;

	UILabel *dayLabel;
	UILabel *measuredWeightLabel;
	UILabel *trendWeightLabel;
	UIButton *flaggedLabel;
	
}

@property (nonatomic) unsigned day;
@property (nonatomic) float measuredWeight;
@property (nonatomic) float trendWeight;
@property (nonatomic) BOOL flagged;

- (void)updateLabels;

@end
