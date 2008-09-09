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
	BOOL b;
	
	@synchronized (self) {
		b = [[NSUserDefaults standardUserDefaults] objectForKey:kGoalWeightKey] != nil;
	}
	return b;
}


- (BOOL)isAttained {
	BOOL b;
	
	@synchronized (self) {
		float s = self.startWeight;
		float e = self.endWeight;
		float w = [self weightOnDate:[NSDate date]];
		b = (s > e && e > w) || (s < e && e < w);
	}
	return b;
}


- (NSDate *)startDate {
	NSDate *d;
	
	@synchronized (self) {
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		NSNumber *number = [defs objectForKey:kGoalStartDateKey];
		if (number) {
			d = [NSDate dateWithTimeIntervalSinceReferenceDate:[number doubleValue]];
		} else {
			NSDate *date = [NSDate date];
			self.startDate = date;
			d = date;
		}
	}
	return d;
}


- (void)setStartDate:(NSDate *)date {
	@synchronized (self) {
		[self willChangeValueForKey:@"startDate"];
		[self willChangeValueForKey:@"startWeight"];
		[self willChangeValueForKey:@"endDate"];
		[[NSUserDefaults standardUserDefaults] setDouble:[date timeIntervalSinceReferenceDate] forKey:kGoalStartDateKey];
		[self didChangeValueForKey:@"startDate"];
		[self didChangeValueForKey:@"startWeight"];
		[self didChangeValueForKey:@"endDate"];
	}
}


- (EWMonthDay)startMonthDay {
	return EWMonthDayFromDate(self.startDate);
}


- (float)endWeight {
	float w;
	
	@synchronized (self) {
		w = [[NSUserDefaults standardUserDefaults] floatForKey:kGoalWeightKey];
	}
	return w;
}


- (void)setEndWeight:(float)weight {
	@synchronized (self) {
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
	float delta;
	
	@synchronized (self) {
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		NSNumber *number = [defs objectForKey:kGoalWeightChangePerDayKey];
		if (number) {
			delta = [number floatValue];
		} else {
			delta = [WeightFormatters defaultWeightChange];
			self.weightChangePerDay = delta;
		}
	}
	return delta;
}


- (void)setWeightChangePerDay:(float)delta {
	@synchronized (self) {
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
	float w;
	
	@synchronized (self) {
		w = [self weightOnDate:self.startDate];
	}
	return w;
}


- (NSDate *)endDateFromStartDate:(NSDate *)date atWeightChangePerDay:(float)weightChangePerDay {
	NSTimeInterval seconds;
	
	@synchronized (self) {
		float totalWeightChange = (self.endWeight - [self weightOnDate:date]);
		seconds = totalWeightChange / weightChangePerDay * SecondsPerDay;
	}
	return [date addTimeInterval:seconds];
}


- (NSDate *)endDate {
	NSDate *d;

	@synchronized (self) {
		d = [self endDateFromStartDate:self.startDate 
				  atWeightChangePerDay:self.weightChangePerDay];
	}
	return d;
}


- (void)setEndDate:(NSDate *)date {
	@synchronized (self) {
		float weightChange = self.endWeight - self.startWeight;
		NSTimeInterval timeChange = [date timeIntervalSinceDate:self.startDate];
		self.weightChangePerDay = (weightChange / (timeChange / SecondsPerDay));
	}
}


@end
