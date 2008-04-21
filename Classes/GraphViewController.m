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
		firstLoad = YES;
		
		self.title = @"Graph";
	}
	return self;
}


- (void)loadView
{
	UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[mainView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[mainView setAutoresizesSubviews:YES];
	mainView.backgroundColor = [UIColor lightGrayColor];
	self.view = mainView;

	// View for when there's not enough data
	
	warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 320-40, 410)];
	warningLabel.backgroundColor = [UIColor clearColor];
	warningLabel.text = @"Not enough data to draw a graph. Try again tomorrow.";
	warningLabel.lineBreakMode = UILineBreakModeWordWrap;
	warningLabel.numberOfLines = 0;
	
	// View for the graph

	EWMonth earliestMonth = [database earliestMonth];
	EWMonth currentMonth = EWMonthFromDate([NSDate date]);
	NSUInteger monthCount = MAX(1, currentMonth - earliestMonth + 1);
	
	CGSize totalSize = CGSizeMake(0, 410);
	
	scrollView = [[UIScrollView alloc] initWithFrame:[mainView bounds]];
	
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
}

- (void)viewWillAppear:(BOOL)animated
{
	if ([database changeCount] != dbChangeCount) {
		if ([database weightCount] > 1) {
			if ([scrollView superview] == nil) {
				[warningLabel removeFromSuperview];
				[self.view addSubview:scrollView];
				[self.view setNeedsLayout];
				if (firstLoad) {
					CGRect rect = CGRectMake(scrollView.contentSize.width - 1, 0, 1, 1);
					[scrollView scrollRectToVisible:rect animated:NO];
					firstLoad = NO;
				}
			}
			[[scrollView subviews] makeObjectsPerformSelector:@selector(setNeedsDisplay)];
		} else {
			if ([warningLabel superview] == nil) {
				[scrollView removeFromSuperview];
				[self.view addSubview:warningLabel];
				[self.view setNeedsLayout];
			}
		}
		dbChangeCount = [database changeCount];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
	BOOL shouldReleaseSubviews = ([self.view superview] == nil);
	[super didReceiveMemoryWarning];
	if (shouldReleaseSubviews) {
		[scrollView release]; scrollView = nil;
		[warningLabel release]; warningLabel = nil;
	}
}

- (void)dealloc
{
	[scrollView release];
	[warningLabel release];
	[super dealloc];
}


@end
