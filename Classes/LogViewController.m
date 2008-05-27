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
#import "LogTableViewCell.h"


@interface LogViewController ()
- (void)databaseDidChange:(NSNotification *)notice;
@end


@implementation LogViewController

- (id)init {
	if (self = [super init]) {
		self.title = NSLocalizedString(@"LOG_VIEW_TITLE", nil);
		firstLoad = YES;

		sectionTitleFormatter = [[NSDateFormatter alloc] init];
		sectionTitleFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
		sectionTitleFormatter.dateFormat = NSLocalizedString(@"MONTH_YEAR_DATE_FORMAT", nil);
	}
	return self;
}


- (void)startObservingDatabase {
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(databaseDidChange:) 
												 name:EWDatabaseDidChangeNotification 
											   object:nil];
	[self databaseDidChange:nil];
}


- (void)stopObservingDatabase {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)databaseDidChange:(NSNotification *)notice {
	EWMonthDay today = EWMonthDayFromDate([NSDate date]);
	Database *db = [Database sharedDatabase];
	
	earliestMonth = db.earliestMonth;
	latestMonth = MAX(db.latestMonth, EWMonthDayGetMonth(today));

	NSUInteger row, section;
	section = latestMonth - earliestMonth;
	if (latestMonth == EWMonthDayGetMonth(today)) {
		row = EWMonthDayGetDay(today) - 1;
	} else {
		row = EWDaysInMonth(latestMonth) - 1;
	}
	[lastIndexPath release];
	lastIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
	[lastIndexPath retain];
	
	UITableView *tableView = (UITableView *)self.view;
	[tableView reloadData];
}


- (void)loadView {
	UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.sectionIndexMinimumDisplayRowCount = 2; //NSIntegerMax;
	
	self.view = tableView;
	[tableView release];
}


- (EWMonth)monthForSection:(NSInteger)section {
	return earliestMonth + section;
}


- (void)autoWeighInIfEnabled {
	if (! [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoWeighIn"]) return;
	
	MonthData *data = [[Database sharedDatabase] dataForMonth:[self monthForSection:[lastIndexPath section]]];
	EWDay day = ([lastIndexPath row] + 1);
	if ([data measuredWeightOnDay:day] == 0) {
		[self presentLogEntryViewForMonthData:data onDay:day weighIn:YES];
	}
}


- (void)viewWillAppear:(BOOL)animated {
	[self startObservingDatabase];
	
	UITableView *tableView = (UITableView *)self.view;
	NSIndexPath *tableSelection = [tableView indexPathForSelectedRow];
	if (tableSelection) {
		[tableView deselectRowAtIndexPath:tableSelection animated:NO];
	}

	if (firstLoad) {
		firstLoad = NO;
		[tableView scrollToRowAtIndexPath:lastIndexPath
						 atScrollPosition:UITableViewScrollPositionBottom 
								 animated:NO];
		[self autoWeighInIfEnabled];
	}
}


- (UIView *)findSubviewOfView:(UIView *)parent ofClass:(Class)viewClass {
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


- (void)viewWillDisappear:(BOOL)animated {
	[self stopObservingDatabase];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	[[logEntryViewController navigationController] release];
	[logEntryViewController release]; // maybe we need to check for use?
	logEntryViewController = nil;
}


- (void)dealloc {
	[lastIndexPath release];
	[sectionTitleFormatter release];
	[logEntryViewController release];
	[super dealloc];
}


- (void)presentLogEntryViewForMonthData:(MonthData *)monthData onDay:(EWDay)day weighIn:(BOOL)flag {
	if (logEntryViewController == nil) {
		logEntryViewController = [[LogEntryViewController alloc] init];
		[[UINavigationController alloc] initWithRootViewController:logEntryViewController];
	}
	logEntryViewController.monthData = monthData;
	logEntryViewController.day = day;
	logEntryViewController.weighIn = flag;
	[[self parentViewController] presentModalViewController:[logEntryViewController navigationController] animated:!flag];
}


#pragma mark UITableViewDataSource (Required)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return latestMonth - earliestMonth + 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == [lastIndexPath section]) {
		return [lastIndexPath row] + 1;
	} else {
		EWMonth month = [self monthForSection:section];
		return EWDaysInMonth(month);
	}
}


#pragma mark UITableViewDataSource (Optional)

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	EWMonth month = [self monthForSection:section];
	NSDate *theDate = EWDateFromMonthAndDay(month, 1);
	return [sectionTitleFormatter stringFromDate:theDate];
}


#pragma mark UITableViewDelegate (Required)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	EWMonth month = [self monthForSection:[indexPath section]];
	MonthData *monthData = [[Database sharedDatabase] dataForMonth:month];
	EWDay day = 1 + [indexPath row];
	[self presentLogEntryViewForMonthData:monthData onDay:day weighIn:NO];
}

@end
