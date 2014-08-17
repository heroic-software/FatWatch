//
//  EWDate.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/12/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EW_INLINE static __inline__
#define EW_EXTERN extern

typedef int EWMonthDay;
typedef int EWMonth;
typedef int EWDay;

EW_INLINE EWMonthDay EWMonthDayMake(EWMonth m, EWDay d) { return (m << 5) | d; }
EW_INLINE EWMonth EWMonthDayGetMonth(EWMonthDay md) { return md >> 5; }
EW_INLINE EWDay EWMonthDayGetDay(EWMonthDay md) { return 0x1F & md; }

EW_EXTERN int EWDaysInMonth(EWMonth m);
EW_EXTERN NSInteger EWDaysBetweenMonthDays(EWMonthDay mdA, EWMonthDay mdB);
EW_EXTERN EWMonthDay EWMonthDayNext(EWMonthDay md);
EW_EXTERN EWMonthDay EWMonthDayPrevious(EWMonthDay md);
EW_EXTERN NSDate *EWDateFromMonthAndDay(EWMonth m, EWDay d);
EW_EXTERN EWMonthDay EWMonthDayFromDate(NSDate *theDate);
EW_EXTERN EWMonthDay EWMonthDayToday();
EW_EXTERN BOOL EWMonthAndDayIsWeekend(EWMonth m, EWDay d);
EW_EXTERN NSUInteger EWWeekdayFromMonthAndDay(EWMonth m, EWDay d);

EW_INLINE NSDate *EWDateFromMonthDay(EWMonthDay md) { 
	return EWDateFromMonthAndDay(EWMonthDayGetMonth(md), EWMonthDayGetDay(md));
}
