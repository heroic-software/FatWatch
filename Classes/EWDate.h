/*
 * EWDate.h
 * Created by Benjamin Ragheb on 4/12/08.
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
