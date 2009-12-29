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
#import "EWDatabase.h"
#import "YAxisView.h"
#import "EWGoal.h"
#import "LogViewController.h"
#import "NSUserDefaults+EWAdditions.h"
#import "EWWeightFormatter.h"


enum {
	kSpan30Days,
	kSpan90Days,
	kSpanYear,
	kSpanAll,
	kSpanScrolling
};


@implementation GraphViewController


@synthesize axisView;
@synthesize scrollView;
@synthesize spanControl;


- (id)init {
	if ([super initWithNibName:@"GraphView" bundle:nil]) {
		cachedGraphViews = [[NSMutableArray alloc] initWithCapacity:5];
	}
	return self;
}


- (void)dealloc {
	[axisView release];
	[scrollView release];
	[spanControl release];
	[cachedGraphViews release];
	[self clearGraphViewInfo];
	[super dealloc];
}


- (void)clearGraphViewInfo {
	if (info == nil) return;
	[GraphDrawingOperation flushQueue];
	
	if (infoCount > 1) {
		// If we are switching away from the 'Browse' view, save the offset
		scrollingSpanSavedOffset = scrollView.contentOffset;
	}

	int i;
	for (i = 0; i < infoCount; i++) {
		GraphViewInfo *ginfo = &info[i];
		[ginfo->view removeFromSuperview];
		[ginfo->view release];
		CGImageRelease(ginfo->imageRef);
		[ginfo->operation cancel];
		[ginfo->operation release];
	}
	free(info);
	info = NULL;
	infoCount = 0;
	
	[parameters.regions release];
	parameters.regions = nil;
}


#pragma mark Sync Scrolling


- (void)syncScrollViewToLogView {
	EWMonthDay md = [LogViewController currentMonthDay];
	if (md == 0) {
		[scrollView setContentOffset:scrollingSpanSavedOffset animated:NO];
		return;
	}
	
	EWMonth month = EWMonthDayGetMonth(md);
	int i = month - EWMonthDayGetMonth(info[0].beginMonthDay);
	CGFloat offsetDay = EWMonthDayGetDay(md) / EWDaysInMonth(month);

	CGRect scrollRect = scrollView.bounds;
	scrollRect.origin.x = info[i].offsetX + offsetDay;
	[scrollView scrollRectToVisible:scrollRect animated:NO];
	
	[LogViewController setCurrentMonthDay:0];
}


- (void)prepareGraphViewInfo {
	[GraphDrawingOperation flushQueue];

	EWDatabase *db = [EWDatabase sharedDatabase];
	float minWeight, maxWeight;
	EWMonthDay beginMonthDay, endMonthDay;
	
	CGSize size = scrollView.bounds.size;
	NSInteger numberOfDays;

	if (spanControl.selectedSegmentIndex == kSpanScrolling) {
		infoCount = db.latestMonth - db.earliestMonth + 1;
		NSAssert1(infoCount > 0, @"infoCount (%d) must be at least 1", infoCount);
		if (infoCount == 1) {
			numberOfDays = EWDaysInMonth(db.earliestMonth);
		} else {
			numberOfDays = 0;
			size.width = kDayWidth;
		}

		beginMonthDay = 0;
		endMonthDay = 0;
	} else {
		const NSTimeInterval kSecondsPerDay	= 60 * 60 * 24;

		infoCount = 1;

		NSInteger spanIndex = spanControl.selectedSegmentIndex;
		
		if (spanIndex == kSpanAll) {
			[db getEarliestMonthDay:&beginMonthDay latestMonthDay:&endMonthDay];
			if (beginMonthDay == 0 || endMonthDay == 0) {
				beginMonthDay = EWMonthDayToday();
				endMonthDay = beginMonthDay;
			}
			numberOfDays = EWDaysBetweenMonthDays(beginMonthDay, endMonthDay);
		} else {
			if (spanIndex == kSpan30Days) {
				numberOfDays = 30;
			} else if (spanIndex == kSpan90Days) {
				numberOfDays = 90;
			} else { // if (spanIndex == kSpanYear) {
				numberOfDays = 365;
			}
			
			NSTimeInterval t = numberOfDays * kSecondsPerDay;
			endMonthDay = EWMonthDayToday();
			beginMonthDay = EWMonthDayFromDate([NSDate dateWithTimeIntervalSinceNow:-t]);
		}
	}
	
	parameters.shouldDrawNoDataWarning = (infoCount == 1);

	[db getWeightMinimum:&minWeight maximum:&maxWeight from:beginMonthDay to:endMonthDay];

	if (minWeight == 0 || maxWeight == 0) {
		minWeight = 140;
		maxWeight = 160;
	}
	
	parameters.minWeight = minWeight;
	parameters.maxWeight = maxWeight;
		
	[GraphDrawingOperation prepareGraphViewInfo:&parameters 
										forSize:size
								   numberOfDays:numberOfDays];
	
	info = malloc(infoCount * sizeof(GraphViewInfo));
	NSAssert(info, @"could not allocate memory for GraphViewInfo");
	
	if (spanControl.selectedSegmentIndex == kSpanScrolling) {
		EWMonth m = db.earliestMonth;
		CGFloat x = 0;
		int i;
		for (i = 0; i < infoCount; i++) {
			NSInteger days = EWDaysInMonth(m);
			CGFloat w = parameters.scaleX * days;
			
			info[i].beginMonthDay = EWMonthDayMake(m, 1);
			info[i].endMonthDay = EWMonthDayMake(m, days);
			info[i].offsetX = x;
			info[i].width = w; 
			info[i].view = nil;
			info[i].imageRef = NULL;
			info[i].operation = nil;
			
			m += 1;
			x += w;
		}

		scrollView.contentSize = CGSizeMake(x, CGRectGetHeight(scrollView.bounds));
		[self syncScrollViewToLogView];
	} else {
		info[0].beginMonthDay = beginMonthDay;
		info[0].endMonthDay = endMonthDay;
		info[0].offsetX = 0;
		info[0].width = CGRectGetWidth(scrollView.bounds);
		info[0].view = nil;
		info[0].imageRef = NULL;
		info[0].operation = nil;
		
		scrollView.contentSize = scrollView.bounds.size;
		[scrollView setContentOffset:CGPointZero animated:NO];
	}
	
	lastMinIndex = -1;
	lastMaxIndex = 0;
}


- (void)viewDidLoad {
	[axisView useParameters:&parameters];
	spanControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"ChartSelectedSpanIndex"];
}


- (void)databaseDidChange:(NSNotification *)notice {
	[self view]; // make sure view is loaded
	[self clearGraphViewInfo];
	[self prepareGraphViewInfo];
	[axisView setNeedsDisplay];
	[self scrollViewDidScroll:scrollView];
}


- (void)startObservingDatabase {
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(databaseDidChange:) 
												 name:EWDatabaseDidChangeNotification 
											   object:nil];
	[self databaseDidChange:nil];
}


- (void)stopObservingDatabase {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	int index;
	for (index = 0; index < infoCount; index++) {
		GraphViewInfo *ginfo = &info[index];
		if (ginfo->view == nil && ginfo->imageRef != NULL) {
			CGImageRelease(ginfo->imageRef);
			ginfo->imageRef = NULL;
		}
	}
}


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
	return month - EWMonthDayGetMonth(info[0].beginMonthDay);
}


- (void)cacheViewAtIndex:(int)index {
	if (index < 0 || index >= infoCount) return;
	GraphViewInfo *ginfo = &info[index];
	if (ginfo->view != nil) {
		[cachedGraphViews addObject:ginfo->view];
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
	GraphViewInfo *ginfo = &info[index];

	ginfo->view.beginMonthDay = ginfo->beginMonthDay;
	ginfo->view.endMonthDay = ginfo->endMonthDay;
	ginfo->view.p = &parameters;
	ginfo->view.image = ginfo->imageRef;
	[ginfo->view setNeedsDisplay];
	
	if (ginfo->imageRef == NULL && ginfo->operation == nil) {
		GraphDrawingOperation *operation = [[GraphDrawingOperation alloc] init];
		operation.delegate = self;
		operation.index = index;
		operation.p = &parameters;
		operation.bounds = ginfo->view.bounds;
		operation.beginMonthDay = ginfo->beginMonthDay;
		operation.endMonthDay = ginfo->endMonthDay;
		
		ginfo->operation = operation;
		[operation enqueue];
	}
}


- (void)drawingOperationComplete:(GraphDrawingOperation *)operation {
	GraphViewInfo *ginfo = &info[operation.index];
	if (ginfo->operation == operation && ![operation isCancelled]) {
		CGImageRelease(ginfo->imageRef);
		ginfo->imageRef = CGImageRetain(operation.imageRef);
		if (ginfo->view) {
			[ginfo->view setImage:ginfo->imageRef];
			[ginfo->view setNeedsDisplay];
		}
		[ginfo->operation release];
		ginfo->operation = nil;
	}
}


- (void)viewWillAppear:(BOOL)animated {
	[self startObservingDatabase];
}


- (void)viewWillDisappear:(BOOL)animated {
	[self stopObservingDatabase];
}


- (void)viewDidDisappear:(BOOL)animated {
	[self clearGraphViewInfo];
}


- (IBAction)spanSelected:(UISegmentedControl *)sender {
	[self databaseDidChange:nil];
	if (spanControl.selectedSegmentIndex == kSpanScrolling) {
		[scrollView flashScrollIndicators];
	}
	[[NSUserDefaults standardUserDefaults] setInteger:spanControl.selectedSegmentIndex 
											   forKey:@"ChartSelectedSpanIndex"];
}


#pragma mark UIScrollViewDelegate


- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
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

	CGFloat graphHeight = CGRectGetHeight(scrollView.bounds);

	for (index = minIndex; index <= maxIndex; index++) {
		GraphViewInfo *ginfo = &info[index];
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
			[ginfo->view setFrame:CGRectMake(ginfo->offsetX, 0, ginfo->width, graphHeight)];
			[self updateViewAtIndex:index];
		}
	}

	lastMinIndex = minIndex;
	lastMaxIndex = maxIndex;
}


@end
