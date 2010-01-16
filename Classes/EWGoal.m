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
static NSString * const kGoalWeightChangePerDayKey = @"GoalWeightChangePerDay";


@implementation EWGoal


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


+ (EWGoal *)sharedGoal {
	static EWGoal *goal = nil;
	
	if (goal == nil) {
		[self fixHeightIfNeeded];
		goal = [[EWGoal alloc] init];
	}
	
	return goal;
}


+ (void)deleteGoal {
	NSUserDefaults *uds = [NSUserDefaults standardUserDefaults];
	[uds removeObjectForKey:kGoalWeightKey];
	[uds removeObjectForKey:kGoalWeightChangePerDayKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:EWGoalDidChangeNotification object:self];
}


+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	// endWeight is independent
	// weightChangePerDay is independent
	
	// endDate depends on endWeight and weightChangePerDay
	if ([key isEqualToString:@"endDate"]) {
		NSSet *morePaths = [NSSet setWithObjects:
							@"weightChangePerDay", 
							@"endWeight",
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


- (float)currentWeight {
	float w = [[EWDatabase sharedDatabase] latestWeight];
	if (w > 0) return w;

	// this means the database is empty, so we'll just return the goal weight
	return self.endWeight;
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
		b = fabsf([self currentWeight] - self.endWeight) < 2.5f;
	}
	return b;
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
		[[NSUserDefaults standardUserDefaults] setFloat:weight forKey:kGoalWeightKey];
		// make sure sign matches
		float weightChange = weight - [self currentWeight];
		float delta = self.weightChangePerDay;
		if ((weightChange > 0 && delta < 0) || (weightChange < 0 && delta > 0)) {
			self.weightChangePerDay = -delta;
		}
		[self didChangeValueForKey:@"endWeight"];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:EWGoalDidChangeNotification object:self];
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
			delta = [[NSUserDefaults standardUserDefaults] defaultWeightChange];
			self.weightChangePerDay = delta;
		}
	}
	return delta;
}


- (void)setWeightChangePerDay:(float)delta {
	@synchronized (self) {
		[self willChangeValueForKey:@"weightChangePerDay"];
		// make sure sign matches
		float weightChange = self.endWeight - [self currentWeight];
		if ((weightChange > 0 && delta < 0) || (weightChange < 0 && delta > 0)) {
			delta = -delta;
		}
		[[NSUserDefaults standardUserDefaults] setFloat:delta forKey:kGoalWeightChangePerDayKey];
		[self didChangeValueForKey:@"weightChangePerDay"];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:EWGoalDidChangeNotification object:self];
}


- (NSDate *)endDateWithWeightChangePerDay:(float)weightChangePerDay {
	NSTimeInterval seconds;
	
	@synchronized (self) {
		float totalWeightChange = (self.endWeight - [self currentWeight]);
		seconds = totalWeightChange / weightChangePerDay * kSecondsPerDay;
	}
	return [NSDate dateWithTimeIntervalSinceNow:seconds];
}


- (NSDate *)endDate {
	NSDate *d;

	@synchronized (self) {
		d = [self endDateWithWeightChangePerDay:self.weightChangePerDay];
	}
	return d;
}


- (void)setEndDate:(NSDate *)date {
	@synchronized (self) {
		float weightChange = self.endWeight - [self currentWeight];
		NSTimeInterval timeChange = [date timeIntervalSinceNow];
		self.weightChangePerDay = (weightChange / (timeChange / kSecondsPerDay));
	}
}


@end
