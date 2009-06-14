//
//  GraphViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EWDate.h"
#import "GraphView.h"
#import "GraphDrawingOperation.h"

@class YAxisView;


typedef struct {
	EWMonthDay beginMonthDay;
	EWMonthDay endMonthDay;
	CGFloat offsetX;
	CGFloat width;
	GraphView *view;
	CGImageRef imageRef;
	GraphDrawingOperation *operation;
} GraphViewInfo;


@interface GraphViewController : UIViewController <UIScrollViewDelegate> {
	YAxisView *axisView;
	UIScrollView *scrollView;
	UISegmentedControl *spanControl;
	GraphViewInfo *info;
	size_t infoCount;
	NSMutableArray *cachedGraphViews;
	int lastMinIndex, lastMaxIndex;
	GraphViewParameters parameters;
	NSOperationQueue *queue;
	CGPoint scrollingSpanSavedOffset;
}
@property (nonatomic,retain) IBOutlet YAxisView *axisView;
@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic,retain) IBOutlet UISegmentedControl *spanControl;
- (void)clearGraphViewInfo;
- (IBAction)spanSelected:(UISegmentedControl *)sender;
@end
