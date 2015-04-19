/*
 * EWGoalTest.m
 * Created by Benjamin Ragheb on 1/28/10.
 * Copyright 2015 Heroic Software Inc
 *
 * This file is part of FatWatch.
 *
 * FatWatch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FatWatch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "EWGoal.h"
#import "EWDatabase.h"
#import "EWDBMonth.h"


@interface EWGoalTest : XCTestCase 
@end

@implementation EWGoalTest


- (void)testUpgrade {
	EWDatabase *testdb = [[EWDatabase alloc] initWithSQLNamed:@"DBCreate3" bundle:[NSBundle bundleForClass:[self class]]];
	
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
	EWGoal *goal = [[EWGoal alloc] initWithDatabase:testdb];
	NSLog(@"AFTER %@", [ud dictionaryRepresentation]);
	
	XCTAssertNil([ud objectForKey:@"GoalStartDate"], @"start date removed");
	XCTAssertNil([ud objectForKey:@"GoalWeightChangePerDay"], @"change removed");
	XCTAssertNotNil([ud objectForKey:@"GoalWeight"], @"goal weight set");
	XCTAssertNotNil([ud objectForKey:@"GoalDate"], @"goal date set");
	XCTAssertEqual(goal.currentWeight, 100.0f, @"current weight");
	XCTAssertEqual(goal.endWeight, 90.0f, @"goal weight");

}


@end
