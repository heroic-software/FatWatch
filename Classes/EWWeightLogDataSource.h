//
//  EWWeightLogDataSource.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/15/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EWWeightLogDataSource : NSObject <UITableViewDelegate, UITableViewDataSource> {
	NSDate *beginDate;
	NSDate *endDate;
	NSDateFormatter *sectionTitleFormatter;
	NSUInteger numberOfSections;
	NSIndexPath *lastIndexPath;
}
- (NSIndexPath *)lastIndexPath;
@end
