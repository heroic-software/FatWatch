//
//  TrendViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "TrendViewController.h"
#import "Database.h"

@implementation TrendViewController

- (void)computeLabel:(NSString *)label days:(NSUInteger)dayCount
{
	float slope = [database slopeForPastDays:dayCount];
	[array addObject:[NSArray arrayWithObjects:label,
					  [NSString stringWithFormat:@"%+.2f lbs/week", (7.0f * slope)], 
					  [NSString stringWithFormat:@"%+.2f cal/day", (3500.0f * slope)], 
					  nil]];
}

- (void)recompute
{
	[array removeAllObjects];
	[self computeLabel:@"Week" days:7];
	[self computeLabel:@"Fortnight" days:14];
	[self computeLabel:@"Month" days:30];
	[self computeLabel:@"Quarter" days:90];
	[self computeLabel:@"Six months" days:182];
	[self computeLabel:@"Year" days:365];
	UITableView *tableView = (UITableView *)self.view;
	[tableView reloadData];
}

- (id)initWithDatabase:(Database *)db
{
	if (self = [super init]) {
		// Initialize your view controller.
		self.title = @"Trend";
		
		database = db;
		
		array = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)loadView
{
	// Create a custom view hierarchy.
	UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.sectionIndexMinimumDisplayRowCount = NSIntegerMax;
	
	self.view = tableView;
	[tableView release];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self recompute];
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
	[array release];
	[super dealloc];
}

#pragma mark UITableViewDataSource (Required)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [array count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

#pragma mark UITableViewDataSource (Optional)

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[array objectAtIndex:section] objectAtIndex:0];
}

#pragma mark UITableViewDelegate (Required)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	
	id availableCell = [tableView dequeueReusableCellWithIdentifier:@"Foo"];
	if (availableCell != nil) {
		cell = (UITableViewCell *)availableCell;
	} else {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"Foo"] autorelease];
	}
	
	cell.text = [[array objectAtIndex:[indexPath section]] objectAtIndex:([indexPath row] + 1)];
	return cell;
}

@end
