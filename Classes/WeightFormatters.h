//
//  WeightFormatters.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WeightFormatters : NSObject {

}

+ (UIColor *)goodColor;
+ (UIColor *)warningColor;
+ (UIColor *)badColor;

+ (NSArray *)weightUnitNames;
+ (NSUInteger)selectedWeightUnitIndex;
+ (void)setSelectedWeightUnitIndex:(NSUInteger)index;

+ (NSArray *)energyUnitNames;
+ (NSUInteger)selectedEnergyUnitIndex;
+ (void)setSelectedEnergyUnitIndex:(NSUInteger)index;

+ (NSArray *)scaleIncrementNames;
+ (NSUInteger)selectedScaleIncrementIndex;
+ (void)setSelectedScaleIncrementIndex:(NSUInteger)index;

+ (float)scaleIncrement;
+ (float)defaultWeightChange;

+ (float)goalWeightIncrement;
+ (NSFormatter *)goalWeightFormatter;

+ (NSFormatter *)weightFormatter;
+ (NSString *)stringForWeight:(float)weightLbs;

+ (NSFormatter *)weightChangeFormatter;
+ (NSString *)stringForWeightChange:(float)deltaLbs;

+ (NSFormatter *)energyChangePerDayFormatter;
+ (NSString *)energyStringForWeightPerDay:(float)lbsPerDay;
+ (float)energyChangePerDayIncrement;

+ (NSFormatter *)weightChangePerWeekFormatter;
+ (NSString *)weightStringForWeightPerDay:(float)lbsPerDay;
+ (float)weightChangePerWeekIncrement;

+ (NSNumberFormatter *)exportWeightFormatter;

+ (NSNumberFormatter *)chartWeightFormatter;
+ (float)chartWeightIncrement;
+ (float)chartWeightIncrementAfter:(float)previousIncrement;

+ (float)bodyMassIndexForWeight:(float)weight;
+ (float)weightForBodyMassIndex:(float)bmi;

+ (UIColor *)backgroundColorForWeight:(float)weight;
+ (UIColor *)colorForBodyMassIndex:(float)BMI;

+ (NSFormatter *)heightFormatter;
+ (float)heightIncrement;

@end

#import "BRTableValueRow.h"

@interface BMITextColorFormatter : NSObject <BRColorFormatter> {
}
@end

@interface BMIBackgroundColorFormatter : NSObject <BRColorFormatter> {
}
@end
