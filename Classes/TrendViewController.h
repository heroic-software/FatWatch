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


typedef enum {
	TrendGoalStateUndefined,
	TrendGoalStateDefined,
	TrendGoalStateAttained
} TrendGoalState;


@interface TrendViewController : UIViewController {
	EWDatabase *database;
	NSArray *spanArray;
	NSUInteger spanIndex;
	BOOL showFat;
	BOOL showAbsoluteDate;
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
	TrendGoalState goalState;
}
@property (nonatomic,strong) IBOutlet EWDatabase *database;
@property (nonatomic,strong) IBOutlet GraphView	*graphView;
@property (nonatomic,strong) IBOutlet UIView *changeGroupView;
@property (nonatomic,strong) IBOutlet EWTrendButton *weightChangeButton;
@property (nonatomic,strong) IBOutlet EWTrendButton *energyChangeButton;
@property (nonatomic,strong) IBOutlet UIView *goalGroupView;
@property (nonatomic,strong) IBOutlet EWTrendButton *relativeEnergyButton;
@property (nonatomic,strong) IBOutlet EWTrendButton *relativeWeightButton;
@property (nonatomic,strong) IBOutlet EWTrendButton *dateButton;
@property (nonatomic,strong) IBOutlet EWTrendButton *planButton;
@property (nonatomic,strong) IBOutlet UIView *flagGroupView;
@property (nonatomic,strong) IBOutlet UILabel *flag0Label;
@property (nonatomic,strong) IBOutlet UILabel *flag1Label;
@property (nonatomic,strong) IBOutlet UILabel *flag2Label;
@property (nonatomic,strong) IBOutlet UILabel *flag3Label;
@property (nonatomic,strong) IBOutlet UIView *messageGroupView;
@property (nonatomic,strong) IBOutlet UIView *goalAttainedView;
- (IBAction)showEnergyEquivalents:(id)sender;
- (IBAction)toggleDateFormat:(id)sender;
- (IBAction)toggleTotalOrFat:(id)sender;
- (IBAction)previousSpan:(id)sender;
- (IBAction)nextSpan:(id)sender;
@end
