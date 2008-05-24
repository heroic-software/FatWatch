//
//  DatabaseTest.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/23/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Database.h"
#import "MonthData.h"

@interface DatabaseTest : SenTestCase
{
}
@end


@implementation DatabaseTest

- (void)openDatabase {
	NSString *srcPath = @"/Users/benzado/Projects/iPhone/EatWatch/WeightData.db";
	//[[NSBundle mainBundle] pathForResource:@"WeightData" ofType:@"db"];
	NSLog(@"source database: %@", srcPath);
	NSString *dstPath = @"test.db";
	[[NSFileManager defaultManager] removeItemAtPath:dstPath error:nil];
	BOOL didCopy = [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:nil];
	STAssertTrue(didCopy, @"must copy");
	
	Database *db = [Database sharedDatabase];
	[db openAtPath:dstPath];
	STAssertEquals((NSUInteger)0, [db weightCount], @"should be empty");
}


- (void)closeDatabase {
	[[Database sharedDatabase] close];
	BOOL didDelete = [[NSFileManager defaultManager] removeItemAtPath:@"test.db" error:nil];
	STAssertTrue(didDelete, @"must delete");
}


- (void)setWeight:(float)weight onDay:(EWDay)day inMonth:(EWMonth)month {
	MonthData *md = [[Database sharedDatabase] dataForMonth:month];
	[md setMeasuredWeight:weight flag:NO note:nil onDay:day];
}


- (void)commitDatabase {
	NSUInteger ccBefore = [[Database sharedDatabase] changeCount];
	[[Database sharedDatabase] commitChanges];
	NSUInteger ccAfter = [[Database sharedDatabase] changeCount];
	STAssertTrue(ccBefore != ccAfter, @"change count must change");
}


- (void)assertWeight:(float)weight andTrend:(float)trend onDay:(EWDay)day inMonth:(EWMonth)month {
	MonthData *md = [[Database sharedDatabase] dataForMonth:month];
	STAssertEquals(weight, [md measuredWeightOnDay:day], @"weight must match");
	STAssertEqualsWithAccuracy(trend, [md trendWeightOnDay:day], 0.0001f, @"trend must match");
}


- (void)testDatabase {
	[self openDatabase];

	// set up 10 weights
	[self setWeight:100 onDay:15 inMonth:0];
	[self setWeight:200 onDay:18 inMonth:0];
	[self setWeight:100 onDay: 6 inMonth:3];
	[self setWeight:200 onDay: 7 inMonth:3];
	[self setWeight:100 onDay:29 inMonth:4];
	[self setWeight:200 onDay:30 inMonth:4];
	[self setWeight:100 onDay: 1 inMonth:7];
	[self setWeight:200 onDay:15 inMonth:7];
	[self setWeight:100 onDay:31 inMonth:7];
	[self setWeight:200 onDay:15 inMonth:8];
	[self commitDatabase];
	
	// verify trends
	STAssertEquals(0.0f, [[[Database sharedDatabase] dataForMonth:0] inputTrendOnDay:14], @"before first trend");
	STAssertEquals(100.0f, [[[Database sharedDatabase] dataForMonth:0] inputTrendOnDay:15], @"first trend");
	[self assertWeight:100 andTrend:100.0000 onDay:15 inMonth:0];
	[self assertWeight:200 andTrend:110.0000 onDay:18 inMonth:0];
	[self assertWeight:100 andTrend:109.0000 onDay: 6 inMonth:3];
	[self assertWeight:200 andTrend:118.1000 onDay: 7 inMonth:3];
	[self assertWeight:100 andTrend:116.2900 onDay:29 inMonth:4];
	[self assertWeight:200 andTrend:124.6610 onDay:30 inMonth:4];
	[self assertWeight:100 andTrend:122.1949 onDay: 1 inMonth:7];
	[self assertWeight:200 andTrend:129.9754 onDay:15 inMonth:7];
	[self assertWeight:100 andTrend:126.9778 onDay:31 inMonth:7];
	[self assertWeight:200 andTrend:134.2800 onDay:15 inMonth:8];
	STAssertEquals((NSUInteger)10, [[Database sharedDatabase] weightCount], @"10 items");
	
	// delete one weight and verify trends
	[self setWeight:0 onDay:30 inMonth:4];
	[self commitDatabase];
	[self assertWeight:100 andTrend:100.0000 onDay:15 inMonth:0];
	[self assertWeight:200 andTrend:110.0000 onDay:18 inMonth:0];
	[self assertWeight:100 andTrend:109.0000 onDay: 6 inMonth:3];
	[self assertWeight:200 andTrend:118.1000 onDay: 7 inMonth:3];
	[self assertWeight:100 andTrend:116.2900 onDay:29 inMonth:4];
	[self assertWeight:  0 andTrend:  0      onDay:30 inMonth:4];
	[self assertWeight:100 andTrend:114.6610 onDay: 1 inMonth:7];
	[self assertWeight:200 andTrend:123.1949 onDay:15 inMonth:7];
	[self assertWeight:100 andTrend:120.8754 onDay:31 inMonth:7];
	[self assertWeight:200 andTrend:128.7879 onDay:15 inMonth:8];
	STAssertEquals((NSUInteger)9, [[Database sharedDatabase] weightCount], @"9 weights");

	// append one weight and verify trends
	[self setWeight:100 onDay:11 inMonth:9];
	[self commitDatabase];
	[self assertWeight:100 andTrend:100.0000 onDay:15 inMonth:0];
	[self assertWeight:200 andTrend:110.0000 onDay:18 inMonth:0];
	[self assertWeight:100 andTrend:109.0000 onDay: 6 inMonth:3];
	[self assertWeight:200 andTrend:118.1000 onDay: 7 inMonth:3];
	[self assertWeight:100 andTrend:116.2900 onDay:29 inMonth:4];
	[self assertWeight:  0 andTrend:  0      onDay:30 inMonth:4];
	[self assertWeight:100 andTrend:114.6610 onDay: 1 inMonth:7];
	[self assertWeight:200 andTrend:123.1949 onDay:15 inMonth:7];
	[self assertWeight:100 andTrend:120.8754 onDay:31 inMonth:7];
	[self assertWeight:200 andTrend:128.7879 onDay:15 inMonth:8];
	[self assertWeight:100 andTrend:125.9091 onDay:11 inMonth:9];
	STAssertEquals((NSUInteger)10, [[Database sharedDatabase] weightCount], @"10 weights");
	
	// prepend one weight and verify trends
	[self setWeight:200 onDay:8 inMonth:-2];
	[self commitDatabase];
	[self assertWeight:200 andTrend:200.0000 onDay: 8 inMonth:-2];
	[self assertWeight:100 andTrend:190.0000 onDay:15 inMonth:0];
	[self assertWeight:200 andTrend:191.0000 onDay:18 inMonth:0];
	[self assertWeight:100 andTrend:181.9000 onDay: 6 inMonth:3];
	[self assertWeight:200 andTrend:183.7100 onDay: 7 inMonth:3];
	[self assertWeight:100 andTrend:175.3390 onDay:29 inMonth:4];
	[self assertWeight:  0 andTrend:  0      onDay:30 inMonth:4];
	[self assertWeight:100 andTrend:167.8051 onDay: 1 inMonth:7];
	[self assertWeight:200 andTrend:171.0246 onDay:15 inMonth:7];
	[self assertWeight:100 andTrend:163.9221 onDay:31 inMonth:7];
	[self assertWeight:200 andTrend:167.5299 onDay:15 inMonth:8];
	[self assertWeight:100 andTrend:160.7769 onDay:11 inMonth:9];
	STAssertEquals((NSUInteger)11, [[Database sharedDatabase] weightCount], @"11 weights");
	
	[self closeDatabase];
}

@end
