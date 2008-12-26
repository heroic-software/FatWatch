//
//  GraphView.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/16/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWDate.h"

@interface GraphView : UIView {
	EWMonthDay beginMonthDay;
	EWMonthDay endMonthDay;
	UIImage *image;
}
@property (nonatomic,retain) UIImage *image;
- (void)setBeginMonthDay:(EWMonthDay)mdBegin endMonthDay:(EWMonthDay)mdEnd;
@end
