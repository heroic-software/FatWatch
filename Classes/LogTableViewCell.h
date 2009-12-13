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

extern NSString * const kLogCellReuseIdentifier;

#define kLogContentViewTag 456

@interface LogTableViewCell : UITableViewCell {
	LogTableViewCellContentView *logContentView;
	BOOL highlightWeekends;
}
+ (NSInteger)auxiliaryInfoType;
+ (void)setAuxiliaryInfoType:(NSInteger)infoType;
+ (NSString *)nameForAuxiliaryInfoType:(NSInteger)infoType;
+ (NSArray *)availableAuxiliaryInfoTypes;
- (void)updateWithMonthData:(EWDBMonth *)monthData day:(EWDay)day;
@end
