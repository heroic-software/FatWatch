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


typedef UInt8 EWFlagValue;
typedef UInt32 EWFlags;
typedef struct EWDBDay {
	float scaleWeight;
	float scaleFat; // scaleFat is set => scaleWeight is set
	float trendWeight;
	float trendFat;
	NSString *note;
	EWFlags flags;
} EWDBDay;


static inline EWFlagValue EWFlagGet(EWFlags flags, int i) {
	return 0xFF & (flags >> (8*i));
}


static inline void EWFlagSet(EWFlags *flags, int i, EWFlagValue v) { 
	*flags = (*flags & ~(0xFF << (8*i))) | (v << (8*i));
}


@interface EWDBMonth : NSObject {
	EWDatabase *database;
	EWMonth month;
	struct EWDBDay days[31];
	UInt32 dirtyBits;
}
@property (nonatomic,readonly) EWMonth month;
@property (nonatomic,readonly) EWDBMonth *previous;
@property (nonatomic,readonly) EWDBMonth *next;
- (id)initWithMonth:(EWMonth)m database:(EWDatabase *)ewdb;
- (NSDate *)dateOnDay:(EWDay)day;
- (struct EWDBDay *)getDBDay:(EWDay)day;
- (EWDay)firstDayWithWeight;
- (EWDay)lastDayWithWeight;
- (float)inputTrendOnDay:(EWDay)day;
- (void)updateTrends;
- (void)setScaleWeight:(float)weight scaleFat:(float)fat flags:(EWFlags)flags note:(NSString *)note onDay:(EWDay)day;
- (BOOL)hasDataOnDay:(EWDay)day;
- (BOOL)commitChanges;
@end
