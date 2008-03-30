//
//  LogViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "LogViewController.h"
#import "EWWeightLogDataSource.h"


@implementation LogViewController

- (id)init
{
	if (self = [super init]) {
		// Initialize your view controller.
		self.title = @"Log";
	}
	return self;
}


- (void)loadView
{
	/*
	 // Show the window with table view
	 [tableView reloadData];
	 [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:2] 
	 atScrollPosition:UITableViewScrollPositionBottom
	 animated:NO];
	 */

	// Create a custom view hierarchy.
	UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

	id tableSource = [[EWWeightLogDataSource alloc] init];
	tableView.delegate = tableSource;
	tableView.dataSource = tableSource;
	tableView.sectionIndexMinimumDisplayRowCount = NSIntegerMax;
	
	self.view = tableView;
	[tableView release];
}

- (void)viewWillAppear:(BOOL)animated
{
	UITableView *tableView = (UITableView *)self.view;
	id dataSource = [tableView dataSource];
	[tableView reloadData];
	[tableView scrollToRowAtIndexPath:[dataSource lastIndexPath]
					 atScrollPosition:UITableViewScrollPositionBottom 
							 animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
