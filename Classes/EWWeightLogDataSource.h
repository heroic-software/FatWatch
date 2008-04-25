//
//  EWWeightLogDataSource.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/15/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWDate.h"

@class LogViewController;

@interface EWWeightLogDataSource : NSObject <UITableViewDelegate, UITableViewDataSource> {
	EWMonth earliestMonth;
	NSDateFormatter *sectionTitleFormatter;
	NSUInteger numberOfSections;
	NSIndexPath *lastIndexPath;
	LogViewController *viewController;
}
@property (nonatomic,retain) LogViewController *viewController;
- (NSIndexPath *)lastIndexPath;
- (EWMonth)monthForSection:(NSInteger)section;
@end
