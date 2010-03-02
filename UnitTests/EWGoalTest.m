//
//  EWGoalTest.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/28/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "EWGoal.h"
#import "EWDatabase.h"
#import "EWDBMonth.h"


@interface EWGoalTest : SenTestCase 
{
}
@end



@implementation EWGoalTest


- (void)testUpgrade {
	EWDatabase *testdb = [[EWDatabase alloc] initWithSQLNamed:@"DBCreate3"];
	[EWDatabase setSharedDatabase:testdb];
	[testdb release];
	
	EWDBDay dbd;
	dbd.scaleWeight = 100;
	dbd.scaleFatWeight = 0;
	dbd.flags[0] = 0;
	dbd.flags[1] = 0;
	dbd.flags[2] = 0;
	dbd.flags[3] = 0;
	dbd.note = nil;
	[[testdb getDBMonth:0] setDBDay:&dbd onDay:1];
	[testdb commitChanges];
	
	[NSUserDefaults resetStandardUserDefaults];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setInteger:0 forKey:@"GoalStartDate"];
	[ud setFloat:5 forKey:@"GoalWeightChangePerDay"];
	[ud setFloat:90 forKey:@"GoalWeight"];
	
	NSLog(@"BEFORE %@", [ud dictionaryRepresentation]);
	EWGoal *goal = [EWGoal sharedGoal];
	NSLog(@"AFTER %@", [ud dictionaryRepresentation]);
	
	STAssertNil([ud objectForKey:@"GoalStartDate"], @"start date removed");
	STAssertNil([ud objectForKey:@"GoalWeightChangePerDay"], @"change removed");
	STAssertNotNil([ud objectForKey:@"GoalWeight"], @"goal weight set");
	STAssertNotNil([ud objectForKey:@"GoalDate"], @"goal date set");
	STAssertEquals(goal.currentWeight, 100.0f, @"current weight");
	STAssertEquals(goal.endWeight, 90.0f, @"goal weight");

	[EWDatabase setSharedDatabase:nil];
}


@end
