//
//  BRTableNumberPickerRow.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTableValueRow.h"


@interface BRTableNumberPickerRow : BRTableValueRow {
	float minimumValue;
	float maximumValue;
	float increment;
	NSNumber *defaultValue;
}
@property (nonatomic) float minimumValue;
@property (nonatomic) float maximumValue;
@property (nonatomic) float increment;
@property (nonatomic,retain) NSNumber *defaultValue;
@end
