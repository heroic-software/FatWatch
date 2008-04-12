//
//  LogViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "LogViewController.h"
#import "EWWeightLogDataSource.h"
#import "LogEntryViewController.h"


@implementation LogViewController

- (id)initWithDatabase:(Database *)db
{
	if (self = [super init]) {
		self.title = @"Log";
		database = [db retain];
	}
	return self;
}


- (void)loadView
{
	// Create a custom view hierarchy.
	UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

	EWWeightLogDataSource *tableSource = [[EWWeightLogDataSource alloc] initWithDatabase:database];
	tableSource.viewController = self;
	
	tableView.delegate = tableSource;
	tableView.dataSource = tableSource;
	tableView.sectionIndexMinimumDisplayRowCount = NSIntegerMax;
	
	self.view = tableView;
	[tableView release];
}

- (void)viewWillAppear:(BOOL)animated
{
	UITableView *tableView = (UITableView *)self.view;
	NSIndexPath *tableSelection = [tableView indexPathForSelectedRow];
	[tableView deselectRowAtIndexPath:tableSelection animated:NO];

	[tableView reloadData];
	
	/*
	 // select last row
	id dataSource = [tableView dataSource];
	[tableView reloadData];
	[tableView scrollToRowAtIndexPath:[dataSource lastIndexPath]
					 atScrollPosition:UITableViewScrollPositionBottom 
							 animated:NO];
	 */
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	[logEntryViewController release]; // maybe we need to check for use?
	logEntryViewController = nil;
}

- (void)dealloc
{
	[database release];
	[logEntryViewController release];
	[super dealloc];
}

- (void)presentLogEntryViewForMonthData:(MonthData *)monthData onDay:(unsigned int)day
{
	if (logEntryViewController == nil) {
		logEntryViewController = [[LogEntryViewController alloc] init];
	}
	logEntryViewController.monthData = monthData;
	logEntryViewController.day = day;
	//[self presentModalViewController:logEntryViewController animated:YES];
	[[self navigationController] pushViewController:logEntryViewController animated:YES];
}

@end
