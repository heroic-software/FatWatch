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


static NSNumberFormatter *weightFormatter = nil;
static NSNumberFormatter *energyFormatter = nil;


@implementation TrendViewController

- (void)recompute
{
	[array removeAllObjects];

	NSString *labels[] = {@"Week", @"Two Weeks", @"Month", @"Quarter", @"Six Months", @"Year"};
	int stops[] = {7, 14, 30, 90, 182, 365};
	
	Database *database = [Database sharedDatabase];
	
	if (weightFormatter == nil) {
		EWEnergyUnit energyUnit = [[NSUserDefaults standardUserDefaults] integerForKey:@"EnergyUnit"];
		EWWeightUnit weightUnit = [database weightUnit];
		NSAssert1(weightUnit != 0, @"Unknown weight unit in database: %d", weightUnit);
		
		weightFormatter = [[NSNumberFormatter alloc] init];
		[weightFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[weightFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[weightFormatter setPositivePrefix:@"+"];
		[weightFormatter setNegativePrefix:@"−"];
		[weightFormatter setPositiveSuffix:(weightUnit == kWeightUnitPounds) ? @" lbs/week" : @" kgs/week"];
		[weightFormatter setNegativeSuffix:[weightFormatter positiveSuffix]];
		[weightFormatter setMinimumIntegerDigits:1];
		[weightFormatter setMinimumFractionDigits:2];
		[weightFormatter setMaximumFractionDigits:2];
		[weightFormatter setMultiplier:[NSNumber numberWithInt:7]];
		
		energyFormatter = [[NSNumberFormatter alloc] init];
		[energyFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[energyFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[energyFormatter setPositivePrefix:@"+"];
		[energyFormatter setNegativePrefix:@"−"];
		[energyFormatter setPositiveSuffix:(energyUnit == kEnergyUnitCalories) ? @" cal/day" : @" kJ/day"];
		[energyFormatter setNegativeSuffix:[energyFormatter positiveSuffix]];
		[energyFormatter setMinimumIntegerDigits:1];
		[energyFormatter setMinimumFractionDigits:2];
		[energyFormatter setMaximumFractionDigits:2];

		float energyPerWeight;
		if (weightUnit == kWeightUnitPounds) {
			energyPerWeight = (energyUnit == kEnergyUnitCalories) ? kCaloriesPerPound : kKilojoulesPerPound;
		} else {
			energyPerWeight = (energyUnit == kEnergyUnitCalories) ? kCaloriesPerKilogram : kKilojoulesPerKilogram;
		}
		
		[energyFormatter setMultiplier:[NSNumber numberWithFloat:energyPerWeight]];
	}

	SlopeComputer *computer = [[SlopeComputer alloc] init];
	EWMonthDay curMonthDay = EWMonthDayFromDate([NSDate date]);
	EWMonth curMonth = EWMonthDayGetMonth(curMonthDay);
	EWDay curDay = EWMonthDayGetDay(curMonthDay);
	MonthData *data = [database dataForMonth:curMonth];
	EWMonth earliestMonth = [database earliestMonth];
	
	int newValueCount = 0;
	int i;
	float x = 0;
	for (i = 0; (i < 6) && (curMonth >= earliestMonth); i++) {
		while ((x < stops[i]) && (curMonth >= earliestMonth)) {
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
				data = [database dataForMonth:curMonth];
			}
		}
		float weightPerDay = -[computer computeSlope];
		if (newValueCount > 1) {
			[array addObject:[NSArray arrayWithObjects:
							  [NSString stringWithFormat:@"Past %@", labels[i]],
							  [weightFormatter stringFromNumber:[NSNumber numberWithFloat:weightPerDay]], 
							  [energyFormatter stringFromNumber:[NSNumber numberWithFloat:weightPerDay]], 
							  nil]];
			newValueCount = 0;
		}
	}
	[computer release];
}

- (id)init
{
	if (self = [super init]) {
		self.title = @"Trends";
		array = [[NSMutableArray alloc] init];
	}
	return self;
}

- (NSString *)message
{
	return @"Not enough data to compute trends. Try again tomorrow.";
}

- (UIView *)loadDataView
{
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.sectionIndexMinimumDisplayRowCount = NSIntegerMax;
	return [tableView autorelease];
}

- (void)dataChanged
{
	[self recompute];
	UITableView *tableView = (UITableView *)self.dataView;
	[tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
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

#pragma mark UITableViewDelegate (Optional)

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil; // table is for display only, don't allow selection
}

@end
