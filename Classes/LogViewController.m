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
#import "Database.h"
#import "EWDate.h"
#import "MonthData.h"

@implementation LogViewController

- (id)initWithDatabase:(Database *)db
{
	if (self = [super init]) {
		self.title = @"Log";
		database = db;
		firstLoad = YES;
	}
	return self;
}

- (void)loadView
{
	UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

	EWWeightLogDataSource *tableSource = [[EWWeightLogDataSource alloc] initWithDatabase:database];
	tableSource.viewController = self;
	
	tableView.delegate = tableSource;
	tableView.dataSource = tableSource;
	tableView.sectionIndexMinimumDisplayRowCount = 2; //NSIntegerMax;
	
	self.view = tableView;
	[tableView release];
}

- (void)viewWillAppear:(BOOL)animated
{
	UITableView *tableView = (UITableView *)self.view;
	NSIndexPath *tableSelection = [tableView indexPathForSelectedRow];
	if (tableSelection) {
		[tableView deselectRowAtIndexPath:tableSelection animated:NO];
	}

	[tableView reloadData];
	if (firstLoad) {
		id dataSource = [tableView dataSource];
		[tableView scrollToRowAtIndexPath:[dataSource lastIndexPath]
						 atScrollPosition:UITableViewScrollPositionBottom 
								 animated:NO];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	if (firstLoad) {
		firstLoad = NO;
		
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];

		EWWeightUnit databaseWeightUnit = [database weightUnit];
		EWWeightUnit defaultsWeightUnit = [defs integerForKey:@"WeightUnit"];
		
		if (databaseWeightUnit == 0) {
			// This is a new data file.
			if (defaultsWeightUnit == 0) {
				// Prompt user to choose weight unit.
				// [database setWeightUnit:newWeightUnit];
				// [defs setInteger:newWeightUnit forKey:@"WeightUnit"];
			} else {
				// Go with whatever was in defaults.
				// [database setWeightUnit:defaultsWeightUnit];
			}
		} else if (databaseWeightUnit != defaultsWeightUnit) {
			// The weight units don't match.  Offer user:
			// Convert: convert all values in database to new choice, then [database setWeightUnit:defaultsWeightUnit]
			// Reinterpret: [database setWeightUnit:defaultsWeightUnit]
			// Cancel: [defs setInteger:databaseWeightUnit forKey:@"WeightUnit"]
		}
		
		[defs registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"AutoWeighIn"]];
		if (! [defs boolForKey:@"AutoWeighIn"]) return;
		
		UITableView *tableView = (UITableView *)self.view;
		EWWeightLogDataSource *dataSource = (EWWeightLogDataSource *)[tableView dataSource];
		NSIndexPath *lastPath = [dataSource lastIndexPath];
		MonthData *data = [database dataForMonth:[dataSource monthForSection:[lastPath section]]];
		EWDay day = ([lastPath row] + 1);
		if ([data measuredWeightOnDay:day] == 0) {
			[self presentLogEntryViewForMonthData:data onDay:day];
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	[[logEntryViewController navigationController] release];
	[logEntryViewController release]; // maybe we need to check for use?
	logEntryViewController = nil;
}

- (void)dealloc
{
	[database release];
	[logEntryViewController release];
	[super dealloc];
}

- (void)presentLogEntryViewForMonthData:(MonthData *)monthData onDay:(EWDay)day
{
	if (logEntryViewController == nil) {
		logEntryViewController = [[LogEntryViewController alloc] init];
		[[UINavigationController alloc] initWithRootViewController:logEntryViewController];
	}
	logEntryViewController.monthData = monthData;
	logEntryViewController.day = day;
	[self presentModalViewController:[logEntryViewController navigationController] animated:YES];
}

@end
