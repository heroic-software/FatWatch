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


@class GraphView;

@interface GraphViewController : DataViewController <UIScrollViewDelegate> {
	BOOL firstLoad;
	struct GraphViewInfo {
		EWMonth month;
		CGFloat offsetX;
		CGFloat width;
		GraphView *view;
	} *info;
	size_t infoCount;
	NSMutableArray *cachedGraphViews;
}
- (void)clearGraphViewInfo;
@end
