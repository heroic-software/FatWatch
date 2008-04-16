//
//  GraphView.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/16/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWDate.h"

@class Database;

@interface GraphView : UIView {
	Database *database;
	EWMonth month;
}
- (id)initWithDatabase:(Database *)db month:(EWMonth)m;
@end
