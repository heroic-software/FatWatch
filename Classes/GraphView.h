//
//  GraphView.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/16/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWDate.h"

#define EWMonthNone NSIntegerMin

@interface GraphView : UIView {
	EWMonth month;
	CGImageRef image;
}
@property (nonatomic) CGImageRef image;
@property (nonatomic) EWMonth month;
@end
