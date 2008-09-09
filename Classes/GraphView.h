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
	EWMonth month;
	UIImage *image;
}
@property (nonatomic,retain) UIImage *image;
@property (nonatomic) EWMonth month;
@end
