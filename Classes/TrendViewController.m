//
//  TrendViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "TrendViewController.h"
#import "EWGoal.h"
#import "TrendSpan.h"
#import "EWDatabase.h"


@implementation TrendViewController


- (id)init {
	if ([super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"Trends", @"Trends view title");
		self.tabBarItem.image = [UIImage imageNamed:@"TabIconTrend.png"];
		array = [[NSMutableArray alloc] init];
	}
	return self;
}


- (void)databaseDidChange:(NSNotification *)notice {
	[array setArray:[TrendSpan computeTrendSpans]];
	[self.tableView reloadData];
}


- (void)dealloc {
	[array release];
	[super dealloc];
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


- (void)viewWillAppear:(BOOL)animated {
//	self.tableView.rowHeight = 38; // 44 is the default
	[self startObservingDatabase];
}


- (void)viewWillDisappear:(BOOL)animated {
	[self stopObservingDatabase];
}


#pragma mark UITableViewDataSource (Required)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return MAX(1, [array count]);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([array count] == 0) return 0;
	TrendSpan *span = [array objectAtIndex:section];
	return [span numberOfTableRows];
}


#pragma mark UITableViewDataSource (Optional)

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([array count] == 0) return nil;
	TrendSpan *span = [array objectAtIndex:section];
	return span.title;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if ([array count] == 0) {
		return NSLocalizedString(@"You must have weighed-in at least twice in the past year for FatWatch to compute trends.", @"Trends no data message");
	} else {
		return nil;
	}
}


#pragma mark UITableViewDelegate (Required)


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	id availableCell = [tableView dequeueReusableCellWithIdentifier:@"TrendCell"];
	if (availableCell != nil) {
		cell = (UITableViewCell *)availableCell;
	} else {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"TrendCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone; // don't show selection
	}

	TrendSpan *span = [array objectAtIndex:indexPath.section];
	[span configureCell:cell forTableRow:indexPath.row];
	
	return cell;
}


#pragma mark UITableViewDelegate (Optional)


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TrendSpan *span = [array objectAtIndex:indexPath.section];
	if ([span shouldUpdateAfterDidSelectRow:indexPath.row]) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		[span configureCell:cell forTableRow:indexPath.row];
	}
	// auto-scroll section to top of view
	[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]
					 atScrollPosition:UITableViewScrollPositionTop 
							 animated:YES];
}


@end
