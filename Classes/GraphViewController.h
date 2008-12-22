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

@interface GraphViewController : UIViewController <UIScrollViewDelegate> {
	IBOutlet YAxisView *axisView;
	IBOutlet UIScrollView *scrollView;
	IBOutlet UISegmentedControl *spanControl;
	struct GraphViewInfo {
		EWMonth month;
		CGFloat offsetX;
		CGFloat width;
		GraphView *view;
		UIImage *image;
		GraphDrawingOperation *operation;
	} *info;
	size_t infoCount;
	NSMutableArray *cachedGraphViews;
	int lastMinIndex, lastMaxIndex;
	GraphViewParameters parameters;
	NSOperationQueue *queue;
}
- (void)clearGraphViewInfo;
- (IBAction)spanSelected:(UISegmentedControl *)sender;
@end
