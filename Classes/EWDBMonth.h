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
	float scaleFatWeight; // scaleFatWeight is set ONLY IF scaleWeight is set
	float trendWeight;
	float trendFatWeight;
	CFStringRef note;
	EWFlagValue flags[4];
} EWDBDay;


EW_INLINE BOOL EWDBDayIsEmpty(const EWDBDay *d) {
	return !(d->scaleWeight > 0 || 
			 d->flags[0] != 0 ||
			 d->flags[1] != 0 ||
			 d->flags[2] != 0 ||
			 d->flags[3] != 0 ||
			 d->note != NULL);
}


@interface EWDBMonth : NSObject
@property (nonatomic,readonly) EWDatabase *database;
@property (nonatomic,readonly) EWMonth month;
@property (nonatomic,readonly,getter = isValid) BOOL valid;
- (id)initWithMonth:(EWMonth)m database:(EWDatabase *)ewdb;
- (const EWDBDay *)getDBDayOnDay:(EWDay)day;
- (float)inputTrendOnDay:(EWDay)day;
- (float)inputFatTrendOnDay:(EWDay)day;
- (BOOL)didRecordFatBeforeDay:(EWDay)day;
- (void)updateTrends;
- (void)setDBDay:(EWDBDay *)dbd onDay:(EWDay)day;
- (BOOL)hasDataOnDay:(EWDay)day;
- (BOOL)commitChanges;
- (void)invalidate;
@end
