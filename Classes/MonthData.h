//
//  MonthData.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/6/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonthData : NSObject {
	BOOL hydrated;
	BOOL dirty;
	unsigned int firstDay;
	float *measuredWeights;
	float *trendWeights;
	BOOL *flags;
	NSMutableArray *notesArray;
}
- (void)loadMeasuredWeight:(float)measured trendWeight:(float)trend flagged:(BOOL)flag note:(NSString *)note forDay:(unsigned)day;
- (NSString *)titleOnDay:(unsigned)day;
- (float)measuredWeightOnDay:(unsigned)day;
- (float)trendWeightOnDay:(unsigned)day;
- (BOOL)isFlaggedOnDay:(unsigned)day;
- (NSString *)noteOnDay:(unsigned)day;
- (void)setMeasuredWeight:(float)weight 
					 flag:(BOOL)flag
					 note:(NSString *)note
					onDay:(unsigned)day;
@end
