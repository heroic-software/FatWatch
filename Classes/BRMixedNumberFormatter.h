//
//  BRMixedNumberFormatter.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/10/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BRMixedNumberFormatter : NSFormatter {
	float multiple;
	float divisor;
	NSNumberFormatter *quotientFormatter;
	NSNumberFormatter *remainderFormatter;
	NSString *formatString;
}
+ (BRMixedNumberFormatter *)poundsAsStonesFormatterWithFractionDigits:(NSUInteger)digits;
+ (BRMixedNumberFormatter *)metersAsFeetFormatter; // input values are inches
@property (nonatomic) float multiple;
@property (nonatomic) float divisor;
@property (nonatomic,retain) NSNumberFormatter *quotientFormatter;
@property (nonatomic,retain) NSNumberFormatter *remainderFormatter;
@property (nonatomic,retain) NSString *formatString;
@end
