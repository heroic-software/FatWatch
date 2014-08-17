//
//  LogTableViewCell.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWDate.h"
#import "EWDBMonth.h"

@class LogTableViewCellContentView;

typedef NS_ENUM(NSInteger, AuxiliaryInfoType) {
	kAuxiliaryInfoTypeVariance,
	kAuxiliaryInfoTypeBMI,
	kAuxiliaryInfoTypeFatPercent,
	kAuxiliaryInfoTypeFatWeight,
	kAuxiliaryInfoTypeTrend,
	kNumberOfAuxiliaryInfoTypes
};

extern NSString * const kLogCellReuseIdentifier;

@interface LogTableViewCell : UITableViewCell
@property (nonatomic,weak) UITableView *tableView;
@property (nonatomic,readonly) LogTableViewCellContentView *logContentView;
+ (AuxiliaryInfoType)auxiliaryInfoType;
+ (void)setAuxiliaryInfoType:(AuxiliaryInfoType)infoType;
+ (NSString *)nameForAuxiliaryInfoType:(AuxiliaryInfoType)infoType;
+ (NSArray *)availableAuxiliaryInfoTypes;
- (void)updateWithMonthData:(EWDBMonth *)monthData day:(EWDay)day;
- (void)auxiliaryInfoTypeChanged:(NSNotification *)notification;
@end


@interface LogTableViewCellContentView : UIView
@property (nonatomic,weak) LogTableViewCell *cell;
@property (nonatomic,strong) NSString *day;
@property (nonatomic,strong) NSString *weekday;
@property (nonatomic) const EWDBDay *dd;
@property (nonatomic) BOOL highlightDate;
- (void)bmiStatusDidChange:(NSNotification *)notification;
- (void)flagIconDidChange:(NSNotification *)notification;
@end
