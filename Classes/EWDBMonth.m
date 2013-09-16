//
//  EWDBMonth.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/9/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "EWDBMonth.h"
#import "EWDatabase.h"
#import "SQLiteStatement.h"


enum {
	kMonthDayColumn = 0,
	kScaleWeightColumn,
	kScaleFatColumn,
	kFlag0Column,
	kFlag1Column,
	kFlag2Column,
	kFlag3Column,
	kNoteColumn
};


#define EWSetBit(bf, i) { bf |= (1 << (i)); }


BOOL EWDBUpdateTrendValue(float value, float *trendValue, float *trendCarry) {
	if (value <= 0) return NO;
	if (*trendCarry == 0) {
		*trendValue = value;
	} else {
//		*trendValue = (*value * 0.1f) + (*trendCarry * 0.9f);
		*trendValue = *trendCarry + (0.1f * (value - *trendCarry));
	}
	*trendCarry = *trendValue;
	return YES;
}


@interface EWDBMonth ()
- (void)updateTrendsSaveOutput:(BOOL)saveOutput;
- (EWDBDay *)accessDBDayOnDay:(EWDay)day;
@end


@implementation EWDBMonth


@synthesize database;
@synthesize month;
@synthesize valid;


- (id)initWithMonth:(EWMonth)m database:(EWDatabase *)ewdb {
	if ((self = [self init])) {
		database = [ewdb retain];
		month = m;
        valid = YES;
		
		SQLiteStatement *stmt;

		stmt = [database selectDaysStatement];
		[stmt bindInt:EWMonthDayMake(m, 0) toParameter:1];
		[stmt bindInt:EWMonthDayMake(m+1, 0) toParameter:2];
		while ([stmt step]) {
			EWDay day = EWMonthDayGetDay([stmt intValueOfColumn:kMonthDayColumn]);
			EWDBDay *d = [self accessDBDayOnDay:day];
			d->scaleWeight = [stmt floatValueOfColumn:kScaleWeightColumn];
			d->scaleFatWeight = [stmt floatValueOfColumn:kScaleFatColumn];
			d->flags[0] = [stmt intValueOfColumn:kFlag0Column];
			d->flags[1] = [stmt intValueOfColumn:kFlag1Column];
			d->flags[2] = [stmt intValueOfColumn:kFlag2Column];
			d->flags[3] = [stmt intValueOfColumn:kFlag3Column];
			d->note = (CFStringRef)[[stmt stringValueOfColumn:kNoteColumn] copy];
		}

		[self updateTrendsSaveOutput:NO];
    }
	return self;
}


// Used all over the place.
- (const EWDBDay *)getDBDayOnDay:(EWDay)day {
    NSAssert(valid, @"Using an invalid EWDBMonth object!");
	NSAssert1(day >= 1 && day <= 31, @"Day out of range: %d", day);
	return &days[day - 1];
}


// Used all over the place.
- (BOOL)hasDataOnDay:(EWDay)day {
	EWDBDay *d = [self accessDBDayOnDay:day];
	return !EWDBDayIsEmpty(d);
}


/* Finds the trend value for the first day with data preceding the given day. */
// Used by EWGoal during upgrade.
// Used by LogEntryViewController to choose a default weight.
// Used by EWDatabase to determine trend value on a day.
- (float)inputTrendOnDay:(EWDay)day {
    NSAssert(valid, @"Using an invalid EWDBMonth object!");
	// First, search backwards through this month for a trend value.
	for (int i = (day - 1) - 1; i >= 0; i--) {
		float trend = days[i].trendWeight;
		if (trend > 0) return trend;
	}
	// If none is found, use the input trend.
	SQLiteStatement *stmt = [database selectMonthStatement];
	[stmt bindInt:month toParameter:1];
	if ([stmt step]) {
		float trend = [stmt floatValueOfColumn:1];
		[stmt reset];
        return trend;
	}
	// If nothing else, return weight (implies day is <= first day of data ever)
	return days[day - 1].scaleWeight;
}


// Used by LogEntryViewController to choose a default fat.
- (float)inputFatTrendOnDay:(EWDay)day {
    NSAssert(valid, @"Using an invalid EWDBMonth object!");
    // First, search backwards through this month for a trend value.
    for (int i = (day - 1) - 1; i >= 0; i--) {
        if (days[i].trendFatWeight > 0) {
            float trend = days[i].trendFatWeight;
            if (trend > 0) return trend;
        }
    }
    // If none is found, use the input trend
    SQLiteStatement *stmt = [database selectMonthStatement];
    [stmt bindInt:month toParameter:1];
    if ([stmt step]) {
        float fat = [stmt floatValueOfColumn:2];
        [stmt reset];
        return fat;
    }
    // If nothing else, return scale (in case day is <= first day of data)
    return days[day - 1].scaleFatWeight;
}


// Used by LogEntryViewController to determine entry mode (W vs W&F)
- (BOOL)didRecordFatBeforeDay:(EWDay)day {
    NSAssert(valid, @"Using an invalid EWDBMonth object!");
	for (int i = (day - 1) - 1; i >= 0; i--) {
		if (days[i].scaleWeight > 0) {
			return days[i].scaleFatWeight > 0;
		}
	}
	return [database didRecordFatBeforeMonth:month];
}


// Used by EWDatabase in updateTrendValues
- (void)updateTrends {
	[self updateTrendsSaveOutput:YES];
}


// Used by LogEntryViewController (single edit)
// Used by EWImporter (bulk edit)
- (void)setDBDay:(EWDBDay *)src onDay:(EWDay)day {
	NSParameterAssert((src->scaleFatWeight == 0) || 
					  ((src->scaleFatWeight > 0) && (src->scaleWeight > 0)));

	EWDBDay *dst = [self accessDBDayOnDay:day];
	
	if (dst->scaleWeight != src->scaleWeight) {
		dst->scaleWeight = src->scaleWeight;
		dst->trendWeight = 0;
		[database didChangeWeightOnMonthDay:EWMonthDayMake(month, day)];
	}
	
	if (dst->scaleFatWeight != src->scaleFatWeight) {
		dst->scaleFatWeight = src->scaleFatWeight;
		dst->trendFatWeight = 0;
		[database didChangeWeightOnMonthDay:EWMonthDayMake(month, day)];
	}
	
	dst->flags[0] = src->flags[0];
	dst->flags[1] = src->flags[1];
	dst->flags[2] = src->flags[2];
	dst->flags[3] = src->flags[3];
	
	if (dst->note != src->note) {
		CFStringRef oldNote = dst->note;
		if (src->note != NULL && CFStringGetLength(src->note) > 0) {
			dst->note = CFStringCreateCopy(kCFAllocatorDefault, src->note);
		} else {
			dst->note = NULL;
		}
        if (oldNote) CFRelease(oldNote);
	}

	EWSetBit(dirtyBits, day - 1);
}


- (BOOL)commitChanges {
	// This fast check is why we bother with a bit field.
	if (dirtyBits == 0) return NO;
	
	[self updateTrends];
	
	SQLiteStatement *insertStmt = [database insertDayStatement];
	SQLiteStatement *deleteStmt = [database deleteDayStatement];

	int i;
	UInt32 bits;
	for (i = 0, bits = dirtyBits; (bits != 0); i++, bits >>= 1) {
		if ((bits & 1) == 0) continue;
		EWDay day = i + 1;
		if ([self hasDataOnDay:day]) {
			struct EWDBDay *d = &days[i];
			[insertStmt bindInt:EWMonthDayMake(month, day) toParameter:kMonthDayColumn+1];
			if (d->scaleWeight > 0) {
				[insertStmt bindDouble:d->scaleWeight toParameter:kScaleWeightColumn+1];
			} else {
				[insertStmt bindNullToParameter:kScaleWeightColumn+1];
			}
			if (d->scaleFatWeight > 0) {
				[insertStmt bindDouble:d->scaleFatWeight toParameter:kScaleFatColumn+1];
			} else {
				[insertStmt bindNullToParameter:kScaleFatColumn+1];
			}
			[insertStmt bindInt:d->flags[0] toParameter:kFlag0Column+1];
			[insertStmt bindInt:d->flags[1] toParameter:kFlag1Column+1];
			[insertStmt bindInt:d->flags[2] toParameter:kFlag2Column+1];
			[insertStmt bindInt:d->flags[3] toParameter:kFlag3Column+1];
			[insertStmt bindString:(__bridge NSString *)d->note toParameter:kNoteColumn+1];
			[insertStmt step];
			[insertStmt reset];
		} else {
			[deleteStmt bindInt:EWMonthDayMake(month, day) toParameter:kMonthDayColumn+1];
			[deleteStmt step];
			[deleteStmt reset];
		}
	}
	
	dirtyBits = 0;
	return YES;
}


- (void)invalidate
{
    valid = NO;
}


#pragma mark Private Methods


- (void)updateTrendsSaveOutput:(BOOL)saveOutput {
    NSAssert(valid, @"Using an invalid EWDBMonth object!");
	float tw, tf;
	
	SQLiteStatement *stmt = [database selectMonthStatement];
	[stmt bindInt:month toParameter:1];
	if ([stmt step]) {
		tw = [stmt floatValueOfColumn:1];
		tf = [stmt floatValueOfColumn:2];
		[stmt reset];
	} else {
		tw = 0;
		tf = 0;
	}
	
	for (int i = 0; i < 31; i++) {
		struct EWDBDay *d = &days[i];
		EWDBUpdateTrendValue(d->scaleWeight, &d->trendWeight, &tw);
		EWDBUpdateTrendValue(d->scaleFatWeight, &d->trendFatWeight, &tf);
	}
	
	if (saveOutput) {
		stmt = [database insertMonthStatement];
		[stmt bindInt:month toParameter:1];
		[stmt bindDouble:tw toParameter:2];
		[stmt bindDouble:tf toParameter:3];
		[stmt step];
		[stmt reset];
	}
}


- (EWDBDay *)accessDBDayOnDay:(EWDay)day {
    NSAssert(valid, @"Using an invalid EWDBMonth object!");
	NSAssert1(day >= 1 && day <= 31, @"Day out of range: %d", day);
	return &days[day - 1];
}


@end
