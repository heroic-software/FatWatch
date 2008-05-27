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
		self.title = NSLocalizedString(@"GRAPH_VIEW_TITLE", nil);
	}
	return self;
}


- (NSString *)message
{
	return NSLocalizedString(@"NO_DATA_FOR_GRAPH", nil);
}


- (void)removeGraphViews {
	for (UIView *subview in [self.dataView subviews]) {
		if ([subview isKindOfClass:[GraphView class]]) {
			[subview removeFromSuperview];
		}
	}
}


- (void)addGraphViewsToView:(UIScrollView *)scrollView {
	CGSize totalSize = CGSizeMake(0, 300);
	Database *db = [Database sharedDatabase];
	NSUInteger monthCount = MAX(1, db.latestMonth - db.earliestMonth + 1);

	int i;
	CGRect subviewFrame = CGRectMake(0, 0, 0, totalSize.height);
	for (i = 0; i < monthCount; i++) {
		EWMonth month = (db.earliestMonth + i);
		subviewFrame.size.width = 7 * EWDaysInMonth(month);
		GraphView *view = [[GraphView alloc] initWithMonth:month];
		view.frame = subviewFrame;
		[scrollView addSubview:view];
		[view release];
		subviewFrame.origin.x += subviewFrame.size.width;
		totalSize.width += subviewFrame.size.width;
	}
	
	scrollView.contentSize = totalSize;
}


- (UIView *)loadDataView
{
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 480, 300)];
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	scrollView.alwaysBounceVertical = NO;
	scrollView.directionalLockEnabled = YES;
	
	[self addGraphViewsToView:scrollView];
	
	return [scrollView autorelease];
}


- (void)dataChanged
{
	UIScrollView *scrollView = (UIScrollView *)self.dataView;
	[self removeGraphViews];
	[self addGraphViewsToView:scrollView];
	if (firstLoad) {
		CGRect rect = CGRectMake(scrollView.contentSize.width - 1, 0, 1, 1);
		[scrollView scrollRectToVisible:rect animated:NO];
		firstLoad = NO;
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
