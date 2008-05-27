//
//  WeightFormatter.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeightFormatter : NSObject {
	NSNumberFormatter *measuredFormatter;
	NSNumberFormatter *trendFormatter;
	NSNumberFormatter *weightChangeFormatter;
	NSNumberFormatter *energyFormatter;
	NSString *stoneFormat;
}
+ (float)scaleIncrement;
+ (NSArray *)weightUnitNames;
+ (void)setWeightUnit:(int)index;
+ (WeightFormatter *)sharedFormatter;
- (NSString *)stringFromMeasuredWeight:(float)measuredWeight;
- (NSString *)stringFromTrendDifference:(float)difference;
- (NSString *)weightPerWeekStringFromWeightChange:(float)weightPerDay;
- (NSString *)energyPerDayStringFromWeightChange:(float)weightPerDay;
@end
