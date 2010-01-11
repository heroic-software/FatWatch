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


@interface GraphView : UIView <UIActionSheetDelegate> {
	EWMonthDay beginMonthDay;
	EWMonthDay endMonthDay;
	GraphViewParameters *p;
	CGImageRef image;
	UIView *yAxisView;
	BOOL selected;
	BOOL exporting;
}
@property (nonatomic,getter=isSelected) BOOL selected;
@property (nonatomic) CGImageRef image;
@property (nonatomic) EWMonthDay beginMonthDay;
@property (nonatomic) EWMonthDay endMonthDay;
@property (nonatomic) GraphViewParameters *p;
@property (nonatomic,retain) UIView *yAxisView;
@end
