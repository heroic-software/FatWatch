/*
 * EWGoal.h
 * Created by Benjamin Ragheb on 8/19/08.
 * Copyright 2015 Heroic Software Inc
 *
 * This file is part of FatWatch.
 *
 * FatWatch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FatWatch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <UIKit/UIKit.h>
#import "EWDate.h"


extern NSString * const EWGoalDidChangeNotification;
extern float gGoalBandHeight;
extern float gGoalBandHalfHeight;


typedef enum {
	EWGoalStateUndefined,
	EWGoalStateFixedDate,
	EWGoalStateFixedRate,
	EWGoalStateInvalid = -1
} EWGoalState;


@class EWDatabase;


@interface EWGoal : NSObject

+ (void)deleteGoal;

@property (readonly) EWGoalState state;
@property (readonly,getter=isDefined) BOOL defined;

@property (readonly) float currentWeight;

@property float endWeight;
@property (strong) NSNumber *endWeightNumber;

@property (strong) NSDate *endDate;
@property float weightChangePerDay;

- (id)initWithDatabase:(EWDatabase *)db;
- (NSDate *)endDateWithWeightChangePerDay:(float)weightChangePerDay;

@end
