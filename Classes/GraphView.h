//
//  GraphView.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/16/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWDate.h"
#import "GraphDrawingOperation.h"

@interface GraphView : UIView {
	EWMonthDay beginMonthDay;
	EWMonthDay endMonthDay;
	GraphViewParameters *p;
	CGImageRef image;
}
@property (nonatomic) CGImageRef image;
@property (nonatomic) EWMonthDay beginMonthDay;
@property (nonatomic) EWMonthDay endMonthDay;
@property (nonatomic) GraphViewParameters *p;
@end
