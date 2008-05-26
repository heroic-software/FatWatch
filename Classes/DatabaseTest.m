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
	NSUInteger changeCount;
}
@end


@implementation DatabaseTest

- (void)setWeight:(float)weight onDay:(EWDay)day inMonth:(EWMonth)month {
	MonthData *md = [[Database sharedDatabase] dataForMonth:month];
	[md setMeasuredWeight:weight flag:NO note:nil onDay:day];
}


- (void)databaseDidChange:(NSNotification *)notice {
	changeCount += 1;
}


- (void)commitDatabase {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(databaseDidChange:) name:EWDatabaseDidChangeNotification object:nil];
	NSUInteger oldChangeCount = changeCount;
	[[Database sharedDatabase] commitChanges];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	STAssertTrue(oldChangeCount != changeCount, @"change count must change");
}


- (void)openDatabase {
	NSString *srcPath = @"/Build/Products/Debug/UnitTests.octest/WeightData.db";
	//[[NSBundle mainBundle] pathForResource:@"WeightData" ofType:@"db"];
	NSLog(@"source database: %@", srcPath);
	NSString *dstPath = @"test.db";
	[[NSFileManager defaultManager] removeItemAtPath:dstPath error:nil];
	BOOL didCopy = [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:nil];
	STAssertTrue(didCopy, @"must copy");
	
	Database *db = [Database sharedDatabase];
	[db openAtPath:dstPath];
	STAssertEquals((NSUInteger)0, [db weightCount], @"should be empty");

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
}


- (void)closeDatabase {
	[[Database sharedDatabase] close];
	BOOL didDelete = [[NSFileManager defaultManager] removeItemAtPath:@"test.db" error:nil];
	STAssertTrue(didDelete, @"must delete");
}


- (void)assertWeight:(float)weight andTrend:(float)trend onDay:(EWDay)day inMonth:(EWMonth)month {
	MonthData *md = [[Database sharedDatabase] dataForMonth:month];
	STAssertEquals(weight, [md measuredWeightOnDay:day], @"weight must match");
	STAssertEqualsWithAccuracy(trend, [md trendWeightOnDay:day], 0.0001f, @"trend must match");
}


- (void)testDatabase {
	[self openDatabase];
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
	[self closeDatabase];
}


- (void)testDeleteInMiddle {
	[self openDatabase];
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
	[self closeDatabase];
}


- (void)testAppendWeight {
	[self openDatabase];
	// append one weight and verify trends
	[self setWeight:100 onDay:11 inMonth:9];
	[self commitDatabase];
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
	[self assertWeight:100 andTrend:130.8520 onDay:11 inMonth:9];
	STAssertEquals((NSUInteger)11, [[Database sharedDatabase] weightCount], @"11 weights");
	[self closeDatabase];
}


- (void)testPrependWeight {
	[self openDatabase];
	// prepend one weight and verify trends
	[self setWeight:200 onDay:8 inMonth:-2];
	[self commitDatabase];
	[self assertWeight:200 andTrend:200.0000 onDay: 8 inMonth:-2];
	[self assertWeight:100 andTrend:190.0000 onDay:15 inMonth:0];
	[self assertWeight:200 andTrend:191.0000 onDay:18 inMonth:0];
	[self assertWeight:100 andTrend:181.9000 onDay: 6 inMonth:3];
	[self assertWeight:200 andTrend:183.7099 onDay: 7 inMonth:3];
	[self assertWeight:100 andTrend:175.3389 onDay:29 inMonth:4];
	[self assertWeight:200 andTrend:177.8050 onDay:30 inMonth:4];
	[self assertWeight:100 andTrend:170.0245 onDay: 1 inMonth:7];
	[self assertWeight:200 andTrend:173.0221 onDay:15 inMonth:7];
	[self assertWeight:100 andTrend:165.7199 onDay:31 inMonth:7];
	[self assertWeight:200 andTrend:169.1479 onDay:15 inMonth:8];
	STAssertEquals((NSUInteger)11, [[Database sharedDatabase] weightCount], @"11 weights");
	[self closeDatabase];
}


- (void)testDeleteFirst {
	[self openDatabase];
	// delete first weight and verify trends
	[self setWeight:0 onDay:15 inMonth:0];
	[self commitDatabase];
	[self assertWeight:  0 andTrend:  0      onDay:15 inMonth:0];
	[self assertWeight:200 andTrend:200.0000 onDay:18 inMonth:0];
	[self assertWeight:100 andTrend:190.0000 onDay: 6 inMonth:3];
	[self assertWeight:200 andTrend:191.0000 onDay: 7 inMonth:3];
	[self assertWeight:100 andTrend:181.9000 onDay:29 inMonth:4];
	[self assertWeight:200 andTrend:183.7099 onDay:30 inMonth:4];
	[self assertWeight:100 andTrend:175.3389 onDay: 1 inMonth:7];
	[self assertWeight:200 andTrend:177.8050 onDay:15 inMonth:7];
	[self assertWeight:100 andTrend:170.0245 onDay:31 inMonth:7];
	[self assertWeight:200 andTrend:173.0221 onDay:15 inMonth:8];
	STAssertEquals((NSUInteger)9, [[Database sharedDatabase] weightCount], @"9 weights");
	[self closeDatabase];
}

@end
