//
//  BRMixedNumberFormatter.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/10/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BRMixedNumberFormatter : NSFormatter
+ (BRMixedNumberFormatter *)poundsAsStonesFormatterWithFractionDigits:(NSUInteger)digits;
+ (BRMixedNumberFormatter *)metersAsFeetFormatter; // input values are inches
@property (nonatomic) float multiple;
@property (nonatomic) float divisor;
@property (nonatomic,strong) NSNumberFormatter *quotientFormatter;
@property (nonatomic,strong) NSNumberFormatter *remainderFormatter;
@property (nonatomic,strong) NSString *formatString;
@end
