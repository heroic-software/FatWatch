//
//  MonthData.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/6/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWDate.h"

@interface MonthData : NSObject {
	EWMonth month;
	unsigned int dirtyBits;
	float *measuredWeights;
	float *trendWeights;
	unsigned int flagBits;
	NSMutableArray *notesArray;
}

+ (void)finalizeStatements;
- (id)initWithMonth:(EWMonth)m;
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
- (BOOL)commitChanges;

@end
