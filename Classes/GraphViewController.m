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
	
	CGRect contentRect = CGRectMake(0, 0, 100 * monthCount, 500);
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	scrollView.contentOffset = contentRect.origin;
	scrollView.contentSize = contentRect.size;
	
	int i;
	CGRect subviewFrame = CGRectMake(0, 0, 100, 500);
	for (i = 0; i < monthCount; i++) {
		GraphView *view = [[GraphView alloc] initWithDatabase:database month:(earliestMonth + i)];
		view.frame = subviewFrame;
		view.backgroundColor = [UIColor colorWithRed:(i % 2)
											   green:0
												blue:(1 - (i % 2))
											   alpha:1];
		[scrollView addSubview:view];
		[view release];
		subviewFrame.origin.x += subviewFrame.size.width;
	}
	
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
