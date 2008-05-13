//
//  EWDate.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/12/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

#define EWMonthDayMake(m,d) (((m) << 5) | (d))
#define EWMonthDayGetMonth(md) ((md) >> 5)
#define EWMonthDayGetDay(md) (0x1F & (md))

typedef NSInteger EWMonth;
typedef NSInteger EWDay;

void EWDateInit();
NSUInteger EWDaysInMonth(EWMonth m);
NSDate *NSDateFromEWMonthAndDay(EWMonth m, EWDay d);
EWMonth EWMonthFromDate(NSDate *theDate);
EWDay EWDayFromDate(NSDate *theDate);
