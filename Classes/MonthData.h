//
//  MonthData.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/6/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWDate.h"

@class Database;

@interface MonthData : NSObject {
	Database *database;
	EWMonth month;
	unsigned int dirtyBits;
	float *measuredWeights;
	float *trendWeights;
	unsigned int flagBits;
	NSMutableArray *notesArray;
}

@property (nonatomic,readonly) Database *database;

+ (void)finalizeStatements;
- (id)initWithDatabase:(Database *)db month:(EWMonth)m;
- (NSDate *)dateOnDay:(EWDay)day;
- (float)measuredWeightOnDay:(EWDay)day;
- (float)inputTrendOnDay:(EWDay)day;
- (float)trendWeightOnDay:(EWDay)day;
- (BOOL)isFlaggedOnDay:(EWDay)day;
- (NSString *)noteOnDay:(EWDay)day;
- (void)setMeasuredWeight:(float)weight 
					 flag:(BOOL)flag
					 note:(NSString *)note
					onDay:(EWDay)day;
- (void)commitChanges;

@end
