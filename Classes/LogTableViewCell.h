/*
 * LogTableViewCell.h
 * Created by Benjamin Ragheb on 3/29/08.
 * Copyright 2015 Heroic Software Inc
 *
 * This file is part of FatWatch.
 *
 * FatWatch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FatWatch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
 */

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
