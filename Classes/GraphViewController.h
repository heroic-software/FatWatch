//
//  GraphViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EWDate.h"
#import "GraphView.h"
#import "GraphDrawingOperation.h"


@class YAxisView;
@class EWDatabase;


@interface GraphViewController : UIViewController <UIActionSheetDelegate, UIScrollViewDelegate>
@property (nonatomic,strong) IBOutlet EWDatabase *database;
@property (nonatomic,strong) IBOutlet YAxisView *axisView;
@property (nonatomic,strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) IBOutlet UISegmentedControl *spanControl;
@property (nonatomic,strong) IBOutlet UISegmentedControl *typeControl;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *actionButtonItem;
- (void)clearGraphSegments;
- (IBAction)spanSelected:(UISegmentedControl *)sender;
- (IBAction)typeSelected:(UISegmentedControl *)sender;
- (IBAction)showActionMenu:(UIBarButtonItem *)sender;
@end
