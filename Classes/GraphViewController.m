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

- (id)initWithDatabase:(Database *)db
{
	if (self = [super init]) {
		database = db;
		
		self.title = @"Graph";
	}
	return self;
}


- (void)loadView
{
	EWMonth earliestMonth = [database earliestMonth];
	EWMonth currentMonth = EWMonthFromDate([NSDate date]);
	
	NSUInteger monthCount = MAX(1, currentMonth - earliestMonth + 1);
	
	CGSize totalSize = CGSizeMake(0, 408);
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
	
	int i;
	CGRect subviewFrame = CGRectMake(0, 0, 0, totalSize.height);
	for (i = 0; i < monthCount; i++) {
		EWMonth month = (earliestMonth + i);
		subviewFrame.size.width = 5 * EWDaysInMonth(month);
		GraphView *view = [[GraphView alloc] initWithDatabase:database month:month];
		view.frame = subviewFrame;
		[scrollView addSubview:view];
		[view release];
		subviewFrame.origin.x += subviewFrame.size.width;
		totalSize.width += subviewFrame.size.width;
	}
	
	scrollView.contentSize = totalSize;

	self.view = scrollView;
	[scrollView release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
	/*
	 doesn't seem to matter since we're inside a tab view
		(interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
		(interfaceOrientation == UIInterfaceOrientationLandscapeRight);
	 */
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview.
	// Release anything that's not essential, such as cached data.
}

- (void)dealloc
{
	[super dealloc];
}


@end
