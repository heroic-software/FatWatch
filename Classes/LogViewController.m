//
//  LogViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "LogViewController.h"
#import "LogEntryViewController.h"
#import "Database.h"
#import "EWDate.h"
#import "MonthData.h"
#import "NewDatabaseViewController.h"
#import "UnitConvertViewController.h"
#import "LogTableViewCell.h"

@implementation LogViewController

- (id)init
{
	if (self = [super init]) {
		self.title = @"Log";
		firstLoad = YES;

		sectionTitleFormatter = [[NSDateFormatter alloc] init];
		sectionTitleFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
		sectionTitleFormatter.dateFormat = @"MMMM yyyy";
		
		earliestMonth = [[Database sharedDatabase] earliestMonth];
		EWMonth currentMonth = EWMonthFromDate([NSDate date]);
		EWDay currentDay = EWDayFromDate([NSDate date]);
		
		numberOfSections = MAX(1, currentMonth - earliestMonth + 1);
		
		lastIndexPath = [NSIndexPath indexPathForRow:(currentDay - 1)
										   inSection:(numberOfSections - 1)];
		[lastIndexPath retain];
	}
	return self;
}

- (void)loadView
{
	UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.sectionIndexMinimumDisplayRowCount = 2; //NSIntegerMax;
	
	self.view = tableView;
	[tableView release];
}

- (EWMonth)monthForSection:(NSInteger)section
{
	return earliestMonth + section;
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
		[tableView scrollToRowAtIndexPath:lastIndexPath
						 atScrollPosition:UITableViewScrollPositionBottom 
								 animated:NO];
	}
}

- (void)autoWeighInIfEnabled
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"AutoWeighIn"]];
	if (! [defs boolForKey:@"AutoWeighIn"]) return;
	
	MonthData *data = [[Database sharedDatabase] dataForMonth:[self monthForSection:[lastIndexPath section]]];
	EWDay day = ([lastIndexPath row] + 1);
	if ([data measuredWeightOnDay:day] == 0) {
		[self presentLogEntryViewForMonthData:data onDay:day weighIn:YES];
	}
}

- (UIView *)findSubviewOfView:(UIView *)parent ofClass:(Class)viewClass
{
	for (UIView *subview in [parent subviews]) {
		if ([subview isKindOfClass:viewClass]) {
			return subview;
		} else {
			UIView *subsubview = [self findSubviewOfView:subview ofClass:viewClass];
			if (subsubview) return subsubview;
		}
	}
	return nil;
}

- (void)viewDidAppear:(BOOL)animated
{
	if (firstLoad) {
		EWWeightUnit databaseWeightUnit = [[Database sharedDatabase] weightUnit];
		EWWeightUnit defaultsWeightUnit = [[NSUserDefaults standardUserDefaults] integerForKey:@"WeightUnit"];
		
		if (databaseWeightUnit == 0) {
			// This is a new data file.
			if (defaultsWeightUnit == 0) {
				// Prompt user to choose weight unit.
				NewDatabaseViewController *newDbController = [[NewDatabaseViewController alloc] init];
				[[self parentViewController] presentModalViewController:newDbController animated:YES];
				[newDbController release];
				return;
			} else {
				// Go with whatever was in defaults.
				[[Database sharedDatabase] setWeightUnit:defaultsWeightUnit];
			}
		} else if (defaultsWeightUnit == 0) {
			// Have units in the database but not in defaults, go with the database.
			[[NSUserDefaults standardUserDefaults] setInteger:databaseWeightUnit forKey:@"WeightUnit"];
		} else if (databaseWeightUnit != defaultsWeightUnit) {
			// The weight units don't match.
			UnitConvertViewController *unitConvertController = [[UnitConvertViewController alloc] init];
			[[self parentViewController] presentModalViewController:unitConvertController animated:YES];
			[unitConvertController release];
			return;
		}
		// Normal launch
		firstLoad = NO;
		[self autoWeighInIfEnabled];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
	[lastIndexPath release];
	[sectionTitleFormatter release];
	[logEntryViewController release];
	[super dealloc];
}

- (void)presentLogEntryViewForMonthData:(MonthData *)monthData onDay:(EWDay)day weighIn:(BOOL)flag
{
	if (logEntryViewController == nil) {
		logEntryViewController = [[LogEntryViewController alloc] init];
		[[UINavigationController alloc] initWithRootViewController:logEntryViewController];
	}
	logEntryViewController.monthData = monthData;
	logEntryViewController.day = day;
	logEntryViewController.weighIn = flag;
	[[self parentViewController] presentModalViewController:[logEntryViewController navigationController] animated:YES];
}

#pragma mark UITableViewDataSource (Required)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == numberOfSections - 1) {
		return [lastIndexPath row] + 1;
	} else {
		EWMonth month = [self monthForSection:section];
		return EWDaysInMonth(month);
	}
}

#pragma mark UITableViewDataSource (Optional)

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	EWMonth month = [self monthForSection:section];
	NSDate *theDate = NSDateFromEWMonthAndDay(month, 1);
	return [sectionTitleFormatter stringFromDate:theDate];
}

#pragma mark UITableViewDelegate (Required)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	LogTableViewCell *cell = nil;
	
	id availableCell = [tableView dequeueReusableCellWithIdentifier:kLogCellReuseIdentifier];
	if (availableCell != nil) {
		cell = (LogTableViewCell *)availableCell;
	} else {
		cell = [[[LogTableViewCell alloc] init] autorelease];
	}
	
	MonthData *monthData = [[Database sharedDatabase] dataForMonth:[self monthForSection:[indexPath section]]];
	EWDay day = 1 + [indexPath row];
	[cell updateWithMonthData:monthData day:day];
	
	return cell;
}

#pragma mark UITableViewDelegate (Optional)

- (void)tableView:(UITableView *)tableView selectionDidChangeToIndexPath:(NSIndexPath *)newIndexPath fromIndexPath:(NSIndexPath *)oldIndexPath
{
	if (newIndexPath) {
		EWMonth month = [self monthForSection:[newIndexPath section]];
		MonthData *monthData = [[Database sharedDatabase] dataForMonth:month];
		EWDay day = 1 + [newIndexPath row];
		[self presentLogEntryViewForMonthData:monthData onDay:day weighIn:NO];
	}
}

@end
