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


static NSString *kGoalStartDateKey = @"GoalStartDate";
static NSString *kGoalWeightKey = @"GoalWeight";
static NSString *kGoalWeightChangePerDayKey = @"GoalWeightChangePerDay";


static EWGoal *sharedInstance = nil;


@implementation EWGoal


+ (void)deleteGoal {
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs removeObjectForKey:kGoalStartDateKey];
	[defs removeObjectForKey:kGoalWeightKey];
	[defs removeObjectForKey:kGoalWeightChangePerDayKey];
	[sharedInstance release];
	sharedInstance = nil;
}


+ (EWGoal *)sharedGoal {
	static EWGoal *goal = nil;
	
	if (goal == nil) {
		goal = [[EWGoal alloc] init];
	}
	
	return goal;
}


- (BOOL)isDefined {
	return [[NSUserDefaults standardUserDefaults] objectForKey:kGoalStartDateKey] != nil;
}


- (NSDate *)startDate {
	return [NSDate dateWithTimeIntervalSinceReferenceDate:[[NSUserDefaults standardUserDefaults] doubleForKey:kGoalStartDateKey]];
}


- (void)setStartDate:(NSDate *)date {
	[[NSUserDefaults standardUserDefaults] setDouble:[date timeIntervalSinceReferenceDate] forKey:kGoalStartDateKey];
}


- (float)endWeight {
	return [[NSUserDefaults standardUserDefaults] floatForKey:kGoalWeightKey];
}


- (void)setEndWeight:(float)weight {
	[[NSUserDefaults standardUserDefaults] setFloat:weight forKey:kGoalWeightKey];
}


- (float)weightChangePerDay {
	return [[NSUserDefaults standardUserDefaults] floatForKey:kGoalWeightChangePerDayKey];
}


- (void)setWeightChangePerDay:(float)delta {
	[[NSUserDefaults standardUserDefaults] setFloat:delta forKey:kGoalWeightChangePerDayKey];
}


- (EWMonthDay)startMonthDay {
	return EWMonthDayFromDate(self.startDate);
}


- (float)startWeight {
	EWMonthDay startMonthDay = self.startMonthDay;
	MonthData *md = [[Database sharedDatabase] dataForMonth:EWMonthDayGetMonth(startMonthDay)];
	float w = [md trendWeightOnDay:EWMonthDayGetDay(startMonthDay)];
	if (w == 0) {
		w = [md inputTrendOnDay:EWMonthDayGetDay(startMonthDay)];
	}
	return w;
}


- (NSDate *)endDate {
	float weightChange = (self.endWeight - self.startWeight);
		
	NSTimeInterval seconds = weightChange / self.weightChangePerDay * 86400;
	return [self.startDate addTimeInterval:seconds];
}


@end
