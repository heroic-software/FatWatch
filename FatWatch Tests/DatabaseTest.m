//
//  DatabaseTest.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/23/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "EWDatabase.h"
#import "EWDBMonth.h"


@interface DatabaseTest : XCTestCase
@end


@implementation DatabaseTest
{
	EWDatabase *testdb;
	NSUInteger changeCount;
}

- (void)setWeight:(float)weight onDay:(EWDay)day inMonth:(EWMonth)month {
	EWDBMonth *dbm = [testdb getDBMonth:month];
	EWDBDay dbd;
	bcopy([dbm getDBDayOnDay:day], &dbd, sizeof(EWDBDay));
	dbd.scaleWeight = weight;
	[dbm setDBDay:&dbd onDay:day];
}


- (void)databaseDidChange:(NSNotification *)notice {
	changeCount += 1;
}


- (void)printDatabase {
	NSMutableString *output = [[NSMutableString alloc] init];
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM"];
	
	for (EWMonth month = testdb.earliestMonth; month <= testdb.latestMonth; month++) {
		EWDBMonth *dbm = [testdb getDBMonth:month];
		[output appendFormat:@"%@ (#%d)\n", 
		 [df stringFromDate:EWDateFromMonthAndDay(dbm.month, 1)],
		 month];

		for (EWDay day = 1; day <= 31; day++) {
			if (![dbm hasDataOnDay:day]) continue;
			const EWDBDay *d = [dbm getDBDayOnDay:day];
			[output appendFormat:@"  %2d:  %5.1f (%5.1f) %5.1f (%5.1f) 0x%08x \"%@\"\n",
			 day,
			 d->scaleWeight, d->trendWeight,
			 d->scaleFatWeight, d->trendFatWeight,
			 *(unsigned int *)&d->flags,
			 d->note];
		}
	}
	NSLog(@"DATABASE\n\n%@\n", output);
}


- (void)commitDatabase {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(databaseDidChange:) name:EWDatabaseDidChangeNotification object:nil];
	NSUInteger oldChangeCount = changeCount;
	[testdb commitChanges];
	[center removeObserver:self];
	XCTAssertTrue(oldChangeCount != changeCount, @"change count must change");
	[self printDatabase];
}


- (void)openDatabase {
	testdb = [[EWDatabase alloc] initWithSQLNamed:@"DBCreate2" bundle:[NSBundle bundleForClass:[self class]]];
	
	if ([testdb needsUpgrade]) [testdb upgrade];
	
	XCTAssertTrue([testdb isEmpty], @"should be empty");

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
	[testdb close];
	testdb = nil;
}


- (void)assertWeight:(float)weight andTrend:(float)trend onDay:(EWDay)day inMonth:(EWMonth)month {
	EWDBMonth *dbm = [testdb getDBMonth:month];
	const EWDBDay *d = [dbm getDBDayOnDay:day];
	XCTAssertEqual(weight, d->scaleWeight, @"mismatch on %@", EWDateFromMonthAndDay(month, day));
	XCTAssertEqualWithAccuracy(trend, d->trendWeight, 0.0001f, @"mismatch on %@", EWDateFromMonthAndDay(month, day));
}


- (void)testDatabase {
	[self openDatabase];
	// verify trends
	XCTAssertEqual(0.0f, [[testdb getDBMonth:0] inputTrendOnDay:14], @"before first trend");
	XCTAssertEqual(100.0f, [[testdb getDBMonth:0] inputTrendOnDay:15], @"first trend");
	[self assertWeight:100 andTrend:100.0000f onDay:15 inMonth:0];
	[self assertWeight:200 andTrend:110.0000f onDay:18 inMonth:0];
	[self assertWeight:100 andTrend:109.0000f onDay: 6 inMonth:3];
	[self assertWeight:200 andTrend:118.1000f onDay: 7 inMonth:3];
	[self assertWeight:100 andTrend:116.2900f onDay:29 inMonth:4];
	[self assertWeight:200 andTrend:124.6610f onDay:30 inMonth:4];
	[self assertWeight:100 andTrend:122.1949f onDay: 1 inMonth:7];
	[self assertWeight:200 andTrend:129.9754f onDay:15 inMonth:7];
	[self assertWeight:100 andTrend:126.9778f onDay:31 inMonth:7];
	[self assertWeight:200 andTrend:134.2800f onDay:15 inMonth:8];
	[self closeDatabase];
}


- (void)testDeleteInMiddle {
	[self openDatabase];
	// delete one weight and verify trends
	[self setWeight:0 onDay:30 inMonth:4];
	[self commitDatabase];
	[self assertWeight:100 andTrend:100.0000f onDay:15 inMonth:0];
	[self assertWeight:200 andTrend:110.0000f onDay:18 inMonth:0];
	[self assertWeight:100 andTrend:109.0000f onDay: 6 inMonth:3];
	[self assertWeight:200 andTrend:118.1000f onDay: 7 inMonth:3];
	[self assertWeight:100 andTrend:116.2900f onDay:29 inMonth:4];
	[self assertWeight:  0 andTrend:  0       onDay:30 inMonth:4];
	[self assertWeight:100 andTrend:114.6610f onDay: 1 inMonth:7];
	[self assertWeight:200 andTrend:123.1949f onDay:15 inMonth:7];
	[self assertWeight:100 andTrend:120.8754f onDay:31 inMonth:7];
	[self assertWeight:200 andTrend:128.7879f onDay:15 inMonth:8];
	[self closeDatabase];
}


- (void)testAppendWeight {
	[self openDatabase];
	// append one weight and verify trends
	[self setWeight:100 onDay:11 inMonth:9];
	[self commitDatabase];
	[self assertWeight:100 andTrend:100.0000f onDay:15 inMonth:0];
	[self assertWeight:200 andTrend:110.0000f onDay:18 inMonth:0];
	[self assertWeight:100 andTrend:109.0000f onDay: 6 inMonth:3];
	[self assertWeight:200 andTrend:118.1000f onDay: 7 inMonth:3];
	[self assertWeight:100 andTrend:116.2900f onDay:29 inMonth:4];
	[self assertWeight:200 andTrend:124.6610f onDay:30 inMonth:4];
	[self assertWeight:100 andTrend:122.1949f onDay: 1 inMonth:7];
	[self assertWeight:200 andTrend:129.9754f onDay:15 inMonth:7];
	[self assertWeight:100 andTrend:126.9778f onDay:31 inMonth:7];
	[self assertWeight:200 andTrend:134.2800f onDay:15 inMonth:8];
	[self assertWeight:100 andTrend:130.8520f onDay:11 inMonth:9];
	[self closeDatabase];
}


- (void)testPrependWeight {
	[self openDatabase];
	// prepend one weight and verify trends
	[self setWeight:200 onDay:8 inMonth:-2];
	[self commitDatabase];
	[self assertWeight:200 andTrend:200.0000f onDay: 8 inMonth:-2];
	[self assertWeight:100 andTrend:190.0000f onDay:15 inMonth:0];
	[self assertWeight:200 andTrend:191.0000f onDay:18 inMonth:0];
	[self assertWeight:100 andTrend:181.9000f onDay: 6 inMonth:3];
	[self assertWeight:200 andTrend:183.7099f onDay: 7 inMonth:3];
	[self assertWeight:100 andTrend:175.3389f onDay:29 inMonth:4];
	[self assertWeight:200 andTrend:177.8050f onDay:30 inMonth:4];
	[self assertWeight:100 andTrend:170.0245f onDay: 1 inMonth:7];
	[self assertWeight:200 andTrend:173.0221f onDay:15 inMonth:7];
	[self assertWeight:100 andTrend:165.7199f onDay:31 inMonth:7];
	[self assertWeight:200 andTrend:169.1479f onDay:15 inMonth:8];
	[self closeDatabase];
}


- (void)testDeleteFirst {
	[self openDatabase];
	// delete first weight and verify trends
	[self setWeight:0 onDay:15 inMonth:0];
	[self commitDatabase];
	[self assertWeight:  0 andTrend:  0       onDay:15 inMonth:0];
	[self assertWeight:200 andTrend:200.0000f onDay:18 inMonth:0];
	[self assertWeight:100 andTrend:190.0000f onDay: 6 inMonth:3];
	[self assertWeight:200 andTrend:191.0000f onDay: 7 inMonth:3];
	[self assertWeight:100 andTrend:181.9000f onDay:29 inMonth:4];
	[self assertWeight:200 andTrend:183.7099f onDay:30 inMonth:4];
	[self assertWeight:100 andTrend:175.3389f onDay: 1 inMonth:7];
	[self assertWeight:200 andTrend:177.8050f onDay:15 inMonth:7];
	[self assertWeight:100 andTrend:170.0245f onDay:31 inMonth:7];
	[self assertWeight:200 andTrend:173.0221f onDay:15 inMonth:8];
	[self closeDatabase];
}


@end
