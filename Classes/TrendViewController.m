//
//  TrendViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "TrendViewController.h"
#import "EWDatabase.h"
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

/*
 [W]	weight change
 [E]	energy change
 [P]	relative to plan
 
 [A]	weight to goal
 [D]	time to goal
 [S]	relative to plan
 
 Values:
 
 [W]	[+1.0 lbs/week] gaining
 [W]	[-1.0 lbs/week] losing
 
 [E]	[+52 cal/day] eating more than you burn
 [E]	[-52 cal/day] burning more than you eat
 
 [P]	burning 10 cal/day more than plan
 [P]	eating 10 cal/day less than plan
 [P]	burning 10 cal/day less than plan
 [P]	eating 10 cal/day more than plan
		tap: calorie equivalents
 
 [A]	[27 lbs] to gain
 [A]	[12 lbs] to lose
 
 [D]	goal on [March 27, 2010]
 [D]	goal in 27 days
 [D]	goal attained
 [D]	moving away from goal
 
 [S]	more than a year behind plan
 [S]	12 days earlier than plan
 [S]	12 days later than plan

 Actions:
 
 [W]	nothing
 [E]	show calorie equivalents
 [P]	show calorie equivalents
 [A]	nothing
 [D]	toggle date vs. days-to
 [S]	nothing
 */


static const NSTimeInterval kSecondsPerDay = 60 * 60 * 24;


@interface TrendViewController ()
- (void)updateControls;
@end


@implementation TrendViewController


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


- (id)init {
	if (self = [super initWithNibName:@"TrendView" bundle:nil]) {
		self.title = NSLocalizedString(@"Trends", @"Trends view title");
		self.tabBarItem.image = [UIImage imageNamed:@"TabIconTrend.png"];
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(previousSpan:)] autorelease];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(nextSpan:)] autorelease];
	}
	return self;
}


- (void)databaseDidChange:(NSNotification *)notice {
	[spanArray release];
	spanArray = nil;
}


- (void)viewDidLoad {
	goalGroupView.backgroundColor = self.view.backgroundColor;
	
	graphView.backgroundColor = [UIColor whiteColor];
	
	weightChangeButton.enabled = NO;
	relativeWeightButton.enabled = NO;
	planButton.enabled = NO;
	
	energyChangeButton.showsDisclosureIndicator = YES;
	relativeEnergyButton.showsDisclosureIndicator = YES;
	
	[relativeEnergyButton setText:@"burning " forPart:0];
	[relativeEnergyButton setText:@"10 cal/day" forPart:1];
	[relativeEnergyButton setText:@" less than plan" forPart:2];
	
	[relativeWeightButton setText:@"27 lb" forPart:0];
	[relativeWeightButton setText:@" to lose" forPart:1];
	
	UIFont *boldFont = [UIFont boldSystemFontOfSize:17];
	[weightChangeButton setFont:boldFont forPart:0];
	[energyChangeButton setFont:boldFont forPart:0];
	[relativeEnergyButton setFont:boldFont forPart:1];
	[relativeWeightButton setFont:boldFont forPart:0];
	[dateButton setFont:boldFont forPart:1];
	[planButton setFont:boldFont forPart:0];

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(databaseDidChange:) 
												 name:EWDatabaseDidChangeNotification 
											   object:nil];
	
	[self.view addSubview:messageGroupView];
	messageGroupView.hidden = YES;
	CGRect frame = messageGroupView.frame;
	frame.origin.x = 0;
	frame.origin.y = CGRectGetMinY(changeGroupView.frame);
	messageGroupView.frame = frame;
}


- (void)viewWillAppear:(BOOL)animated {
	if (spanArray == nil) {
		spanArray = [[TrendSpan computeTrendSpans] copy];
	}
	[self updateControls];
}


- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)updateDateButtonWithDate:(NSDate *)date {
	if (date) {
		int dayCount = floor([date timeIntervalSinceNow] / kSecondsPerDay);
		if (dayCount > 365) {
			[dateButton setText:@"goal in " forPart:0];
			[dateButton setText:@"over a year" forPart:1];
		} else if (showAbsoluteDate) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterLongStyle];
			[formatter setTimeStyle:NSDateFormatterNoStyle];
			[dateButton setText:@"goal on " forPart:0];
			[dateButton setText:[formatter stringFromDate:date] forPart:1];
			[formatter release];
		} else if (dayCount == 0) {
			[dateButton setText:@"goal " forPart:0];
			[dateButton setText:@"today" forPart:1];
		} else {
			[dateButton setText:@"goal in " forPart:0];
			[dateButton setText:[NSString stringWithFormat:@"%d days", dayCount] forPart:1];
		}
		[dateButton setTextColor:[UIColor blackColor] forPart:1];
	} else {
		[dateButton setText:@"" forPart:0];
		if ([[EWGoal sharedGoal] isAttained]) {
			[dateButton setText:@"goal attained" forPart:1];
			[dateButton setTextColor:[BRColorPalette colorNamed:@"GoodText"] forPart:1];
		} else {
			[dateButton setText:@"moving away from goal" forPart:1];
			[dateButton setTextColor:[BRColorPalette colorNamed:@"BadText"] forPart:1];
		}
	}
}


- (void)updatePlanButtonWithDate:(NSDate *)date {
	if (date) {
		NSTimeInterval t = [date timeIntervalSinceDate:[[EWGoal sharedGoal] endDate]];
		int dayCount = floor(t / kSecondsPerDay);
		if (dayCount > 0) {
			if (dayCount > 365) {
				[planButton setText:@"over a year" forPart:0];
			} else if (dayCount == 1) {
				[planButton setText:@"1 day" forPart:0];
			} else {
				[planButton setText:[NSString stringWithFormat:@"%d days", dayCount] forPart:0];
			}
			[planButton setText:@" later than plan" forPart:1];
			[planButton setTextColor:[BRColorPalette colorNamed:@"WarningText"] forPart:0];
		} else if (dayCount < 0) {
			if (dayCount < -365) {
				[planButton setText:@"over a year" forPart:0];
			} else if (dayCount == -1) {
				[planButton setText:@"1 day" forPart:0];
			} else {
				[planButton setText:[NSString stringWithFormat:@"%d days", -dayCount] forPart:0];
			}
			[planButton setText:@" earlier than plan" forPart:1];
			[planButton setTextColor:[BRColorPalette colorNamed:@"GoodText"] forPart:0];
		} else {
			[planButton setText:@"on schedule" forPart:0];
			[planButton setText:@" according to plan" forPart:1];
			[planButton setTextColor:[BRColorPalette colorNamed:@"GoodText"] forPart:0];
		}
		planButton.hidden = NO;
	} else {
		planButton.hidden = YES;
	}
}


- (void)updateRelativeWeightButton {
	float goalWeight = [[EWGoal sharedGoal] endWeight];
	float currentWeight = [[EWDatabase sharedDatabase] trendWeightOnMonthDay:EWMonthDayToday()];
	
	EWWeightFormatter *wf = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleDisplay];
	[relativeWeightButton setText:[wf stringForFloat:fabsf(goalWeight - currentWeight)]
						  forPart:0];
	[relativeWeightButton setText:((goalWeight > currentWeight) ? 
								   @" to gain" :
								   @" to lose") 
						  forPart:1];
}


- (void)updateRelativeEnergyButtonWithRate:(float)rate {
	float plan = [[EWGoal sharedGoal] weightChangePerDay];
/*
	plan	rate
	+10		+15		eating 5 more		15-10=	+5
	+10		+5		eating 5 less		 5-10=	-5
	-10		-15		burning 5 more		-15+10=	-5
	-10		-5		burning 5 less		-5+10=  +5 ***

	-10		+5		eating 15 more		 5+10= +15
	+10		-5		burning 15 less		-5-10= -15
 
	+60		-82		burning (-82-60) more	
*/
	
	[relativeEnergyButton setText:(rate < 0 ? @"burning " : @"eating ") forPart:0];
	
	NSNumberFormatter *wf = [[EWWeightChangeFormatter alloc] initWithStyle:EWWeightChangeFormatterStyleEnergyPerDay];
	[wf setPositivePrefix:@""];
	[relativeEnergyButton setText:[wf stringForFloat:fabsf(rate - plan)]
						  forPart:1];
	[wf release];
	
	BOOL more;
	
	if (rate > 0 && plan > 0) {
		more = (rate > plan);
	}
	else if (rate < 0 && plan < 0) {
		more = (rate < plan);
	}
	else {
		more = (rate > 0 && plan < 0);
	}
	
	[relativeEnergyButton setText:(more ?
								   @" more than plan" :
								   @" less than plan")
						  forPart:2];
}


- (void)updateGraph {
	TrendSpan *span = [spanArray objectAtIndex:spanIndex];
	
	GraphViewParameters *gp = span.graphParameters;
	
	if (gp->gridIncrementWeight == 0) {
		[GraphDrawingOperation prepareGraphViewInfo:gp 
											forSize:graphView.bounds.size
									   numberOfDays:span.length];
	}
	
	graphView.beginMonthDay = span.beginMonthDay;
	graphView.endMonthDay = span.endMonthDay;
	graphView.p = span.graphParameters;
	graphView.image = span.graphImageRef;
	[graphView setNeedsDisplay];
	
	if (span.graphImageRef == nil && span.graphOperation == nil) {
		GraphDrawingOperation *op = [[GraphDrawingOperation alloc] init];
		op.delegate = self;
		op.index = spanIndex;
		op.p = span.graphParameters;
		op.bounds = graphView.bounds;
		op.beginMonthDay = span.beginMonthDay;
		op.endMonthDay = span.endMonthDay;
		span.graphOperation = op;
		[op enqueue];
		[op release];
	}
}


- (void)drawingOperationComplete:(GraphDrawingOperation *)operation {
	TrendSpan *span = [spanArray objectAtIndex:operation.index];
	
	if (span.graphOperation == operation && ![operation isCancelled]) {
		span.graphImageRef = operation.imageRef;
		if (operation.index == spanIndex) {
			[graphView setImage:span.graphImageRef];
			[graphView setNeedsDisplay];
		}
		span.graphOperation = nil;
	}
}


- (void)updateControlsWithSpan:(TrendSpan *)span {
	UINavigationItem *navItem = self.navigationItem;
	navItem.title = span.title;
	navItem.leftBarButtonItem.enabled = (spanIndex > 0);
	navItem.rightBarButtonItem.enabled = (spanIndex + 1 < [spanArray count]);

	[self updateGraph];
	
	changeGroupView.hidden = NO;
	NSNumber *change = [NSNumber numberWithFloat:span.weightPerDay];
	
	NSFormatter *wf = [[EWWeightChangeFormatter alloc] initWithStyle:EWWeightChangeFormatterStyleWeightPerWeek];
	[weightChangeButton setText:[wf stringForObjectValue:change] forPart:0];
	[weightChangeButton setText:(span.weightPerDay > 0 ?
								 @" gaining" :
								 @" losing")
						forPart:1];
	[wf release];

	NSFormatter *ef = [[EWWeightChangeFormatter alloc] initWithStyle:EWWeightChangeFormatterStyleEnergyPerDay];
	[energyChangeButton setText:[ef stringForObjectValue:change] forPart:0];
	[energyChangeButton setText:(span.weightPerDay > 0 ? 
								 @" eating more than you burn" : 
								 @" burning more than you eat")
						forPart:1];
	[ef release];
	
	goalGroupView.hidden = ![[EWGoal sharedGoal] isDefined];
	if (!goalGroupView.hidden) {
		[self updateRelativeWeightButton];
		[self updateRelativeEnergyButtonWithRate:span.weightPerDay];
		[self updateDateButtonWithDate:span.endDate];
		[self updatePlanButtonWithDate:span.endDate];
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
		[self updateControlsWithSpan:[spanArray objectAtIndex:spanIndex]];
		messageGroupView.hidden = YES;
	} else {
		UINavigationItem *navItem = self.navigationItem;
		navItem.title = @"Not Enough Data";
		navItem.leftBarButtonItem.enabled = NO;
		navItem.rightBarButtonItem.enabled = NO;
		changeGroupView.hidden = YES;
		goalGroupView.hidden = YES;
		flagGroupView.hidden = YES;
		messageGroupView.hidden = NO;
	}
}


#pragma mark Actions


- (void)previousSpan:(id)sender {
	if (spanIndex > 0) {
		spanIndex -= 1;
		[self updateControls];
	}
}


- (void)nextSpan:(id)sender {
	if (spanIndex + 1 < [spanArray count]) {
		spanIndex += 1;
		[self updateControls];
	}
}


- (IBAction)showEnergyEquivalents:(id)sender {
	TrendSpan *span = [spanArray objectAtIndex:spanIndex];
	float rate = span.weightPerDay;
	
	if (sender == relativeEnergyButton) {
		float plan = [[EWGoal sharedGoal] weightChangePerDay];
		rate = fabsf(rate - plan);
	} else {
		rate = fabsf(rate);
	}

	// FIXME: find latest weight in DB; this code will fail if last month has no weight
	EWDatabase *db = [EWDatabase sharedDatabase];
	EWDBMonth *month = [db getDBMonth:db.latestMonth];
	const EWDBDay *day = [month getDBDayOnDay:[month lastDayWithWeight]];
	float weight = day->trendWeight;
	EnergyViewController *ctrlr = [[EnergyViewController alloc] initWithWeight:weight
															   andChangePerDay:rate];
	[self.navigationController pushViewController:ctrlr animated:YES];
	[ctrlr release];
}


- (IBAction)toggleDateFormat:(id)sender {
	showAbsoluteDate = !showAbsoluteDate;
	[self updateControls];
}


#pragma mark Cleanup


- (void)dealloc {
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
	[super dealloc];
}


@end
