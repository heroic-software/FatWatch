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


typedef struct {
	EWMonthDay beginMonthDay;
	EWMonthDay endMonthDay;
	CGFloat offsetX;
	CGFloat width;
	GraphView *view;
	CGImageRef imageRef;
	GraphDrawingOperation *operation;
} GraphViewInfo;


@interface GraphViewController : UIViewController <UIActionSheetDelegate, UIScrollViewDelegate> {
	EWDatabase *database;
	YAxisView *axisView;
	UIScrollView *scrollView;
	UISegmentedControl *spanControl;
	UISegmentedControl *typeControl;
	UIBarButtonItem *actionButtonItem;
	GraphViewInfo *info;
	size_t infoCount;
	NSMutableArray *cachedGraphViews;
	int lastMinIndex, lastMaxIndex;
	GraphViewParameters parameters;
	CGPoint scrollingSpanSavedOffset;
	int saveButtonIndex, copyButtonIndex;
}
@property (nonatomic,retain) IBOutlet EWDatabase *database;
@property (nonatomic,retain) IBOutlet YAxisView *axisView;
@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic,retain) IBOutlet UISegmentedControl *spanControl;
@property (nonatomic,retain) IBOutlet UISegmentedControl *typeControl;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *actionButtonItem;
- (void)clearGraphViewInfo;
- (IBAction)spanSelected:(UISegmentedControl *)sender;
- (IBAction)typeSelected:(UISegmentedControl *)sender;
- (IBAction)showActionMenu:(UIBarButtonItem *)sender;
@end
