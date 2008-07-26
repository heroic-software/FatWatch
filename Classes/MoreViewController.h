//
//  MoreViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/10/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTableViewController.h"


@class MicroWebServer;


@interface MoreViewController : BRTableViewController {
	MicroWebServer *webServer;
}
@end
