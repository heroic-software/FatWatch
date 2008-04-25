//
//  EWDate.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/12/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSInteger EWMonth;
typedef NSInteger EWDay;

void EWDateInit();
NSUInteger EWDaysInMonth(EWMonth m);
NSDate *NSDateFromEWMonthAndDay(EWMonth m, EWDay d);
EWMonth EWMonthFromDate(NSDate *theDate);
EWDay EWDayFromDate(NSDate *theDate);
