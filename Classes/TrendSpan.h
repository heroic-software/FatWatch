//
//  TrendSpan.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 9/9/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphDrawingOperation.h"


@class EWDatabase;


@interface TrendSpan : NSObject {
	NSString *title;
	NSInteger length;
	float weightPerDay;
	NSDate *endDate;
	float flagFrequencies[4];
	EWMonthDay beginMonthDay;
	EWMonthDay endMonthDay;
	CGImageRef graphImageRef;
	NSOperation *graphOperation;
	GraphViewParameters graphParameters;
}
+ (NSArray *)computeTrendSpansFromDatabase:(EWDatabase *)db;
@property (nonatomic,retain) NSString *title;
@property (nonatomic) NSInteger length;
@property (nonatomic) float weightPerDay;
@property (nonatomic,retain) NSDate *endDate;
@property (nonatomic,readonly) float *flagFrequencies;
@property (nonatomic) EWMonthDay beginMonthDay;
@property (nonatomic) EWMonthDay endMonthDay;
@property (nonatomic) CGImageRef graphImageRef;
@property (nonatomic,retain) NSOperation *graphOperation;
@property (nonatomic,readonly) GraphViewParameters *graphParameters;
@end
