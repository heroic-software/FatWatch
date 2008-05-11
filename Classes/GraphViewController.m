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

@implementation GraphViewController

- (id)init
{
	if (self = [super init]) {
		firstLoad = YES;
		self.title = @"Graph";
	}
	return self;
}


- (NSString *)message
{
	return @"Not enough data to draw a graph. Try again tomorrow.";
}


- (UIView *)loadDataView
{
	// View for the graph

	EWMonth earliestMonth = [[Database sharedDatabase] earliestMonth];
	EWMonth currentMonth = EWMonthFromDate([NSDate date]);
	NSUInteger monthCount = MAX(1, currentMonth - earliestMonth + 1);
	
	CGSize totalSize = CGSizeMake(0, 300);
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 480, 300)];
	scrollView.alwaysBounceVertical = NO;
	scrollView.directionalLockEnabled = YES;
	
	int i;
	CGRect subviewFrame = CGRectMake(0, 0, 0, totalSize.height);
	for (i = 0; i < monthCount; i++) {
		EWMonth month = (earliestMonth + i);
		subviewFrame.size.width = 5 * EWDaysInMonth(month);
		GraphView *view = [[GraphView alloc] initWithMonth:month];
		view.frame = subviewFrame;
		[scrollView addSubview:view];
		[view release];
		subviewFrame.origin.x += subviewFrame.size.width;
		totalSize.width += subviewFrame.size.width;
	}
	
	scrollView.contentSize = totalSize;
	
	return [scrollView autorelease];
}


- (void)dataChanged
{
	UIScrollView *scrollView = (UIScrollView *)self.dataView;
	if (firstLoad) {
		CGRect rect = CGRectMake(scrollView.contentSize.width - 1, 0, 1, 1);
		[scrollView scrollRectToVisible:rect animated:NO];
		firstLoad = NO;
	}
	[[scrollView subviews] makeObjectsPerformSelector:@selector(setNeedsDisplay)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}

@end
