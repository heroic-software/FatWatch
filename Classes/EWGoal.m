//
//  EWGoal.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 8/19/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "EWDBMonth.h"
#import "EWDatabase.h"
#import "EWGoal.h"
#import "EWWeightFormatter.h"
#import "NSUserDefaults+EWAdditions.h"


static const NSTimeInterval kSecondsPerDay = 60 * 60 * 24;


NSString * const EWGoalDidChangeNotification = @"EWGoalDidChange";


static NSString * const kGoalWeightKey = @"GoalWeight";
static NSString * const kGoalDateKey = @"GoalDate"; // stored as MonthDay


@implementation EWGoal


#pragma mark Class Methods


+ (void)fixHeightIfNeeded {
	static NSString *kHeightFixAppliedKey = @"EWFixedBug0000017";
	NSUserDefaults *uds = [NSUserDefaults standardUserDefaults];
	
	if ([uds boolForKey:kHeightFixAppliedKey]) return;
	
	// To fix a stupid bug where all height values were offset by 1 cm,
	// causing weird results when measuring in inches.
	if ([uds heightIncrement] > 0.01f) {
		float height = [uds height];
		float error = fmodf(height, 0.0254f);
		if (fabsf(error - 0.01f) < 0.0001f) {
			[uds setHeight:(height - 0.01f)];
			NSLog(@"Bug 0000017: Height adjusted from %f to %f", height, [uds height]);
		}
	}

	[uds setBool:YES forKey:kHeightFixAppliedKey];
}


+ (void)upgradeDefaultsIfNeeded {
	static NSString * const kOldGoalStartDateKey = @"GoalStartDate";
	static NSString * const kOldGoalWeightChangePerDayKey = @"GoalWeightChangePerDay";
	
	NSUserDefaults *uds = [NSUserDefaults standardUserDefaults];
	
	NSNumber *startDateNumber = [uds objectForKey:kOldGoalStartDateKey];
	if (startDateNumber == nil) return;
	
	NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[startDateNumber doubleValue]];
	float changePerDay = [uds floatForKey:kOldGoalWeightChangePerDayKey];

	EWMonthDay md = EWMonthDayFromDate(startDate);
	EWDatabase *db = [EWDatabase sharedDatabase];
	float startWeight = [db trendWeightOnMonthDay:md];
	if (startWeight == 0) {
		EWDBMonth *dbm = [db getDBMonth:EWMonthDayGetMonth(md)];
		startWeight = [dbm inputTrendOnDay:EWMonthDayGetDay(md)];
	}
	
	if (startWeight > 0) {
		float goalWeight = [uds floatForKey:kGoalWeightKey];
		NSTimeInterval seconds = (goalWeight - startWeight) / changePerDay * kSecondsPerDay;
		NSDate *goalDate = [startDate addTimeInterval:seconds];
		[uds setInteger:EWMonthDayFromDate(goalDate) forKey:kGoalDateKey];
	}
	
	[uds removeObjectForKey:kOldGoalStartDateKey];
	[uds removeObjectForKey:kOldGoalWeightChangePerDayKey];
}


+ (EWGoal *)sharedGoal {
	static EWGoal *goal = nil;
	
	if (goal == nil) {
		[self fixHeightIfNeeded];
		[self upgradeDefaultsIfNeeded];
		goal = [[EWGoal alloc] init];
	}
	
	return goal;
}


+ (void)deleteGoal {
	NSUserDefaults *uds = [NSUserDefaults standardUserDefaults];
	[uds removeObjectForKey:kGoalWeightKey];
	[uds removeObjectForKey:kGoalDateKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:EWGoalDidChangeNotification object:self];
}


+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	// endWeight is independent
	// endDate is independent

	// weightChangePerDay depends on endWeight and endDate
	if ([key isEqualToString:@"weightChangePerDay"]) {
		NSSet *morePaths = [NSSet setWithObjects:
							@"endWeight", 
							@"endDate",
							nil];
		keyPaths = [keyPaths setByAddingObjectsFromSet:morePaths];
	}
	else if ([key isEqualToString:@"endWeightNumber"]) {
		keyPaths = [keyPaths setByAddingObject:@"endWeight"];
	}
	else if ([key isEqualToString:@"endWeight"]) {
		keyPaths = [keyPaths setByAddingObject:@"endWeightNumber"];
	}
	
	return keyPaths;
}


#pragma mark Helper Methods


- (float)currentWeight {
	float w = [[EWDatabase sharedDatabase] latestWeight];
	if (w > 0) return w;

	// this means the database is empty, so we'll just return the goal weight
	return self.endWeight;
}


- (NSDate *)endDateWithWeightChangePerDay:(float)weightChangePerDay {
	NSTimeInterval seconds;
	
	@synchronized (self) {
		float totalWeightChange = (self.endWeight - [self currentWeight]);
		seconds = totalWeightChange / weightChangePerDay * kSecondsPerDay;
	}
	return [NSDate dateWithTimeIntervalSinceNow:seconds];
}


#pragma mark Properties


- (BOOL)isDefined {
	NSUserDefaults *uds = [NSUserDefaults standardUserDefaults];
	@synchronized (self) {
		return [uds objectForKey:kGoalWeightKey] != nil;
	}
	return NO;
}


#pragma mark -


- (BOOL)isAttained {
	@synchronized (self) {
		return fabsf([self currentWeight] - self.endWeight) < 1.4f;
	}
	return NO;
}


#pragma mark -


- (float)endWeight {
	NSUserDefaults *uds = [NSUserDefaults standardUserDefaults];
	@synchronized (self) {
		return [uds floatForKey:kGoalWeightKey];
	}
	return 0;
}


- (void)setEndWeight:(float)weight {
	NSUserDefaults *uds = [NSUserDefaults standardUserDefaults];
	@synchronized (self) {
		[self willChangeValueForKey:@"endWeight"];
		[uds setFloat:weight forKey:kGoalWeightKey];
		[self didChangeValueForKey:@"endWeight"];
		NSDate *date = self.endDate;
		if (date == nil) {
			date = EWDateFromMonthDay(EWMonthDayToday());
			date = [date addTimeInterval:90 * kSecondsPerDay];
			self.endDate = date;
		}
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:EWGoalDidChangeNotification object:self];
}


#pragma mark -


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


#pragma mark -


- (NSDate *)endDate {
	NSUserDefaults *uds = [NSUserDefaults standardUserDefaults];
	EWMonthDay md;
	@synchronized (self) {
		md = [uds integerForKey:kGoalDateKey];
	}
	return EWDateFromMonthDay(md);
}


- (void)setEndDate:(NSDate *)date {
	NSUserDefaults *uds = [NSUserDefaults standardUserDefaults];
	EWMonthDay md = EWMonthDayFromDate(date);
	@synchronized (self) {
		[self willChangeValueForKey:@"endDate"];
		[uds setInteger:md forKey:kGoalDateKey];
		[self didChangeValueForKey:@"endDate"];
	}
}


#pragma mark -


- (float)weightChangePerDay {
	float delta;
	
	@synchronized (self) {
		NSDate *todayDate = EWDateFromMonthDay(EWMonthDayToday());
		NSTimeInterval seconds = [self.endDate timeIntervalSinceDate:todayDate];
		float weightChange = self.endWeight - [self currentWeight];
		return weightChange / (seconds / kSecondsPerDay);
	}
	return delta;
}


- (void)setWeightChangePerDay:(float)delta {
	@synchronized (self) {
		float weightChange = self.endWeight - [self currentWeight];
		NSTimeInterval seconds = (weightChange / delta) * kSecondsPerDay;
		NSDate *todayDate = EWDateFromMonthDay(EWMonthDayToday());
		self.endDate = [todayDate addTimeInterval:seconds];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:EWGoalDidChangeNotification object:self];
}


@end
