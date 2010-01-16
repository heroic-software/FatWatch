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
	UITableView *tableView;
	LogTableViewCellContentView *logContentView;
	BOOL highlightWeekends;
}
@property (nonatomic,assign) UITableView *tableView;
@property (nonatomic,readonly) LogTableViewCellContentView *logContentView;
+ (NSInteger)auxiliaryInfoType;
+ (void)setAuxiliaryInfoType:(NSInteger)infoType;
+ (NSString *)nameForAuxiliaryInfoType:(NSInteger)infoType;
+ (NSArray *)availableAuxiliaryInfoTypes;
- (void)updateWithMonthData:(EWDBMonth *)monthData day:(EWDay)day;
@end


@interface LogTableViewCellContentView : UIView {
	LogTableViewCell *cell;
	NSString *day;
	NSString *weekday;
	const EWDBDay *dd;
	BOOL highlightDate;
	NSFormatter *weightFormatter;
	NSFormatter *varianceFormatter;
	NSFormatter *bmiFormatter;
}
@property (nonatomic,assign) LogTableViewCell *cell;
@property (nonatomic,retain) NSString *day;
@property (nonatomic,retain) NSString *weekday;
@property (nonatomic) const EWDBDay *dd;
@property (nonatomic) BOOL highlightDate;
- (void)bmiStatusDidChange:(NSNotification *)notification;
@end
