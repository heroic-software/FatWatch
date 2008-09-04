//
//  GraphViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataViewController.h"
#import "EWDate.h"
#import "GraphView.h"
#import "GraphDrawingOperation.h"


@interface GraphViewController : DataViewController <UIScrollViewDelegate> {
	BOOL firstLoad;
	struct GraphViewInfo {
		EWMonth month;
		CGFloat offsetX;
		CGFloat width;
		GraphView *view;
		UIImage *image;
		BOOL drawing;
	} *info;
	size_t infoCount;
	NSMutableArray *cachedGraphViews;
	int lastMinIndex, lastMaxIndex;
	GraphViewParameters parameters;
	NSOperationQueue *queue;
}
- (void)clearGraphViewInfo;
@end
