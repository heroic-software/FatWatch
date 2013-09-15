//
//  TrendViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "TrendViewController.h"
#import "EWDatabase.h"
#import "EWDBIterator.h"
#import "EWTrendButton.h"
#import "EWGoal.h"
#import "TrendSpan.h"
#import "EWWeightChangeFormatter.h"
#import "EWWeightFormatter.h"
#import "BRColorPalette.h"
#import "GraphView.h"
#import "GraphDrawingOperation.h"
#import "EnergyViewController.h"
#import "EWDBMonth.h"


static const NSTimeInterval kSecondsPerDay = 60 * 60 * 24;
static NSString * const kTrendSpanLengthKey = @"TrendSpanLength";
static NSString * const kTrendShowFatKey = @"TrendViewControllerShowFat";
static NSString * const kTrendShowAbsoluteDateKey = @"TrendViewControllerShowAbsoluteDate";


@interface TrendViewController ()
- (void)updateGoalState;
- (void)updateControls;
@end


@implementation TrendViewController


@synthesize database;
@synthesize graphView;
@synthesize changeGroupView;
@synthesize weightChangeButton;
@synthesize energyChangeButton;
@synthesize goalGroupView;
@synthesize relativeEnergyButton;
@synthesize relativeWeightButton;
@synthesize dateButton;
@synthesize planButton;
@synthesize flagGroupView;
@synthesize flag0Label;
@synthesize flag1Label;
@synthesize flag2Label;
@synthesize flag3Label;
@synthesize messageGroupView;
@synthesize goalAttainedView;


- (void)databaseDidChange:(NSNotification *)notice {
	[spanArray release];
	spanArray = nil;
}


- (void)viewDidLoad {
	goalGroupView.backgroundColor = self.view.backgroundColor;
	goalAttainedView.backgroundColor = self.view.backgroundColor;
	
	graphView.backgroundColor = [UIColor whiteColor];
	graphView.drawBorder = YES;
	
	relativeWeightButton.enabled = NO;
	planButton.enabled = NO;
	
	energyChangeButton.accessoryType = EWTrendButtonAccessoryDisclosureIndicator;
	relativeEnergyButton.accessoryType = EWTrendButtonAccessoryDisclosureIndicator;
	
	dateButton.accessoryType = EWTrendButtonAccessoryToggle;
	weightChangeButton.accessoryType = EWTrendButtonAccessoryToggle;
	
	UIFont *boldFont = [UIFont boldSystemFontOfSize:17];
	[weightChangeButton setFont:boldFont forPart:1];
	[weightChangeButton setFont:boldFont forPart:3];
	[energyChangeButton setFont:boldFont forPart:1];
	[relativeWeightButton setFont:boldFont forPart:0];
	[dateButton setFont:boldFont forPart:1];
	[planButton setFont:boldFont forPart:0];
	[relativeEnergyButton setFont:boldFont forPart:0];
	[relativeEnergyButton setFont:boldFont forPart:1];

	[weightChangeButton setText:@" of " forPart:2];

	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self 
			   selector:@selector(databaseDidChange:) 
				   name:EWDatabaseDidChangeNotification 
				 object:nil];
	[center addObserver:self
			   selector:@selector(databaseDidChange:)
				   name:EWBMIStatusDidChangeNotification
				 object:nil];
	[center addObserver:self
			   selector:@selector(databaseDidChange:)
				   name:EWGoalDidChangeNotification 
				 object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	showFat = [userDefaults boolForKey:kTrendShowFatKey];
	showAbsoluteDate = [userDefaults boolForKey:kTrendShowAbsoluteDateKey];
	if (spanArray == nil) {
		spanArray = [[TrendSpan computeTrendSpansFromDatabase:database] copy];
		int length = [userDefaults integerForKey:kTrendSpanLengthKey];
		if (length > 0) {
			for (NSUInteger i = 0; i < [spanArray count]; i++) {
				// Allow length to be off by a few days
				if (ABS([[spanArray objectAtIndex:i] length] - length) < 7) {
					spanIndex = i;
				}
			}
		}
		[self updateGoalState];
	}
	[self updateControls];
}


- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)updateRelativeWeightButton {
	EWGoal *goal = [[EWGoal alloc] initWithDatabase:database];
	float weightToGo = goal.endWeight - goal.currentWeight;
	EWWeightFormatter *wf = [EWWeightFormatter weightFormatterWithStyle:
							 EWWeightFormatterStyleDisplay];
	[relativeWeightButton setText:[wf stringForFloat:fabsf(weightToGo)] 
						  forPart:0];
	[relativeWeightButton setText:((weightToGo > 0) ?
								   @" to gain" :
								   @" to lose")
						  forPart:1];
	[relativeWeightButton setTextColor:[UIColor blackColor] forPart:0];
	[goal release];
}


- (NSString *)stringFromDayCount:(int)dayCount {
	if (dayCount > 365) {
		int yearCount = roundf((float)dayCount / 365.25f);
		if (yearCount == 1) {
			return @"about a year";
		} else {
			return [NSString stringWithFormat:@"about %d years", yearCount];
		}
	} else if (dayCount == 1) {
		return @"1 day";
	} else {
		return [NSString stringWithFormat:@"%d days", dayCount];
	}
}


- (void)updateDateButtonWithDate:(NSDate *)date {
	if (date) {
		int dayCount = (int)floor([date timeIntervalSinceNow] / kSecondsPerDay);
		if (dayCount > 365) {
			[dateButton setText:@"goal weight in " forPart:0];
			[dateButton setText:[self stringFromDayCount:dayCount] forPart:1];
			dateButton.enabled = NO;
		} else if (showAbsoluteDate) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterLongStyle];
			[formatter setTimeStyle:NSDateFormatterNoStyle];
			[dateButton setText:@"goal weight on " forPart:0];
			[dateButton setText:[formatter stringFromDate:date] forPart:1];
			[formatter release];
			dateButton.enabled = YES;
			dateButton.selected = showAbsoluteDate;
		} else {
			[dateButton setText:@"goal weight " forPart:0];
			if (dayCount == 0) {
				[dateButton setText:@"today" forPart:1];
			} else if (dayCount == 1) {
				[dateButton setText:@"tomorrow" forPart:1];
			} else {
				[dateButton setText:[NSString stringWithFormat:@"in %d days", dayCount] forPart:1];
			}
			dateButton.enabled = YES;
			dateButton.selected = showAbsoluteDate;
		}
		[dateButton setTextColor:[UIColor blackColor] forPart:1];
	} else {
		[dateButton setText:@"" forPart:0];
		[dateButton setText:@"moving away from goal" forPart:1];
		[dateButton setTextColor:[BRColorPalette colorNamed:@"BadText"] forPart:1];
		dateButton.enabled = NO;
	}
}


- (void)updatePlanButtonWithDate:(NSDate *)date {
	planButton.hidden = (date == nil);
	if (date == nil) return;
	EWGoal *goal = [[EWGoal alloc] initWithDatabase:database];
	NSTimeInterval t = [date timeIntervalSinceDate:[goal endDate]];
	[goal release];
	int dayCount = (int)floor(t / kSecondsPerDay);
	if (dayCount > 0) {
		[planButton setText:[self stringFromDayCount:dayCount] forPart:0];
		[planButton setText:@" later than goal date" forPart:1];
		[planButton setTextColor:[BRColorPalette colorNamed:@"WarningText"] forPart:0];
	} else if (dayCount < 0) {
		[planButton setText:[self stringFromDayCount:-dayCount] forPart:0];
		[planButton setText:@" earlier than goal date" forPart:1];
		[planButton setTextColor:[BRColorPalette colorNamed:@"GoodText"] forPart:0];
	} else {
		[planButton setText:@"on schedule" forPart:0];
		[planButton setText:@" for goal date" forPart:1];
		[planButton setTextColor:[BRColorPalette colorNamed:@"GoodText"] forPart:0];
	}
}


- (void)updateRelativeEnergyButtonWithRate:(float)rate {
	EWGoal *goal = [[EWGoal alloc] initWithDatabase:database];
	float plan = [goal weightChangePerDay];
	[goal release];
/*
 plan		rate	R-P
 ***		***		 ~0		following plan						G
 -10		-20		-10		burning 10 cal/day more than plan	G
 -30		-20		+10		burn 10 cal/day more to make goal	W
 -30		+20		+50		burn 50 cal/day more to meet goal	B \
 -10		+20		+30		burn 30 cal/day more to meet goal	B /
 +10		-20		-30		eat 30 cal/day more to make goal	B \
 +30		-20		-50		eat 50 cal/day more to make goal	B /
 +30		+20		-10		eat 10 cal/day more to make goal	W
 +10		+20		+10		eating 10 cal/day more than plan	G
 */
	
	float gap = rate - plan;

#if TARGET_IPHONE_SIMULATOR
	NSLog(@"PLAN=%f RATE=%f GAP=%f", plan, rate, gap);
#endif
	
	if (fabsf(gap) < 0.001) { // remember, this is lbs/day
		// I love it when a plan comes together.
		[relativeEnergyButton setText:@"" forPart:0];
		[relativeEnergyButton setText:@"following plan" forPart:1];
		[relativeEnergyButton setText:@"" forPart:2];
		[relativeEnergyButton setTextColor:[BRColorPalette colorNamed:@"GoodText"] forPart:1];
		relativeEnergyButton.enabled = NO;
		return;
	}
	
	UIColor *energyColor;
	
	NSString *kTextBurning = NSLocalizedString(@"burning ", nil);
	NSString *kTextEating = NSLocalizedString(@"eating ", nil);
	NSString *kTextPlanDescriptive = NSLocalizedString(@" beyond plan", nil);
	NSString *kTextCut = NSLocalizedString(@"cut ", nil);
	NSString *kTextAdd = NSLocalizedString(@"add ", nil);
	NSString *kTextPlanImperative = NSLocalizedString(@" to match plan", nil);
	
	if (plan < 0) {
		if (rate < 0) {
			if (gap < 0) {
				[relativeEnergyButton setText:kTextBurning forPart:0];
				energyColor = [BRColorPalette colorNamed:@"GoodText"];
				[relativeEnergyButton setText:kTextPlanDescriptive forPart:2];
			} else {
				[relativeEnergyButton setText:kTextCut forPart:0];
				energyColor = [BRColorPalette colorNamed:@"WarningText"];
				[relativeEnergyButton setText:kTextPlanImperative forPart:2];
			}
		} else {
			[relativeEnergyButton setText:kTextCut forPart:0];
			energyColor = [BRColorPalette colorNamed:@"BadText"];
			[relativeEnergyButton setText:kTextPlanImperative forPart:2];
		}
	} else {
		if (rate < 0) {
			[relativeEnergyButton setText:kTextAdd forPart:0];
			energyColor = [BRColorPalette colorNamed:@"BadText"];
			[relativeEnergyButton setText:kTextPlanImperative forPart:2];
		} else {
			if (gap < 0) {
				[relativeEnergyButton setText:kTextAdd forPart:0];
				energyColor = [BRColorPalette colorNamed:@"WarningText"];
				[relativeEnergyButton setText:kTextPlanImperative forPart:2];
			} else {
				[relativeEnergyButton setText:kTextEating forPart:0];
				energyColor = [BRColorPalette colorNamed:@"GoodText"];
				[relativeEnergyButton setText:kTextPlanDescriptive forPart:2];
			}
		}
	}
	
	NSNumberFormatter *wf = [[EWWeightChangeFormatter alloc] initWithStyle:
							 EWWeightChangeFormatterStyleEnergyPerDay];
	[wf setPositivePrefix:@""];
	[relativeEnergyButton setText:[wf stringForFloat:fabsf(gap)] forPart:1];
	[relativeEnergyButton setTextColor:energyColor forPart:1];
	[wf release];
	relativeEnergyButton.enabled = YES;
}


- (void)updateGraph {
	TrendSpan *span = spanArray[spanIndex];
	
	GraphViewParameters *gp;
	GraphDrawingOperation *op;
	CGImageRef imgRef;
	
	if (showFat) {
		gp = span.fatGraphParameters;
		op = (GraphDrawingOperation *)span.fatGraphOperation;
		imgRef = span.fatGraphImageRef;
	} else {
		gp = span.totalGraphParameters;
		op = (GraphDrawingOperation *)span.totalGraphOperation;
		imgRef = span.totalGraphImageRef;
	}
		
	if (!gp->shouldDrawNoDataWarning) {
		gp->shouldDrawNoDataWarning = YES;
		[GraphDrawingOperation prepareGraphViewInfo:gp 
											forSize:graphView.bounds.size
									   numberOfDays:span.length
										   database:database];
	}
	
	graphView.beginMonthDay = EWMonthDayNext(span.beginMonthDay);
	graphView.endMonthDay = span.endMonthDay;
	graphView.p = gp;
	graphView.image = imgRef;
	[graphView setNeedsDisplay];
	
	if (imgRef == nil && op == nil) {
		op = [[GraphDrawingOperation alloc] init];
		op.database = database;
		op.delegate = self;
		op.index = spanIndex;
		op.p = graphView.p;
		op.bounds = graphView.bounds;
		op.beginMonthDay = graphView.beginMonthDay;
		op.endMonthDay = graphView.endMonthDay;
		op.showGoalLine = YES;
		op.showTrajectoryLine = YES;
		if (showFat) {
			span.fatGraphOperation = op;
		} else {
			span.totalGraphOperation = op;
		}
		[op enqueue];
		[op release];
	}
}


- (void)drawingOperationComplete:(GraphDrawingOperation *)operation {
	if ([operation isCancelled]) return;
	TrendSpan *span = spanArray[operation.index];
	BOOL isFat = operation.p->showFatWeight;

	// Display now, if needed
	if (operation.index == spanIndex && isFat == showFat) {
		[graphView setImage:operation.imageRef];
		[graphView setNeedsDisplay];
	}

	if (span.totalGraphOperation == operation) {
		span.totalGraphImageRef = operation.imageRef;
		span.totalGraphOperation = nil;
	}
	else if (span.fatGraphOperation == operation) {
		span.fatGraphImageRef = operation.imageRef;
		span.fatGraphOperation = nil;
	}
}


/* How do we know when we have attained our goal? This menthod used to employ a
 naïve comparison between the latest trend value and the goal weight. That 
 method would display "goal attained" before the real weight had crossed the
 goal line.
 
 Now we scan backwards and ask the following questions:
 
 (1) Has the trend line crossed the goal line?
 
 (2) Has the trend line crossed outside the 5 lb goal band?
 
 If (2) comes before (1), the goal has been attained. Otherwise, it has not.
 This indicates the trend line has entered the goal zone and is staying around
 it. */

- (void)updateGoalState {
	EWGoal *goal = [[EWGoal alloc] initWithDatabase:database];

	if (! goal.defined) {
		goalState = TrendGoalStateUndefined;
		[goal release];
		return;
	}
	
	float goalWeight = goal.endWeight;
	
	[goal release];
	
	// Scan backwards, see what happens first.
	
	BOOL trendAboveGoal = NO;
	BOOL trendBelowGoal = NO;
	BOOL trendOutsideBand = NO;
	NSUInteger loopLimit = 360;
	
	EWDBIterator *it = [database iterator];
	it.latestMonthDay = EWMonthDayToday();
	const EWDBDay *dd;
	while ((dd = [it previousDBDay]) && (loopLimit--)) {
		if (dd->trendWeight > 0) {
			float delta = goalWeight - dd->trendWeight;
			if (delta > 0) {
				trendBelowGoal = YES;
				if (trendAboveGoal) break;
			} else {
				trendAboveGoal = YES;
				if (trendBelowGoal) break;
			}
			if (fabsf(delta) > gGoalBandHalfHeight) {
				trendOutsideBand = YES;
				break;
			}
		}
	}
	
	if (trendOutsideBand) {
		// We most recently were outside the band without crossing the line.
		goalState = TrendGoalStateDefined;
	} else if (trendAboveGoal && trendBelowGoal) {
		// We most recently crossed the line without leaving the band.
		goalState = TrendGoalStateAttained;
	} else {
		// We ran out of data (or got tired of looking) so let's count it.
		goalState = TrendGoalStateAttained;
	}
}


- (void)updateWeightChangeButtonWithRate:(float)weightPerDay {
	NSString *weightChangeText;
	UIColor *weightChangeColor;
	if (showFat) {
		weightChangeText = @"fat";
		weightChangeColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.8f alpha:1];
	} else {
		weightChangeText = @"total weight";
		weightChangeColor = [UIColor colorWithRed:0.8f green:0.1f blue:0.1f alpha:1];
	}

	[weightChangeButton setText:weightChangeText forPart:3];
	[weightChangeButton setTextColor:weightChangeColor forPart:3];
	[weightChangeButton setSelected:showFat];
	
	NSString *part0Text;
	NSString *part1Text;
	
	if (isnan(weightPerDay)) {
		part0Text = @"";
		part1Text = @"insufficient measurements";
	} else {
		if (weightPerDay > 0) {
			part0Text = @"gaining ";
		} else {
			part0Text = @"losing ";
		}
		NSNumber *change = @(fabsf(weightPerDay));
		NSNumberFormatter *wf = [[EWWeightChangeFormatter alloc] initWithStyle:EWWeightChangeFormatterStyleWeightPerWeek];
		[wf setPositivePrefix:@""];
		part1Text = [wf stringForObjectValue:change];
		[wf release];
	}
	[weightChangeButton setText:part0Text forPart:0];
	[weightChangeButton setText:part1Text forPart:1];
}


- (void)updateEnergyChangeButtonWithRate:(float)weightPerDay {
	energyChangeButton.hidden = isnan(weightPerDay);
	if (energyChangeButton.hidden) return;

	if (weightPerDay > 0) {
		[energyChangeButton setText:@"eating " forPart:0];
		[energyChangeButton setText:@" more than you burn" forPart:2];
	} else {
		[energyChangeButton setText:@"burning " forPart:0];
		[energyChangeButton setText:@" more than you eat" forPart:2];
	}
	NSNumber *change = @(fabsf(weightPerDay));
	NSNumberFormatter *ef = [[EWWeightChangeFormatter alloc] initWithStyle:EWWeightChangeFormatterStyleEnergyPerDay];
	[ef setPositivePrefix:@""];
	[energyChangeButton setText:[ef stringForObjectValue:change] forPart:1];
	[ef release];
	
}


- (void)updateControlsWithSpan:(TrendSpan *)span {
	[[NSUserDefaults standardUserDefaults] setInteger:span.length forKey:kTrendSpanLengthKey];
	
	UINavigationItem *navItem = self.navigationItem;
	navItem.title = span.title;
	navItem.leftBarButtonItem.enabled = (spanIndex + 1 < [spanArray count]);
	navItem.rightBarButtonItem.enabled = (spanIndex > 0);

	[self updateGraph];

	float weightPerDay = (showFat ? span.fatWeightPerDay : span.totalWeightPerDay);
		 
	changeGroupView.hidden = NO;
	
	[self updateWeightChangeButtonWithRate:weightPerDay];
	[self updateEnergyChangeButtonWithRate:weightPerDay];
	
	if (isnan(weightPerDay)) {
		goalGroupView.hidden = YES;
	} else {
		switch (goalState) {
			case TrendGoalStateUndefined:
			{
				goalGroupView.hidden = YES;
				break;
			}
			case TrendGoalStateDefined:
			{
				NSDate *endDate = showFat ? span.fatEndDate : span.totalEndDate;
				goalGroupView.hidden = NO;
				goalAttainedView.hidden = YES;
				dateButton.hidden = NO;
				planButton.hidden = NO;
				relativeEnergyButton.hidden = NO;
				relativeWeightButton.hidden = NO;
				[self updateDateButtonWithDate:endDate];
				[self updatePlanButtonWithDate:endDate];
				[self updateRelativeEnergyButtonWithRate:weightPerDay];
				[self updateRelativeWeightButton];
				break;
			}
			case TrendGoalStateAttained:
			{
				goalGroupView.hidden = NO;
				goalAttainedView.hidden = NO;
				if ([goalAttainedView superview] == nil) {
					goalAttainedView.frame = goalGroupView.bounds;
					[goalGroupView addSubview:goalAttainedView];
				}
				dateButton.hidden = YES;
				planButton.hidden = YES;
				relativeEnergyButton.hidden = YES;
				relativeWeightButton.hidden = YES;
				break;
			}
		}
	}
	
	flagGroupView.hidden = NO;
	NSNumberFormatter *pf = [[NSNumberFormatter alloc] init];
	[pf setNumberStyle:NSNumberFormatterPercentStyle];
	flag0Label.text = [pf stringForFloat:span.flagFrequencies[0]];
	flag1Label.text = [pf stringForFloat:span.flagFrequencies[1]];
	flag2Label.text = [pf stringForFloat:span.flagFrequencies[2]];
	flag3Label.text = [pf stringForFloat:span.flagFrequencies[3]];
	[pf release];
}


- (void)updateControls {
	if (spanIndex < [spanArray count]) {
		[self updateControlsWithSpan:spanArray[spanIndex]];
		messageGroupView.hidden = YES;
	} else {
		UINavigationItem *navItem = self.navigationItem;
		navItem.title = @"Not Enough Data";
		navItem.leftBarButtonItem.enabled = NO;
		navItem.rightBarButtonItem.enabled = NO;
		// An import could have removed data where there was data before.
		graphView.image = nil;
		[graphView setNeedsDisplay];
		changeGroupView.hidden = YES;
		goalGroupView.hidden = YES;
		flagGroupView.hidden = YES;
		messageGroupView.hidden = NO;
	}
}


#pragma mark Actions


- (IBAction)previousSpan:(id)sender {
	if (spanIndex > 0) {
		spanIndex -= 1;
		[self updateControls];
	}
}


- (IBAction)nextSpan:(id)sender {
	if (spanIndex + 1 < [spanArray count]) {
		spanIndex += 1;
		[self updateControls];
	}
}


- (IBAction)showEnergyEquivalents:(id)sender {
	TrendSpan *span = spanArray[spanIndex];
	float rate = showFat ? span.fatWeightPerDay : span.totalWeightPerDay;
	
	if (sender == relativeEnergyButton) {
		EWGoal *goal = [[EWGoal alloc] initWithDatabase:database];
		float plan = [goal weightChangePerDay];
		rate = fabsf(rate - plan);
		[goal release];
	} else {
		rate = fabsf(rate);
	}

	float weight = [database latestWeight];
	EnergyViewController *ctrlr = [[EnergyViewController alloc] initWithWeight:weight andChangePerDay:rate database:database];
	[self.navigationController pushViewController:ctrlr animated:YES];
	[ctrlr release];
}


- (IBAction)toggleDateFormat:(id)sender {
	showAbsoluteDate = !showAbsoluteDate;
	[[NSUserDefaults standardUserDefaults] setBool:showAbsoluteDate 
											forKey:kTrendShowAbsoluteDateKey];
	[self updateControls];
}


- (IBAction)toggleTotalOrFat:(id)sender {
	showFat = !showFat;
	[[NSUserDefaults standardUserDefaults] setBool:showFat
											forKey:kTrendShowFatKey];
	[self updateControls];
}


#pragma mark Cleanup


- (void)dealloc {
	[database release];
	[weightChangeButton release];
	[energyChangeButton release];
	[goalGroupView release];
	[relativeEnergyButton release];
	[relativeWeightButton release];
	[dateButton release];
	[planButton release];
	[flag0Label release];
	[flag1Label release];
	[flag2Label release];
	[flag3Label release];
	[messageGroupView release];
	[goalAttainedView release];
	[super dealloc];
}


@end
