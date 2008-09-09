//
//  TrendViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataViewController.h"

@interface TrendViewController : DataViewController <UITableViewDelegate, UITableViewDataSource> {
	NSMutableArray *array;
	BOOL showEndDateAsDate;
}

@end
