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
#import "EWGoal.h"

enum {
	kScrollViewTag = 100,
	kScaleViewTag,
};


const CGFloat kGraphHeight = 300.0f;
const CGFloat kDayWidth = 7.0f;


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
	
	float goalWeight = [[EWGoal sharedGoal] endWeight];
	parameters.minWeight = MIN([db minimumWeight], goalWeight) - 10.0f;
	parameters.maxWeight = MAX([db maximumWeight], goalWeight) + 10.0f;
	parameters.scaleX = kDayWidth;
	parameters.scaleY = kGraphHeight / (parameters.maxWeight - parameters.minWeight);

	infoCount = db.latestMonth - db.earliestMonth + 1;
	NSAssert1(infoCount > 0, @"infoCount (%d) must be at least 1", infoCount);
	info = malloc(infoCount * sizeof(struct GraphViewInfo));
	NSAssert(info, @"could not allocate memory for GraphViewInfo");
	
	EWMonth m = db.earliestMonth;
	CGFloat x = 0;
	int i;
	for (i = 0; i < infoCount; i++) {
		CGFloat w = kDayWidth * EWDaysInMonth(m);
		
		info[i].month = m;
		info[i].offsetX = x;
		info[i].width = w; 
		info[i].view = nil;
		
		m += 1;
		x += w;
	}
	
	CGSize totalSize = CGSizeMake(x, kGraphHeight);
	UIScrollView *scrollView = (id)[self.dataView viewWithTag:kScrollViewTag];
	scrollView.contentSize = totalSize;
	
	lastMinIndex = 0;
	lastMaxIndex = 0;
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
	if (firstLoad) {
		CGRect rect = CGRectMake(scrollView.contentSize.width - 1, 0, 1, 1);
		[scrollView scrollRectToVisible:rect animated:NO];
		firstLoad = NO;
	} else {
		[self scrollViewDidScroll:scrollView];
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


- (void)cacheViewAtIndex:(int)index {
	struct GraphViewInfo *ginfo = &info[index];
	if (ginfo->view != nil) {
		[cachedGraphViews addObject:ginfo->view];
		[ginfo->view release];
		ginfo->view = nil;
	}
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
	for (index = minIndex - 1; index >= lastMinIndex; index--) {
		[self cacheViewAtIndex:index];
	}
	for (index = maxIndex + 1; index <= lastMaxIndex; index++) {
		[self cacheViewAtIndex:index];
	}

	for (index = minIndex; index <= maxIndex; index++) {
		struct GraphViewInfo *ginfo = &info[index];
		if (ginfo->view == nil) {
			GraphView *view = [cachedGraphViews lastObject];
			if (view) {
				ginfo->view = [view retain];
				[cachedGraphViews removeLastObject];
			} else {
				ginfo->view = [[GraphView alloc] initWithParameters:&parameters];
				// insert subview at the back, so it doesn't overlap the scroll indicator
				[scrollView insertSubview:ginfo->view atIndex:0];
			}
			[ginfo->view setMonth:ginfo->month];
			[ginfo->view setFrame:CGRectMake(ginfo->offsetX, 0, ginfo->width, kGraphHeight)];
		}
	}

	lastMinIndex = minIndex;
	lastMaxIndex = maxIndex;
}


@end
