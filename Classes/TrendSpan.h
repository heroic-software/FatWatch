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
	// Independent (Total or Fat)
	NSString *title;
	EWMonthDay beginMonthDay;
	EWMonthDay endMonthDay;
	float flagFrequencies[4];
	// Dependent
	float totalWeightPerDay, fatWeightPerDay;
	NSDate *totalEndDate, *fatEndDate;
	GraphViewParameters totalGraphParameters, fatGraphParameters;
	NSOperation *totalGraphOperation, *fatGraphOperation;
	CGImageRef totalGraphImageRef, fatGraphImageRef;
}
+ (NSArray *)computeTrendSpansFromDatabase:(EWDatabase *)db;
@property (nonatomic,retain) NSString *title;
@property (nonatomic) EWMonthDay beginMonthDay;
@property (nonatomic) EWMonthDay endMonthDay;
@property (nonatomic,readonly) NSInteger length;
@property (nonatomic,readonly) float *flagFrequencies;

@property (nonatomic) float totalWeightPerDay;
@property (nonatomic,retain) NSDate *totalEndDate;
@property (nonatomic,readonly) GraphViewParameters *totalGraphParameters;
@property (nonatomic,retain) NSOperation *totalGraphOperation;
@property (nonatomic) CGImageRef totalGraphImageRef;

@property (nonatomic) float fatWeightPerDay;
@property (nonatomic,retain) NSDate *fatEndDate;
@property (nonatomic,readonly) GraphViewParameters *fatGraphParameters;
@property (nonatomic,retain) NSOperation *fatGraphOperation;
@property (nonatomic) CGImageRef fatGraphImageRef;
@end
