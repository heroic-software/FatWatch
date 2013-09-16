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

extern NSString * const kLogCellReuseIdentifier;

@interface LogTableViewCell : UITableViewCell {
	UITableView *__weak tableView;
	LogTableViewCellContentView *logContentView;
	BOOL highlightWeekends;
}
@property (nonatomic,weak) UITableView *tableView;
@property (nonatomic,readonly) LogTableViewCellContentView *logContentView;
+ (NSInteger)auxiliaryInfoType;
+ (void)setAuxiliaryInfoType:(NSInteger)infoType;
+ (NSString *)nameForAuxiliaryInfoType:(NSInteger)infoType;
+ (NSArray *)availableAuxiliaryInfoTypes;
- (void)updateWithMonthData:(EWDBMonth *)monthData day:(EWDay)day;
- (void)auxiliaryInfoTypeChanged:(NSNotification *)notification;
@end


@interface LogTableViewCellContentView : UIView {
	LogTableViewCell *__weak cell;
	NSString *day;
	NSString *weekday;
	const EWDBDay *dd;
	BOOL highlightDate;
	NSFormatter *weightFormatter;
	NSFormatter *varianceFormatter;
	NSFormatter *bmiFormatter;
}
@property (nonatomic,weak) LogTableViewCell *cell;
@property (nonatomic,strong) NSString *day;
@property (nonatomic,strong) NSString *weekday;
@property (nonatomic) const EWDBDay *dd;
@property (nonatomic) BOOL highlightDate;
- (void)bmiStatusDidChange:(NSNotification *)notification;
- (void)flagIconDidChange:(NSNotification *)notification;
@end
