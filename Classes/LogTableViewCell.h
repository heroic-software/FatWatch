//
//  LogTableViewCell.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWDate.h"

@class MonthData;

extern NSString *kLogCellReuseIdentifier;

@interface LogTableViewCell : UITableViewCell {
	UILabel *dayLabel;
	UILabel *measuredWeightLabel;
	UILabel *trendWeightLabel;
	UILabel *noteLabel;
}
- (void)updateWithMonthData:(MonthData *)monthData day:(EWDay)day;
@end
