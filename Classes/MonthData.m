//
//  WeightMonth.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/6/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "MonthData.h"

@implementation MonthData

- (id)init {
	if ([super init]) {
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

- (void)loadMeasuredWeight:(float)measured trendWeight:(float)trend flagged:(BOOL)flag note:(NSString *)note forDay:(unsigned)day
{
	int i = day - 1;
	measuredWeights[i] = measured;
	trendWeights[i] = trend;
	flags[i] = flag;
	id object = (note != nil) ? (id)note : (id)[NSNull null];
	[notesArray replaceObjectAtIndex:i withObject:object];
}

- (NSString *)titleOnDay:(unsigned)day
{
	return [NSString stringWithFormat:@"The %dth", day];
}

- (float)measuredWeightOnDay:(unsigned)day
{
	return measuredWeights[day - 1];
}

- (float)trendWeightOnDay:(unsigned)day
{
	return trendWeights[day - 1];
}

- (BOOL)isFlaggedOnDay:(unsigned)day
{
	return flags[day - 1];
}

- (NSString *)noteOnDay:(unsigned)day
{
	id note = [notesArray objectAtIndex:(day - 1)];
	return (note == [NSNull null] ? nil : note);
}

- (void)setMeasuredWeight:(float)weight 
					 flag:(BOOL)flag
					 note:(NSString *)note
					onDay:(unsigned)day
{
	int i = day - 1;
	measuredWeights[i] = weight;
	flags[i] = flag;
	id object = (note != nil) ? (id)note : (id)[NSNull null];
	[notesArray replaceObjectAtIndex:i withObject:object];
}

@end
