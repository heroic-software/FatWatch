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

+ (NSArray *)weightUnitNames;
+ (int)indexOfSelectedWeightUnit;
+ (void)selectWeightUnitAtIndex:(int)index;

+ (NSArray *)energyUnitNames;
+ (int)indexOfSelectedEnergyUnit;
+ (void)selectEnergyUnitAtIndex:(int)index;

+ (float)scaleIncrement;

+ (NSNumberFormatter *)exportNumberFormatter;

+ (WeightFormatter *)sharedFormatter;
- (NSString *)stringFromMeasuredWeight:(float)measuredWeight;
- (NSString *)stringFromTrendDifference:(float)difference;
- (NSString *)weightPerWeekStringFromWeightChange:(float)weightPerDay;
- (NSString *)energyPerDayStringFromWeightChange:(float)weightPerDay;

@end
