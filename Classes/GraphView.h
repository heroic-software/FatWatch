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
	UIView *yAxisView;
	BOOL exporting;
	BOOL drawBorder;
}
@property (nonatomic) CGImageRef image;
@property (nonatomic) EWMonthDay beginMonthDay;
@property (nonatomic) EWMonthDay endMonthDay;
@property (nonatomic,strong) GraphViewParameters *p;
@property (nonatomic,strong) UIView *yAxisView;
@property (nonatomic) BOOL drawBorder;
- (void)exportImageToSavedPhotos;
- (void)exportImageToPasteboard;
@end
