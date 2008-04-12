//
//  WeightMonth.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/6/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "MonthData.h"

@implementation MonthData

- (id)initWithMonth:(EWMonth)m {
	if ([super init]) {
		month = m;
		measuredWeights = calloc(31, sizeof(float));
		trendWeights = calloc(31, sizeof(float));
		flags = calloc(31, sizeof(BOOL));
		notesArray = [[NSMutableArray alloc] initWithCapacity:31];
		for (int i = 0; i < 31; i++) {
			[notesArray addObject:[NSNull null]];
		}
	}
	return self;
}

- (void)dealloc {
	free(measuredWeights);
	free(trendWeights);
	free(flags);
	[notesArray release];
	[super dealloc];
}

- (void)loadMeasuredWeight:(float)measured trendWeight:(float)trend flagged:(BOOL)flag note:(NSString *)note forDay:(EWMonth)day
{
	int i = day - 1;
	measuredWeights[i] = measured;
	trendWeights[i] = trend;
	flags[i] = flag;
	id object = (note != nil) ? (id)note : (id)[NSNull null];
	[notesArray replaceObjectAtIndex:i withObject:object];
}

- (NSDate *)dateOnDay:(EWDay)day
{
	return NSDateFromEWMonthAndDay(month, day);
}

- (float)measuredWeightOnDay:(EWDay)day
{
	return measuredWeights[day - 1];
}

- (float)trendWeightOnDay:(EWDay)day
{
	return trendWeights[day - 1];
}

- (BOOL)isFlaggedOnDay:(EWDay)day
{
	return flags[day - 1];
}

- (NSString *)noteOnDay:(EWDay)day
{
	id note = [notesArray objectAtIndex:(day - 1)];
	return (note == [NSNull null] ? nil : note);
}

- (void)setMeasuredWeight:(float)weight 
					 flag:(BOOL)flag
					 note:(NSString *)note
					onDay:(EWDay)day
{
	int i = day - 1;
	measuredWeights[i] = weight;
	flags[i] = flag;
	id object = (note != nil) ? (id)note : (id)[NSNull null];
	[notesArray replaceObjectAtIndex:i withObject:object];
}

@end
