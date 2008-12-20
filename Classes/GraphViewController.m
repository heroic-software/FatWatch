//
//  GraphViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphDrawingOperation.h"
#import "GraphView.h"
#import "EWDate.h"
#import "Database.h"
#import "YAxisView.h"
#import "EWGoal.h"
#import "WeightFormatters.h"
#import "LogViewController.h"


enum {
	kScrollViewTag = 100,
	kYAxisViewTag,
};


const CGFloat kGraphHeight = 300.0f;
const CGFloat kGraphMarginTop = 32.0f;
const CGFloat kGraphMarginBottom = 16.0f;


@implementation GraphViewController

- (id)init
{
	if (self = [super init]) {
		cachedGraphViews = [[NSMutableArray alloc] initWithCapacity:5];
		queue = [[NSOperationQueue alloc] init];
		self.title = NSLocalizedString(@"GRAPH_VIEW_TITLE", nil);
	}
	return self;
}


- (void)dealloc {
	[queue release];
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
	[queue waitUntilAllOperationsAreFinished];
	
	int i;
	for (i = 0; i < infoCount; i++) {
		UIView *view = info[i].view;
		if (view) {
			[view removeFromSuperview];
			[view release];
		}
		UIImage *image = info[i].image;
		if (image) {
			[image release];
		}
		GraphDrawingOperation *operation = info[i].operation;
		if (operation) {
			[operation cancel];
			[operation release];
		}
	}
	free(info);
	infoCount = 0;
	
	[parameters.regions release];
	parameters.regions = nil;
}


- (void)prepareGraphViewInfo {
	[queue waitUntilAllOperationsAreFinished];

	Database *db = [Database sharedDatabase];
	
	infoCount = db.latestMonth - db.earliestMonth + 1;
	NSAssert1(infoCount > 0, @"infoCount (%d) must be at least 1", infoCount);

	float goalWeight = [[EWGoal sharedGoal] endWeight];
	float minWeight, maxWeight;
	if (goalWeight > 0) {
		minWeight = MIN([db minimumWeight], goalWeight);
		maxWeight = MAX([db maximumWeight], goalWeight);
	} else {
		minWeight = [db minimumWeight];
		maxWeight = [db maximumWeight];
	}
	
	if (infoCount == 1) {
		UIScrollView *scrollView = (id)[self.dataView viewWithTag:kScrollViewTag];
		parameters.scaleX = CGRectGetWidth(scrollView.bounds) / EWDaysInMonth(db.earliestMonth);
	} else {
		parameters.scaleX = kDayWidth;
	}
	
	parameters.scaleY = (kGraphHeight - (kGraphMarginTop + kGraphMarginBottom)) / (maxWeight - minWeight);
	parameters.minWeight = minWeight - (kGraphMarginBottom / parameters.scaleY);
	parameters.maxWeight = maxWeight + (kGraphMarginTop / parameters.scaleY);
	
	if ([EWGoal isBMIEnabled]) {
		float w0 = [WeightFormatters weightForBodyMassIndex:18.5];
		float w1 = [WeightFormatters weightForBodyMassIndex:25.0];
		float w2 = [WeightFormatters weightForBodyMassIndex:30.0];
		
		CGFloat width = 32; // at most 31 days in a month

		NSMutableArray *regions = [NSMutableArray arrayWithCapacity:4];

		CGRect rect;
		UIColor *color;
		
		CGRect wholeRect = CGRectMake(0, parameters.minWeight, width, parameters.maxWeight - parameters.minWeight);
		
		if (w0 > parameters.minWeight) {
			rect = CGRectMake(0, parameters.minWeight, width, w0 - parameters.minWeight);
			rect = CGRectIntersection(wholeRect, rect);
			if (!CGRectIsEmpty(rect)) {
				color = [WeightFormatters backgroundColorForWeight:parameters.minWeight];
				[regions addObject:[NSArray arrayWithObjects:[NSValue valueWithCGRect:rect], color, nil]];
			}
		}
		
		rect = CGRectMake(0, w0, width, w1 - w0);
		rect = CGRectIntersection(wholeRect, rect);
		if (!CGRectIsEmpty(rect)) {
			color = [WeightFormatters backgroundColorForWeight:0.5f*(w0+w1)];
			[regions addObject:[NSArray arrayWithObjects:[NSValue valueWithCGRect:rect], color, nil]];
		}
		
		rect = CGRectMake(0, w1, width, w2 - w1);
		rect = CGRectIntersection(wholeRect, rect);
		if (!CGRectIsEmpty(rect)) {
			color = [WeightFormatters backgroundColorForWeight:0.5f*(w1+w2)];
			[regions addObject:[NSArray arrayWithObjects:[NSValue valueWithCGRect:rect], color, nil]];
		}
		
		if (w2 < parameters.maxWeight) {
			rect = CGRectMake(0, w2, width, parameters.maxWeight - w2);
			rect = CGRectIntersection(wholeRect, rect);
			if (!CGRectIsEmpty(rect)) {
				color = [WeightFormatters backgroundColorForWeight:parameters.maxWeight];
				[regions addObject:[NSArray arrayWithObjects:[NSValue valueWithCGRect:rect], color, nil]];
			}
		}
				
		parameters.regions = [regions copy];
	}
	
	float increment = [WeightFormatters chartWeightIncrement];
	while (parameters.scaleY * increment < [UIFont systemFontSize]) {
		increment = [WeightFormatters chartWeightIncrementAfter:increment];
	}
	parameters.gridIncrementWeight = increment;
	parameters.gridMinWeight = roundf(parameters.minWeight / increment) * increment;
	parameters.gridMaxWeight = roundf(parameters.maxWeight / increment) * increment;
	
	CGAffineTransform t = CGAffineTransformMakeTranslation(0, kGraphHeight);
	t = CGAffineTransformScale(t, parameters.scaleX, -parameters.scaleY);
	t = CGAffineTransformTranslate(t, -0.5, -parameters.minWeight);
	parameters.t = t;
	
	info = malloc(infoCount * sizeof(struct GraphViewInfo));
	NSAssert(info, @"could not allocate memory for GraphViewInfo");
	
	EWMonth m = db.earliestMonth;
	CGFloat x = 0;
	int i;
	for (i = 0; i < infoCount; i++) {
		CGFloat w = parameters.scaleX * EWDaysInMonth(m);
		
		info[i].month = m;
		info[i].offsetX = x;
		info[i].width = w; 
		info[i].view = nil;
		info[i].image = nil;
		info[i].operation = nil;
		
		m += 1;
		x += w;
	}
	
	CGSize totalSize = CGSizeMake(x, kGraphHeight);
	UIScrollView *scrollView = (id)[self.dataView viewWithTag:kScrollViewTag];
	scrollView.contentSize = totalSize;
	
	lastMinIndex = -1;
	lastMaxIndex = 0;
}


- (UIView *)loadDataView
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 300)];
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	const CGFloat axisViewWidth = 40;
	
	YAxisView *axisView = [[YAxisView alloc] initWithParameters:&parameters];
	axisView.tag = kYAxisViewTag;
	axisView.frame = CGRectMake(0, 0, axisViewWidth, 300);
	axisView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
	[view addSubview:axisView];
	[axisView release];
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(axisViewWidth, 0, 480 - axisViewWidth, 300)];
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
	[[self.dataView viewWithTag:kYAxisViewTag] setNeedsDisplay];
	UIScrollView *scrollView = (id)[self.dataView viewWithTag:kScrollViewTag];
	[self scrollViewDidScroll:scrollView];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	int index;
	for (index = 0; index < infoCount; index++) {
		struct GraphViewInfo *ginfo = &info[index];
		if (ginfo->view == nil && ginfo->image != nil) {
			[ginfo->image release];
			ginfo->image = nil;
		}
	}
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


- (int)indexOfGraphViewInfoForMonth:(EWMonth)month {
	return month - info[0].month;
}


- (void)cacheViewAtIndex:(int)index {
	if (index < 0 || index >= infoCount) return;
	struct GraphViewInfo *ginfo = &info[index];
	if (ginfo->view != nil) {
		[cachedGraphViews addObject:ginfo->view];
		[ginfo->view setMonth:0];
		[ginfo->view setImage:nil];
		[ginfo->view release];
		ginfo->view = nil;

		// if we haven't started rendering, don't bother
		if (ginfo->operation != nil && ![ginfo->operation isExecuting]) {
			[ginfo->operation cancel];
			[ginfo->operation release];
			ginfo->operation = nil;
		}
	}
}


- (void)updateViewAtIndex:(int)index {
	struct GraphViewInfo *ginfo = &info[index];

	[ginfo->view setMonth:ginfo->month];
	[ginfo->view setImage:ginfo->image];
	
	if (ginfo->image == nil && ginfo->operation == nil) {
		[ginfo->view setImage:nil];
		
		GraphDrawingOperation *operation = [[GraphDrawingOperation alloc] init];
		operation.delegate = self;
		operation.index = index;
		operation.month = ginfo->month;
		operation.p = &parameters;
		operation.bounds = ginfo->view.bounds;
		
		ginfo->operation = operation;
		[queue addOperation:operation];
	}
}


- (void)drawingOperationComplete:(GraphDrawingOperation *)operation {
	struct GraphViewInfo *ginfo = &info[operation.index];
	ginfo->image = [operation.image retain];
	ginfo->operation = nil;
	if (ginfo->view) {
		[ginfo->view setImage:ginfo->image];
	}
	[operation release];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	NSParameterAssert(scrollView);
	CGFloat minX = scrollView.contentOffset.x;
	CGFloat maxX = minX + CGRectGetWidth(scrollView.frame);
	int minIndex = [self indexOfGraphViewInfoAtOffsetX:minX];
	int maxIndex = [self indexOfGraphViewInfoAtOffsetX:maxX];
	
	// Stop now if the visible set of months hasn't changed.
	if ((minIndex == lastMinIndex) && (maxIndex == lastMaxIndex)) {
		// But, if this is the first time through, keep going.
		if (lastMinIndex < 0) {
			lastMinIndex = 0;
		} else {
			return;
		}
	}
	
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
				ginfo->view = [[GraphView alloc] init];
				// insert subview at the back, so it doesn't overlap the scroll indicator
				[scrollView insertSubview:ginfo->view atIndex:0];
			}
			[ginfo->view setFrame:CGRectMake(ginfo->offsetX, 0, ginfo->width, kGraphHeight)];
			[self updateViewAtIndex:index];
		}
	}

	lastMinIndex = minIndex;
	lastMaxIndex = maxIndex;
}


#pragma mark Sync Scrolling


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (info != nil) {
		UIScrollView *scrollView = (id)[self.dataView viewWithTag:kScrollViewTag];
		EWMonthDay monthday = [LogViewController currentMonthDay];
		int i = [self indexOfGraphViewInfoForMonth:EWMonthDayGetMonth(monthday)];
		if (i + 1 == infoCount) {
			CGRect rect = CGRectMake(scrollView.contentSize.width - 1, 0, 1, 1);
			[scrollView scrollRectToVisible:rect animated:NO];
		} else {
			CGFloat dayX = parameters.scaleX * (EWMonthDayGetDay(monthday) - 1);
			CGFloat x = info[i].offsetX + dayX;
			CGFloat width = CGRectGetWidth(scrollView.bounds);
			CGRect rect = CGRectMake(x - width, 0, width, 1);
			[scrollView scrollRectToVisible:rect animated:NO];
		}
	}
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if (info != nil) {
		UIScrollView *scrollView = (id)[self.dataView viewWithTag:kScrollViewTag];
		CGFloat minX = scrollView.contentOffset.x;
		CGFloat x = minX + CGRectGetWidth(scrollView.bounds);
		int i = [self indexOfGraphViewInfoAtOffsetX:x];
		EWDay day = 1 + floorf((x - info[i].offsetX) / parameters.scaleX);
		EWMonthDay monthday = EWMonthDayMake(info[i].month, day);
		[LogViewController setCurrentMonthDay:monthday];
	}
}

@end
