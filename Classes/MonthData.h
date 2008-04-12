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
	BOOL hydrated;
	BOOL dirty;
	unsigned int firstDay;
	float *measuredWeights;
	float *trendWeights;
	BOOL *flags;
	NSMutableArray *notesArray;
}
- (id)initWithMonth:(EWMonth)m;
- (void)loadMeasuredWeight:(float)measured trendWeight:(float)trend flagged:(BOOL)flag note:(NSString *)note forDay:(EWDay)day;
- (NSDate *)dateOnDay:(EWDay)day;
- (float)measuredWeightOnDay:(EWDay)day;
- (float)trendWeightOnDay:(EWDay)day;
- (BOOL)isFlaggedOnDay:(EWDay)day;
- (NSString *)noteOnDay:(EWDay)day;
- (void)setMeasuredWeight:(float)weight 
					 flag:(BOOL)flag
					 note:(NSString *)note
					onDay:(EWDay)day;
@end
