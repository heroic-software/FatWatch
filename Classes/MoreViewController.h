//
//  MoreViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/10/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BRTableViewController.h"


@class EWDatabase;


@interface MoreViewController : BRTableViewController <MFMailComposeViewControllerDelegate> {
	EWDatabase *database;
}
@property (nonatomic,retain) IBOutlet EWDatabase *database;
@end
