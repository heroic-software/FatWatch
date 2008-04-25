//
//  NewDatabaseViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/24/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Database;

@interface NewDatabaseViewController : UIViewController {
	Database *database;
}
- (id)initWithDatabase:(Database *)db;
@end
