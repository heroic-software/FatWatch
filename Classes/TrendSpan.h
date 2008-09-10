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
	BOOL visible;
	BOOL goal;
}
+ (NSArray *)computeTrendSpans;
@property (nonatomic,retain) NSString *title;
@property (nonatomic) NSInteger length;
@property (nonatomic) float weightPerDay;
@property (nonatomic) BOOL visible;
@property (nonatomic) BOOL goal;
@property (nonatomic,readonly) NSDate *endDate;
@end
