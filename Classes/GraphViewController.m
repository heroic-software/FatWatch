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
	kSpan30Days,
	kSpan90Days,
	kSpanYear,
	kSpanAll,
	kSpanScrolling
};

const CGFloat kGraphMarginTop = 32.0f;
const CGFloat kGraphMarginBottom = 16.0f;


@implementation GraphViewController

- (id)init {
	if ([super initWithNibName:@"GraphView" bundle:nil]) {
		cachedGraphViews = [[NSMutableArray alloc] initWithCapacity:5];
		queue = [[NSOperationQueue alloc] init];
	}
	return self;
}


- (void)dealloc {
	[queue release];
	[cachedGraphViews release];
	[self clearGraphViewInfo];
	[super dealloc];
}


- (void)clearGraphViewInfo {
	if (info == nil) return;
	[queue cancelAllOperations];
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


- (void)prepareBMIRegions {
	if (! [EWGoal isBMIEnabled]) return;

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


- (void)prepareGraphViewInfo {
	[queue cancelAllOperations];
	[queue waitUntilAllOperationsAreFinished];

	Database *db = [Database sharedDatabase];
	float minWeight, maxWeight;
	EWMonthDay beginMonthDay, endMonthDay;
	
	if (spanControl.selectedSegmentIndex == kSpanScrolling) {
		infoCount = db.latestMonth - db.earliestMonth + 1;
		NSAssert1(infoCount > 0, @"infoCount (%d) must be at least 1", infoCount);
		if (infoCount == 1) {
			parameters.scaleX = CGRectGetWidth(scrollView.bounds) / EWDaysInMonth(db.earliestMonth);
		} else {
			parameters.scaleX = kDayWidth;
		}
		beginMonthDay = 0;
		endMonthDay = 0;
	} else {
		infoCount = 1;

		NSInteger spanIndex = spanControl.selectedSegmentIndex;
		NSTimeInterval t;
		
		if (spanIndex == kSpan30Days) {
			t = 30 * (60 * 60 * 24);
		} else if (spanIndex == kSpan90Days) {
			t = 90 * (60 * 60 * 24);
		} else if (spanIndex == kSpanYear) {
			t = 365 * (60 * 60 * 24);
		} else {
			// TODO: "earliest month with data"
			NSDate *earlyDate = EWDateFromMonthAndDay(db.earliestMonth, 1);
			t = -[earlyDate timeIntervalSinceNow];
		}
		
		NSInteger numberOfDays = t / (60 * 60 * 24);
		parameters.scaleX = CGRectGetWidth(scrollView.bounds) / (numberOfDays + 1);
		
		endMonthDay = EWMonthDayFromDate([NSDate date]);
		beginMonthDay = EWMonthDayFromDate([NSDate dateWithTimeIntervalSinceNow:-t]);
	}
	
	[db getWeightMinimum:&minWeight maximum:&maxWeight from:beginMonthDay to:endMonthDay];

	if (minWeight == 0 || maxWeight == 0) {
		minWeight = 140;
		maxWeight = 160;
	}
	
	/*
	float goalWeight = [[EWGoal sharedGoal] endWeight];
	if (goalWeight > 0) {
		if (goalWeight < minWeight) minWeight = goalWeight;
		if (goalWeight > maxWeight) maxWeight = goalWeight;
	}
	*/
	
	if ((maxWeight - minWeight) < 0.01) {
		minWeight -= 1;
		maxWeight += 1;
	}
	
	const CGFloat graphHeight = CGRectGetHeight(scrollView.bounds);
	
	parameters.scaleY = (graphHeight - (kGraphMarginTop + kGraphMarginBottom)) / (maxWeight - minWeight);
	parameters.minWeight = minWeight - (kGraphMarginBottom / parameters.scaleY);
	parameters.maxWeight = maxWeight + (kGraphMarginTop / parameters.scaleY);

	[self prepareBMIRegions];
	
	float increment = [WeightFormatters chartWeightIncrement];
	while (parameters.scaleY * increment < [UIFont systemFontSize]) {
		increment = [WeightFormatters chartWeightIncrementAfter:increment];
	}
	parameters.gridIncrementWeight = increment;
	parameters.gridMinWeight = roundf(parameters.minWeight / increment) * increment;
	parameters.gridMaxWeight = roundf(parameters.maxWeight / increment) * increment;
	
	CGAffineTransform t = CGAffineTransformMakeTranslation(0, graphHeight);
	t = CGAffineTransformScale(t, parameters.scaleX, -parameters.scaleY);
	t = CGAffineTransformTranslate(t, -0.5, -parameters.minWeight);
	parameters.t = t;
	
	info = malloc(infoCount * sizeof(struct GraphViewInfo));
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
			info[i].image = nil;
			info[i].operation = nil;
			
			m += 1;
			x += w;
		}

		CGSize totalSize = CGSizeMake(x, graphHeight);
		scrollView.contentSize = totalSize;
	} else {
		info[0].beginMonthDay = beginMonthDay;
		info[0].endMonthDay = endMonthDay;
		info[0].offsetX = 0;
		info[0].width = CGRectGetWidth(scrollView.bounds);
		info[0].view = nil;
		info[0].image = nil;
		info[0].operation = nil;
		
		scrollView.contentSize = scrollView.bounds.size;
	}
	
	lastMinIndex = -1;
	lastMaxIndex = 0;
}


- (void)viewDidLoad {
	[axisView useParameters:&parameters];
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
	return month - EWMonthDayGetMonth(info[0].beginMonthDay);
}


- (void)cacheViewAtIndex:(int)index {
	if (index < 0 || index >= infoCount) return;
	struct GraphViewInfo *ginfo = &info[index];
	if (ginfo->view != nil) {
		[cachedGraphViews addObject:ginfo->view];
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

	[ginfo->view setBeginMonthDay:ginfo->beginMonthDay endMonthDay:ginfo->endMonthDay];
	[ginfo->view setImage:ginfo->image];
	
	if (ginfo->image == nil && ginfo->operation == nil) {
		[ginfo->view setImage:nil];
		
		GraphDrawingOperation *operation = [[GraphDrawingOperation alloc] init];
		operation.delegate = self;
		operation.index = index;
		operation.p = &parameters;
		operation.bounds = ginfo->view.bounds;
		operation.beginMonthDay = ginfo->beginMonthDay;
		operation.endMonthDay = ginfo->endMonthDay;
		
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
			[ginfo->view setFrame:CGRectMake(ginfo->offsetX, 0, ginfo->width, graphHeight)];
			[self updateViewAtIndex:index];
		}
	}

	lastMinIndex = minIndex;
	lastMaxIndex = maxIndex;
}


#pragma mark Sync Scrolling


- (void)viewWillAppear:(BOOL)animated {
	[self startObservingDatabase];
}


- (void)viewWillDisappear:(BOOL)animated {
	[self stopObservingDatabase];
}


- (IBAction)spanSelected:(UISegmentedControl *)sender {
	[self databaseDidChange:nil];
}

@end
