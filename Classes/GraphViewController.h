//
//  GraphViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Database;

@interface GraphViewController : UIViewController {
	Database *database;
	BOOL firstLoad;
}
- (id)initWithDatabase:(Database *)db;
@end
