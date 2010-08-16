//
//  TrendViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphDrawingOperation.h"


@class EWTrendButton;
@class GraphView;
@class EWDatabase;


@interface TrendViewController : UIViewController {
	EWDatabase *database;
	NSArray *spanArray;
	int spanIndex;
	BOOL showAbsoluteDate;
	GraphViewParameters graphParams;
	GraphView *graphView;
	UIView *changeGroupView;
	EWTrendButton *weightChangeButton;
	EWTrendButton *energyChangeButton;
	UIView *goalGroupView;
	EWTrendButton *relativeEnergyButton;
	EWTrendButton *relativeWeightButton;
	EWTrendButton *dateButton;
	EWTrendButton *planButton;
	UIView *flagGroupView;
	UILabel *flag0Label;
	UILabel *flag1Label;
	UILabel *flag2Label;
	UILabel *flag3Label;
	UIView *messageGroupView;
	UIView *goalAttainedView;
}
@property (nonatomic,retain) EWDatabase *database;
@property (nonatomic,retain) IBOutlet GraphView	*graphView;
@property (nonatomic,retain) IBOutlet UIView *changeGroupView;
@property (nonatomic,retain) IBOutlet EWTrendButton *weightChangeButton;
@property (nonatomic,retain) IBOutlet EWTrendButton *energyChangeButton;
@property (nonatomic,retain) IBOutlet UIView *goalGroupView;
@property (nonatomic,retain) IBOutlet EWTrendButton *relativeEnergyButton;
@property (nonatomic,retain) IBOutlet EWTrendButton *relativeWeightButton;
@property (nonatomic,retain) IBOutlet EWTrendButton *dateButton;
@property (nonatomic,retain) IBOutlet EWTrendButton *planButton;
@property (nonatomic,retain) IBOutlet UIView *flagGroupView;
@property (nonatomic,retain) IBOutlet UILabel *flag0Label;
@property (nonatomic,retain) IBOutlet UILabel *flag1Label;
@property (nonatomic,retain) IBOutlet UILabel *flag2Label;
@property (nonatomic,retain) IBOutlet UILabel *flag3Label;
@property (nonatomic,retain) IBOutlet UIView *messageGroupView;
@property (nonatomic,retain) IBOutlet UIView *goalAttainedView;
- (IBAction)showEnergyEquivalents:(id)sender;
- (IBAction)toggleDateFormat:(id)sender;
@end
