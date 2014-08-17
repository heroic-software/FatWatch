//
//  EWDateFormatter.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 2/10/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EWDateFormatter : NSFormatter
+ (NSFormatter *)formatterWithDateFormat:(NSString *)format;
- (id)initWithDateFormat:(NSString *)format;
@end


@interface EWISODateFormatter : NSFormatter
@end
