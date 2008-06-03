//
//  TrendViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "TrendViewController.h"
#import "Database.h"
#import "SlopeComputer.h"
#import "MonthData.h"
#import "WeightFormatter.h"


@implementation TrendViewController

- (void)recompute {
	[array removeAllObjects];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"TrendSpans" ofType:@"plist"];
	NSDictionary *spanDict = [NSDictionary dictionaryWithContentsOfFile:path];
	NSArray *spanLengths = [spanDict objectForKey:@"SpanLengths"];
	NSArray *spanTitles = [spanDict objectForKey:@"SpanTitles"];
	NSUInteger spanCount = MIN([spanLengths count], [spanTitles count]);

	Database *database = [Database sharedDatabase];
	
	SlopeComputer *computer = [[SlopeComputer alloc] init];
	EWMonthDay curMonthDay = EWMonthDayFromDate([NSDate date]);
	EWMonth curMonth = EWMonthDayGetMonth(curMonthDay);
	EWDay curDay = EWMonthDayGetDay(curMonthDay);
	MonthData *data = [database dataForMonth:curMonth];
	EWMonth earliestMonth = [database earliestMonth];
	WeightFormatter *formatter = [WeightFormatter sharedFormatter];

	int newValueCount = 0;
	int spanIndex;
	float x = 0;
	
	for (spanIndex = 0; (spanIndex < spanCount) && (curMonth >= earliestMonth); spanIndex++) {
		NSUInteger spanLength = [[spanLengths objectAtIndex:spanIndex] intValue];
		while ((x < spanLength) && (curMonth >= earliestMonth)) {
			if (data == nil) {
				data = [database dataForMonth:curMonth];
			}
			float y = [data measuredWeightOnDay:curDay];
			if (y > 0) {
				[computer addPointAtX:x y:y];
				newValueCount++;
			}
			x++;
			curDay--;
			if (curDay < 1) {
				curMonth--;
				curDay = EWDaysInMonth(curMonth);
				data = nil;
			}
		}
		if (newValueCount > 1) {
			float weightPerDay = -[computer computeSlope];
			[array addObject:[NSArray arrayWithObjects:
							  [spanTitles objectAtIndex:spanIndex],
							  [formatter weightPerWeekStringFromWeightChange:(7.0f * weightPerDay)],
							  [formatter energyPerDayStringFromWeightChange:weightPerDay],
							  nil]];
			newValueCount = 0;
		}
	}
	[computer release];
}


- (id)init {
	if (self = [super init]) {
		self.title = NSLocalizedString(@"TRENDS_VIEW_TITLE", nil);
		array = [[NSMutableArray alloc] init];
	}
	return self;
}


- (NSString *)message {
	return NSLocalizedString(@"NO_DATA_FOR_TRENDS", nil);
}


- (UIView *)loadDataView {
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	tableView.delegate = self;
	tableView.dataSource = self;
	return [tableView autorelease];
}


- (BOOL)hasEnoughData {
	if ([super hasEnoughData]) {
		[self recompute];
		return [array count] > 0;
	}
	return NO;
}


- (void)dataChanged {
	UITableView *tableView = (UITableView *)self.dataView;
	[tableView reloadData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}


- (void)dealloc {
	[array release];
	[super dealloc];
}


#pragma mark UITableViewDataSource (Required)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [array count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}


#pragma mark UITableViewDataSource (Optional)

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[array objectAtIndex:section] objectAtIndex:0];
}


#pragma mark UITableViewDelegate (Required)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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


#pragma mark UITableViewDelegate (Optional)

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil; // table is for display only, don't allow selection
}

@end
