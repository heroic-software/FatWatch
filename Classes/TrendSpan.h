//
//  TrendSpan.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 9/9/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TrendSpan : NSObject {
	NSString *title;
	NSInteger length;
	float weightPerDay;
	float weightChange;
	BOOL visible;
}
+ (NSArray *)computeTrendSpans;
@property (nonatomic,retain) NSString *title;
@property (nonatomic) NSInteger length;
@property (nonatomic) float weightPerDay;
@property (nonatomic) float weightChange;
@property (nonatomic) BOOL visible;
- (NSInteger)numberOfTableRows;
- (void)configureCell:(UITableViewCell *)cell forTableRow:(NSInteger)row;
- (BOOL)shouldUpdateAfterDidSelectRow:(NSInteger)row;
@end


@interface GoalTrendSpan : TrendSpan {
	BOOL showEndDateAsDate;
}
@property (nonatomic,readonly) NSDate *endDate;
@end
