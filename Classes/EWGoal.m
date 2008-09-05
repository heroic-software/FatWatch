//
//  EWGoal.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 8/19/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "EWGoal.h"
#import "Database.h"
#import "MonthData.h"
#import "WeightFormatters.h"


static NSString *kGoalStartDateKey = @"GoalStartDate";
static NSString *kGoalWeightKey = @"GoalWeight";
static NSString *kGoalWeightChangePerDayKey = @"GoalWeightChangePerDay";


@implementation EWGoal


+ (void)deleteGoal {
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs removeObjectForKey:kGoalStartDateKey];
	[defs removeObjectForKey:kGoalWeightKey];
	[defs removeObjectForKey:kGoalWeightChangePerDayKey];
}


+ (EWGoal *)sharedGoal {
	static EWGoal *goal = nil;
	
	if (goal == nil) {
		goal = [[EWGoal alloc] init];
	}
	
	return goal;
}


- (BOOL)isDefined {
	return [[NSUserDefaults standardUserDefaults] objectForKey:kGoalWeightKey] != nil;
}


- (NSDate *)startDate {
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSNumber *number = [defs objectForKey:kGoalStartDateKey];
	if (number) {
		return [NSDate dateWithTimeIntervalSinceReferenceDate:[number doubleValue]];
	} else {
		NSDate *date = [NSDate date];
		self.startDate = date;
		return date;
	}
}


- (void)setStartDate:(NSDate *)date {
	[self willChangeValueForKey:@"startDate"];
	[self willChangeValueForKey:@"startWeight"];
	[self willChangeValueForKey:@"endDate"];
	[[NSUserDefaults standardUserDefaults] setDouble:[date timeIntervalSinceReferenceDate] forKey:kGoalStartDateKey];
	[self didChangeValueForKey:@"startDate"];
	[self didChangeValueForKey:@"startWeight"];
	[self didChangeValueForKey:@"endDate"];
}


- (EWMonthDay)startMonthDay {
	return EWMonthDayFromDate(self.startDate);
}


- (float)endWeight {
	return [[NSUserDefaults standardUserDefaults] floatForKey:kGoalWeightKey];
}


- (void)setEndWeight:(float)weight {
	[self willChangeValueForKey:@"endWeight"];
	[self willChangeValueForKey:@"endWeightNumber"];
	[self willChangeValueForKey:@"endDate"];
	[[NSUserDefaults standardUserDefaults] setFloat:weight forKey:kGoalWeightKey];
	// make sure sign matches
	float weightChange = weight - self.startWeight;
	float delta = self.weightChangePerDay;
	if ((weightChange > 0 && delta < 0) || (weightChange < 0 && delta > 0)) {
		self.weightChangePerDay = -delta;
	}
	[self didChangeValueForKey:@"endWeight"];
	[self didChangeValueForKey:@"endWeightNumber"];
	[self didChangeValueForKey:@"endDate"];
}


- (NSNumber *)endWeightNumber {
	float w = self.endWeight;
	if (w > 0) {
		return [NSNumber numberWithFloat:w];
	} else {
		return nil;
	}
}


- (void)setEndWeightNumber:(NSNumber *)number {
	self.endWeight = [number floatValue];
}


- (float)weightChangePerDay {
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSNumber *number = [defs objectForKey:kGoalWeightChangePerDayKey];
	if (number) {
		return [number floatValue];
	} else {
		float delta = [WeightFormatters defaultWeightChange];
		self.weightChangePerDay = delta;
		return delta;
	}
}


- (void)setWeightChangePerDay:(float)delta {
	[self willChangeValueForKey:@"weightChangePerDay"];
	[self willChangeValueForKey:@"endDate"];
	// make sure sign matches
	float weightChange = self.endWeight - self.startWeight;
	if ((weightChange > 0 && delta < 0) || (weightChange < 0 && delta > 0)) {
		delta = -delta;
	}
	[[NSUserDefaults standardUserDefaults] setFloat:delta forKey:kGoalWeightChangePerDayKey];
	[self didChangeValueForKey:@"weightChangePerDay"];
	[self didChangeValueForKey:@"endDate"];
}


- (float)weightOnDate:(NSDate *)date {
	EWMonthDay startMonthDay = EWMonthDayFromDate(date);
	MonthData *md = [[Database sharedDatabase] dataForMonth:EWMonthDayGetMonth(startMonthDay)];
	float w = [md trendWeightOnDay:EWMonthDayGetDay(startMonthDay)];
	if (w == 0) {
		w = [md inputTrendOnDay:EWMonthDayGetDay(startMonthDay)];
	}
	return w;
}


- (float)startWeight {
	return [self weightOnDate:self.startDate];
}


- (NSDate *)endDateFromStartDate:(NSDate *)date atWeightChangePerDay:(float)weightChangePerDay {
	float totalWeightChange = (self.endWeight - [self weightOnDate:date]);
	NSTimeInterval seconds = totalWeightChange / weightChangePerDay * 86400;
	return [date addTimeInterval:seconds];
}


- (NSDate *)endDate {
	return [self endDateFromStartDate:self.startDate atWeightChangePerDay:self.weightChangePerDay];
}


- (void)setEndDate:(NSDate *)date {
	float weightChange = self.endWeight - self.startWeight;
	NSTimeInterval timeChange = [date timeIntervalSinceDate:self.startDate];
	self.weightChangePerDay = (weightChange / (timeChange / 86400));
}


@end
