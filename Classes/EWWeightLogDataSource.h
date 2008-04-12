//
//  EWWeightLogDataSource.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/15/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Database;
@class LogViewController;

@interface EWWeightLogDataSource : NSObject <UITableViewDelegate, UITableViewDataSource> {
	Database *database;
	NSDate *beginDate;
	NSDate *endDate;
	NSDateFormatter *sectionTitleFormatter;
	NSUInteger numberOfSections;
	NSIndexPath *lastIndexPath;
	LogViewController *viewController;
}
@property (nonatomic,retain) LogViewController *viewController;
- (id)initWithDatabase:(Database *)db;
- (NSIndexPath *)lastIndexPath;
@end
