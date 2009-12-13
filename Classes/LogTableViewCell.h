//
//  LogTableViewCell.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWDate.h"

@class EWDBMonth;
@class LogTableViewCellContentView;

extern NSString *kLogCellReuseIdentifier;

#define kLogContentViewTag 456

enum {
	kVarianceAuxiliaryInfoType,
	kBMIAuxiliaryInfoType
};

@interface LogTableViewCell : UITableViewCell {
	LogTableViewCellContentView *logContentView;
	BOOL highlightWeekends;
}
+ (void)setAuxiliaryInfoType:(NSInteger)infoType;
- (void)updateWithMonthData:(EWDBMonth *)monthData day:(EWDay)day;
@end
