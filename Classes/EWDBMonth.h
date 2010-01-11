//
//  EWDBMonth.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/9/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWDate.h"


@class EWDatabase;


typedef unsigned char EWFlagValue;

typedef struct EWDBDay {
	float scaleWeight;
	float scaleFat; // scaleFat is set => scaleWeight is set
	float trendWeight;
	float trendFat;
	NSString *note;
	EWFlagValue flags[4];
} EWDBDay;


@interface EWDBMonth : NSObject {
	EWDatabase *database;
	EWMonth month;
	struct EWDBDay days[31];
	UInt32 dirtyBits;
}
@property (nonatomic,readonly) EWDatabase *database;
@property (nonatomic,readonly) EWMonth month;
@property (nonatomic,readonly) EWDBMonth *previous;
@property (nonatomic,readonly) EWDBMonth *next;
- (id)initWithMonth:(EWMonth)m database:(EWDatabase *)ewdb;
- (NSDate *)dateOnDay:(EWDay)day;
- (const EWDBDay *)getDBDayOnDay:(EWDay)day;
- (EWDay)firstDayWithWeight;
- (EWDay)lastDayWithWeight;
- (float)inputTrendOnDay:(EWDay)day;
- (float)latestFatBeforeDay:(EWDay)day;
- (BOOL)didRecordFatBeforeDay:(EWDay)day;
- (void)updateTrends;
- (void)setDBDay:(EWDBDay *)dbd onDay:(EWDay)day;
- (BOOL)hasDataOnDay:(EWDay)day;
- (BOOL)commitChanges;
@end
