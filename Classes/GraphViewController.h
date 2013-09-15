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


@interface GraphViewController : UIViewController <UIActionSheetDelegate, UIScrollViewDelegate> {
	BOOL isLoading;
	EWDatabase *database;
	YAxisView *axisView;
	UIScrollView *scrollView;
	UISegmentedControl *spanControl;
	UISegmentedControl *typeControl;
	UIBarButtonItem *actionButtonItem;
    NSArray *graphSegments;
	NSMutableArray *cachedGraphViews;
	NSInteger lastMinIndex, lastMaxIndex;
	GraphViewParameters parameters;
	EWMonth scrollingSpanSavedMonth;
	CGFloat scrollingSpanSavedOffsetX;
	NSInteger saveButtonIndex, copyButtonIndex;
}
@property (nonatomic,retain) IBOutlet EWDatabase *database;
@property (nonatomic,retain) IBOutlet YAxisView *axisView;
@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic,retain) IBOutlet UISegmentedControl *spanControl;
@property (nonatomic,retain) IBOutlet UISegmentedControl *typeControl;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *actionButtonItem;
- (void)clearGraphSegments;
- (IBAction)spanSelected:(UISegmentedControl *)sender;
- (IBAction)typeSelected:(UISegmentedControl *)sender;
- (IBAction)showActionMenu:(UIBarButtonItem *)sender;
@end
