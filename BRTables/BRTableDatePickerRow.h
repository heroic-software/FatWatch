//
//  BRTableDatePickerRow.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTableValueRow.h"


@interface BRTableDatePickerRow : BRTableValueRow {
	NSDate *minimumDate;
	NSDate *maximumDate;
	UIDatePickerMode datePickerMode;
}
@property (nonatomic,strong) NSDate *minimumDate;
@property (nonatomic,strong) NSDate *maximumDate;
@property (nonatomic) UIDatePickerMode datePickerMode;
@end
