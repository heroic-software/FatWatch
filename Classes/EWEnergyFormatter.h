//
//  EWEnergyFormatter.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/5/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EWEnergyFormatter : NSNumberFormatter {

}
- (NSString *)stringFromFloat:(float)value;
@end
