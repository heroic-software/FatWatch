//
//  GraphViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "EWDate.h"
#import "Database.h"
#import "YAxisView.h"


enum {
	kScrollViewTag = 100,
	kScaleViewTag,
};


@implementation GraphViewController

- (id)init
{
	if (self = [super init]) {
		firstLoad = YES;
		cachedGraphViews = [[NSMutableArray alloc] initWithCapacity:5];
		self.title = NSLocalizedString(@"GRAPH_VIEW_TITLE", nil);
	}
	return self;
}


- (void)dealloc {
	[cachedGraphViews release];
	[self clearGraphViewInfo];
	[super dealloc];
}


- (NSString *)message
{
	return NSLocalizedString(@"NO_DATA_FOR_GRAPH", nil);
}


- (void)clearGraphViewInfo {
	if (info == nil) return;
	
	int i;
	for (i = 0; i < infoCount; i++) {
		UIView *view = info[i].view;
		if (view) {
			[view removeFromSuperview];
			[view release];
		}
	}
	free(info);
	infoCount = 0;
}


- (void)prepareGraphViewInfo {
	Database *db = [Database sharedDatabase];

	infoCount = db.latestMonth - db.earliestMonth + 1;
	NSAssert1(infoCount > 0, @"infoCount (%d) must be at least 1", infoCount);
	info = malloc(infoCount * sizeof(struct GraphViewInfo));
	NSAssert(info, @"could not allocate memory for GraphViewInfo");
	
	EWMonth m = db.earliestMonth;
	CGFloat x = 0;
	int i;
	for (i = 0; i < infoCount; i++) {
		CGFloat w = 7 * EWDaysInMonth(m);
		
		info[i].month = m;
		info[i].offsetX = x;
		info[i].width = w; 
		info[i].view = nil;
		
		m += 1;
		x += w;
	}
	
	CGSize totalSize = CGSizeMake(x, 300);
	UIScrollView *scrollView = (id)[self.dataView viewWithTag:kScrollViewTag];
	scrollView.contentSize = totalSize;
}


- (UIView *)loadDataView
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 300)];
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	YAxisView *axisView = [[YAxisView alloc] initWithFrame:CGRectMake(0, 0, 40, 300)];
	axisView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
	[view addSubview:axisView];
	[axisView release];
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(40, 0, 440, 300)];
	scrollView.tag = kScrollViewTag;
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	scrollView.alwaysBounceVertical = NO;
	scrollView.directionalLockEnabled = YES;
	scrollView.delegate = self;
	[view addSubview:scrollView];
	[scrollView release];
		
	return [view autorelease];
}


- (void)dataChanged
{
	[self view]; // make sure view is loaded
	[self clearGraphViewInfo];
	[self prepareGraphViewInfo];
	UIScrollView *scrollView = (id)[self.dataView viewWithTag:kScrollViewTag];
	[self scrollViewDidScroll:scrollView];
	if (firstLoad) {
		CGRect rect = CGRectMake(scrollView.contentSize.width - 1, 0, 1, 1);
		[scrollView scrollRectToVisible:rect animated:NO];
		firstLoad = NO;
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


#pragma mark UIScrollViewDelegate


- (int)indexOfGraphViewInfoAtOffsetX:(CGFloat)x {
	int leftIndex = 0;
	int rightIndex = infoCount;
	while (leftIndex < rightIndex) {
		int index = (leftIndex + rightIndex) / 2;
		CGFloat leftX = info[index].offsetX;
		if (x >= leftX) {
			if (index + 1 == infoCount) {
				// x is to the right of the last view, we're done
				return infoCount - 1;
			} 
			CGFloat rightX = info[index + 1].offsetX;
			if (x < rightX) {
				return index;
			}
			leftIndex = index + 1;
		} else {
			if (index == 0) {
				// x is to the left of the first view, we're done
				return 0;
			}
			rightIndex = index;
		}
	}
	return 0;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	NSParameterAssert(scrollView);
	CGFloat minX = scrollView.contentOffset.x;
	CGFloat maxX = minX + CGRectGetWidth(scrollView.frame);
	int minIndex = [self indexOfGraphViewInfoAtOffsetX:minX];
	int maxIndex = [self indexOfGraphViewInfoAtOffsetX:maxX];
	
	if ((minIndex == lastMinIndex) && (maxIndex == lastMaxIndex)) return;
	
	int index;
	
	// move non-visible views into cache
	for (index = lastMinIndex; index < minIndex; index++) {
		struct GraphViewInfo *ginfo = &info[index];
		if (ginfo->view != nil) {
			[cachedGraphViews addObject:ginfo->view];
			[ginfo->view release];
			ginfo->view = nil;
		}
	}
	for (index = maxIndex + 1; index < lastMaxIndex; index++) {
		struct GraphViewInfo *ginfo = &info[index];
		if (ginfo->view != nil) {
			[cachedGraphViews addObject:ginfo->view];
			[ginfo->view release];
			ginfo->view = nil;
		}
	}
	
	for (index = minIndex; index <= maxIndex; index++) {
		struct GraphViewInfo *ginfo = &info[index];
		if (ginfo->view == nil) {
			GraphView *view = [cachedGraphViews lastObject];
			if (view) {
				[view setMonth:ginfo->month];
				ginfo->view = [view retain];
				[cachedGraphViews removeLastObject];
			} else {
				ginfo->view = [[GraphView alloc] initWithMonth:ginfo->month];
				[scrollView addSubview:ginfo->view];
			}
			[ginfo->view setFrame:CGRectMake(ginfo->offsetX, 0, ginfo->width, 300)];
		}
	}

	lastMinIndex = minIndex;
	lastMaxIndex = maxIndex;
}


@end
