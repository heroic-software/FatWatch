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
#import "NSUserDefaults+EWAdditions.h"
#import "EWWeightFormatter.h"
#import "EWGoal.h"
#import "GraphSegment.h"


enum {
	kSpan30Days,
	kSpan90Days,
	kSpanYear,
	kSpanAll,
	kSpanScrolling
};


static NSString * const kSelectedSpanIndexKey = @"ChartSelectedSpanIndex";
static NSString * const kShowFatKey = @"ChartShowFat";


@interface GraphViewController ()
- (NSInteger)indexOfGraphViewInfoAtOffsetX:(CGFloat)x;
- (NSInteger)indexOfGraphViewInfoForMonth:(EWMonth)month;
@end



@implementation GraphViewController


@synthesize database;
@synthesize axisView;
@synthesize scrollView;
@synthesize spanControl;
@synthesize typeControl;
@synthesize actionButtonItem;


- (void)awakeFromNib {
	cachedGraphViews = [[NSMutableArray alloc] initWithCapacity:5];
}


- (void)dealloc {
	[database release];
	[axisView release];
	[scrollView release];
	[spanControl release];
	[cachedGraphViews release];
	[self clearGraphSegments];
	[super dealloc];
}


- (void)clearGraphSegments {
	if (graphSegments == nil) return;
	[GraphDrawingOperation flushQueue];
	
	if ([graphSegments count] > 1) {
		CGFloat offsetX = scrollView.contentOffset.x;
		NSInteger k = [self indexOfGraphViewInfoAtOffsetX:offsetX];
        GraphSegment *segment = graphSegments[k];
		scrollingSpanSavedMonth = EWMonthDayGetMonth(segment.beginMonthDay);
		scrollingSpanSavedOffsetX = offsetX - segment.offsetX;
	}

    [graphSegments release];
    graphSegments = nil;
	
	[parameters.regions release];
	parameters.regions = nil;
}


#pragma mark Sync Scrolling


- (void)prepareGraphViewInfo {
	static const NSTimeInterval kSecondsPerDay = 60 * 60 * 24;

	[GraphDrawingOperation flushQueue];

	float minWeight, maxWeight;
	EWMonthDay beginMonthDay, endMonthDay;
	
	EWDatabaseFilter filter = parameters.showFatWeight ? EWDatabaseFilterWeightAndFat : EWDatabaseFilterWeight;
	[database getEarliestMonthDay:&beginMonthDay latestMonthDay:&endMonthDay filter:filter];
	if (beginMonthDay == 0 || endMonthDay == 0) {
		beginMonthDay = EWMonthDayToday();
		endMonthDay = beginMonthDay;
	}
	
	CGSize size = scrollView.bounds.size;
	NSInteger numberOfDays;
    NSUInteger infoCount;

	NSInteger spanIndex = spanControl.selectedSegmentIndex;
	if (spanIndex == kSpanScrolling) {
		infoCount = EWMonthDayGetMonth(endMonthDay) - EWMonthDayGetMonth(beginMonthDay) + 1;
		NSAssert1(infoCount > 0, @"infoCount (%d) must be at least 1", infoCount);
		if (infoCount == 1) {
			parameters.scaleX = size.width / EWDaysInMonth(EWMonthDayGetMonth(beginMonthDay));
		} else {
			parameters.scaleX = kDayWidth;
		}
		numberOfDays = 0; // do not set scaleX
		endMonthDay = 0; // useful hint to getWeightMinimum:maximum:
	} else {
		infoCount = 1;
		if (spanIndex == kSpanAll) {
			numberOfDays = 1 + EWDaysBetweenMonthDays(beginMonthDay, endMonthDay);
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
	
	[database getWeightMinimum:&minWeight maximum:&maxWeight 
					   onlyFat:parameters.showFatWeight
						  from:beginMonthDay to:endMonthDay];
	
	if (minWeight == 0 || maxWeight == 0) {
		minWeight = 150;
		maxWeight = 150;
	}
	
	if (!parameters.showFatWeight) {
		if ([[NSUserDefaults standardUserDefaults] fitGoalOnChart]) {
			EWGoal *goal = [[EWGoal alloc] initWithDatabase:database];
			if (goal.defined) {
				minWeight = MIN(minWeight, goal.endWeight);
				maxWeight = MAX(maxWeight, goal.endWeight);
			}
			[goal release];
		}
	}
	
	parameters.minWeight = minWeight;
	parameters.maxWeight = maxWeight;
		
	[GraphDrawingOperation prepareGraphViewInfo:&parameters 
										forSize:size
								   numberOfDays:numberOfDays
									   database:database];

	if (spanIndex == kSpanScrolling) {
		EWMonth m = EWMonthDayGetMonth(beginMonthDay);
		CGFloat x = 0;
        NSMutableArray *info = [[NSMutableArray alloc] initWithCapacity:infoCount];
		for (NSUInteger i = 0; i < infoCount; i++) {
			NSInteger days = EWDaysInMonth(m);
			CGFloat w = parameters.scaleX * days;

			GraphSegment *segment = [[GraphSegment alloc] init];
            {
                segment.beginMonthDay = EWMonthDayMake(m, 1);
                segment.endMonthDay = EWMonthDayMake(m, days);
                segment.offsetX = x;
                segment.width = w;
                segment.view = nil;
                segment.imageRef = NULL;
                segment.operation = nil;
            }
            [info addObject:segment];
            [segment release];
			m += 1;
			x += w;
		}
        graphSegments = [info copy];
        [info release];
		
		CGFloat offsetX;
		if (scrollingSpanSavedOffsetX < 0) {
			offsetX = x - CGRectGetWidth(scrollView.bounds);
		} else {
			NSInteger k = [self indexOfGraphViewInfoForMonth:scrollingSpanSavedMonth];
            GraphSegment *segment = graphSegments[k];
			offsetX = segment.offsetX + scrollingSpanSavedOffsetX;
		}
		scrollView.contentSize = CGSizeMake(x, CGRectGetHeight(scrollView.bounds));
		[scrollView setContentOffset:CGPointMake(offsetX, 0) animated:NO];
	} else {
        GraphSegment *segment = [[GraphSegment alloc] init];
		segment.beginMonthDay = beginMonthDay;
		segment.endMonthDay = endMonthDay;
		segment.offsetX = 0;
		segment.width = CGRectGetWidth(scrollView.bounds);
		segment.view = nil;
		segment.imageRef = NULL;
		segment.operation = nil;
        graphSegments = [@[ segment ] retain];
        [segment release];
		
		scrollView.contentSize = scrollView.bounds.size;
		[scrollView setContentOffset:CGPointZero animated:NO];
	}

	lastMinIndex = -1;
	lastMaxIndex = 0;
}


- (void)viewDidLoad {
	isLoading = YES; // prevents segmented controls from calling databaseDidChange:
	axisView.database = database;
	[axisView useParameters:&parameters];
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	spanControl.selectedSegmentIndex = [defs integerForKey:kSelectedSpanIndexKey];
	parameters.showFatWeight = [defs boolForKey:kShowFatKey];
	typeControl.selectedSegmentIndex = parameters.showFatWeight ? 1 : 0;
	[axisView sizeToFit];
	// adjust width of scrollView to be flush against axisView
	CGRect frame = scrollView.frame;
	CGFloat axisViewWidth = CGRectGetWidth(axisView.frame);
	CGFloat totalWidth = CGRectGetWidth(self.view.bounds);
	frame.origin.x = axisViewWidth;
	frame.size.width = totalWidth - axisViewWidth;
	scrollView.frame = frame;
	scrollingSpanSavedOffsetX = -1; // indicate first load
	isLoading = NO;
}


- (void)databaseDidChange:(NSNotification *)notice {
	[self view]; // make sure view is loaded
	[self clearGraphSegments];
	[self prepareGraphViewInfo];
	[axisView setNeedsDisplay];
	[self scrollViewDidScroll:scrollView];
	actionButtonItem.enabled = ([graphSegments count] == 1);
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
    for (GraphSegment *segment in graphSegments) {
        if (segment.view == nil && segment.imageRef != NULL) {
            segment.imageRef = NULL;
        }
    }
}


- (NSInteger)indexOfGraphViewInfoAtOffsetX:(CGFloat)x {
	int leftIndex = 0;
	int rightIndex = [graphSegments count];
	while (leftIndex < rightIndex) {
		unsigned int i = (leftIndex + rightIndex) / 2;
		CGFloat leftX = ((GraphSegment *)graphSegments[i]).offsetX;
		if (x >= leftX) {
			if (i + 1 == [graphSegments count]) {
				// x is to the right of the last view, we're done
				return [graphSegments count] - 1;
			} 
			CGFloat rightX = ((GraphSegment *)graphSegments[i + 1]).offsetX;
			if (x < rightX) {
				return i;
			}
			leftIndex = i + 1;
		} else {
			if (index == 0) {
				// x is to the left of the first view, we're done
				return 0;
			}
			rightIndex = i;
		}
	}
	return 0;
}


- (NSInteger)indexOfGraphViewInfoForMonth:(EWMonth)month {
    GraphSegment *segment0 = graphSegments[0];
	NSInteger i = (month - EWMonthDayGetMonth(segment0.beginMonthDay));
    return MINMAX(0, i, (NSInteger)[graphSegments count] - 1);
}


- (void)cacheViewAtIndex:(unsigned int)i {
	if (i >= [graphSegments count]) return;
    GraphSegment *segment = graphSegments[i];
	if (segment.view != nil) {
		[cachedGraphViews addObject:segment.view];
		segment.view = nil;
		// if we haven't started rendering, don't bother
		if (segment.operation != nil && ![segment.operation isExecuting]) {
			[segment.operation cancel];
			segment.operation = nil;
		}
	}
}


- (void)updateViewAtIndex:(unsigned int)i {
    GraphSegment *segment = graphSegments[i];

	segment.view.beginMonthDay = segment.beginMonthDay;
	segment.view.endMonthDay = segment.endMonthDay;
	segment.view.p = &parameters;
	segment.view.image = segment.imageRef;
	[segment.view setNeedsDisplay];
	
	if (segment.imageRef == NULL && segment.operation == nil) {
		GraphDrawingOperation *operation = [[GraphDrawingOperation alloc] init];
		operation.database = database;
		operation.delegate = self;
		operation.index = i;
		operation.p = &parameters;
		operation.bounds = segment.view.bounds;
		operation.beginMonthDay = segment.beginMonthDay;
		operation.endMonthDay = segment.endMonthDay;
		operation.showGoalLine = (i == [graphSegments count] - 1);
		operation.showTrajectoryLine = ([graphSegments count] == 1);
		
		segment.operation = operation;
		[operation enqueue];
	}
}


- (void)drawingOperationComplete:(GraphDrawingOperation *)operation {
	// This method may be called after info has been deallocated. Be careful!
	if (graphSegments == nil) return;
	if ([graphSegments count] <= operation.index) return;
    GraphSegment *segment = graphSegments[operation.index];
	if (segment.operation == operation && ![operation isCancelled]) {
		segment.imageRef = operation.imageRef;
		if (segment.view) {
			[segment.view setImage:segment.imageRef];
			[segment.view setNeedsDisplay];
		}
		segment.operation = nil;
	}
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self startObservingDatabase];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self stopObservingDatabase];
}


- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self clearGraphSegments];
}


- (IBAction)spanSelected:(UISegmentedControl *)sender {
	if (isLoading) return;
	[self databaseDidChange:nil];
	if (spanControl.selectedSegmentIndex == kSpanScrolling) {
		[scrollView flashScrollIndicators];
	}
	[[NSUserDefaults standardUserDefaults] setInteger:spanControl.selectedSegmentIndex 
											   forKey:kSelectedSpanIndexKey];
}


- (IBAction)typeSelected:(UISegmentedControl *)sender {
	if (isLoading) return;
	parameters.showFatWeight = (typeControl.selectedSegmentIndex == 1);
	[self databaseDidChange:nil];
	[[NSUserDefaults standardUserDefaults] setBool:parameters.showFatWeight 
											forKey:kShowFatKey];
}


- (IBAction)showActionMenu:(UIBarButtonItem *)sender {
	if ([graphSegments count] != 1) return;
	UIActionSheet *menu = [[UIActionSheet alloc] init];
	menu.delegate = self;
	saveButtonIndex = [menu addButtonWithTitle:@"Save Image"];
	copyButtonIndex = [menu addButtonWithTitle:@"Copy"];
	menu.cancelButtonIndex = [menu addButtonWithTitle:@"Cancel"];
	[menu showInView:self.view];
	[menu release];
}


#pragma mark UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) return;
    GraphSegment *segment0 = graphSegments[0];
	if (saveButtonIndex == buttonIndex) {
		[segment0.view exportImageToSavedPhotos];
	}
	else if (copyButtonIndex == buttonIndex) {
		[segment0.view exportImageToPasteboard];
	}
}


#pragma mark UIScrollViewDelegate


- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
	CGFloat minX = scrollView.contentOffset.x;
	CGFloat maxX = minX + CGRectGetWidth(scrollView.frame);
	NSInteger minIndex = [self indexOfGraphViewInfoAtOffsetX:minX];
	NSInteger maxIndex = [self indexOfGraphViewInfoAtOffsetX:maxX];
	
	// Stop now if the visible set of months hasn't changed.
	if ((minIndex == lastMinIndex) && (maxIndex == lastMaxIndex)) {
		// But, if this is the first time through, keep going.
		if (lastMinIndex < 0) {
			lastMinIndex = 0;
		} else {
			return;
		}
	}
	
	// move non-visible views into cache
	for (NSInteger i = minIndex - 1; i >= lastMinIndex; i--) {
		[self cacheViewAtIndex:i];
	}
	for (NSInteger i = maxIndex + 1; i <= lastMaxIndex; i++) {
		[self cacheViewAtIndex:i];
	}

	CGFloat graphHeight = CGRectGetHeight(scrollView.bounds);

	for (NSInteger i = minIndex; i <= maxIndex; i++) {
        GraphSegment *segment = graphSegments[i];
		if (segment.view == nil) {
			GraphView *view = [cachedGraphViews lastObject];
			if (view) {
				segment.view = view;
				[cachedGraphViews removeLastObject];
			} else {
				segment.view = [[[GraphView alloc] init] autorelease];
				segment.view.yAxisView = axisView;
				// insert subview at the back, so it doesn't overlap the scroll indicator
				[scrollView insertSubview:segment.view atIndex:0];
			}
			[segment.view setFrame:CGRectMake(segment.offsetX, 0, segment.width, graphHeight)];
			[self updateViewAtIndex:i];
		}
	}

	lastMinIndex = minIndex;
	lastMaxIndex = maxIndex;
}


@end
