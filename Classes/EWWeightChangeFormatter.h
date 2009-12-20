//
//  EWWeightChangeFormatter.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/20/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	EWWeightChangeFormatterStyleEnergyPerDay,
	EWWeightChangeFormatterStyleWeightPerWeek
} EWWeightChangeFormatterStyle;


@interface EWWeightChangeFormatter : NSNumberFormatter {

}
+ (float)energyChangePerDayIncrement;
+ (float)weightChangePerWeekIncrement;
- (id)initWithStyle:(EWWeightChangeFormatterStyle)style;
@end
