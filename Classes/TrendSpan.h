/*
 * TrendSpan.h
 * Created by Benjamin Ragheb on 9/9/08.
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
#import "GraphDrawingOperation.h"


@class EWDatabase;


@interface TrendSpan : NSObject
+ (NSArray *)computeTrendSpansFromDatabase:(EWDatabase *)db;
@property (nonatomic,strong) NSString *title;
@property (nonatomic) EWMonthDay beginMonthDay;
@property (nonatomic) EWMonthDay endMonthDay;
@property (nonatomic,readonly) NSInteger length;
@property (nonatomic,readonly) float *flagFrequencies;

@property (nonatomic) float totalWeightPerDay;
@property (nonatomic,strong) NSDate *totalEndDate;
@property (nonatomic,readonly) GraphViewParameters *totalGraphParameters;
@property (nonatomic,strong) NSOperation *totalGraphOperation;
@property (nonatomic) CGImageRef totalGraphImageRef;

@property (nonatomic) float fatWeightPerDay;
@property (nonatomic,strong) NSDate *fatEndDate;
@property (nonatomic,readonly) GraphViewParameters *fatGraphParameters;
@property (nonatomic,strong) NSOperation *fatGraphOperation;
@property (nonatomic) CGImageRef fatGraphImageRef;
@end
