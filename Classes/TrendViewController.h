/*
 * TrendViewController.h
 * Created by Benjamin Ragheb on 3/29/08.
 * Copyright 2015 Heroic Software Inc
 *
 * This file is part of FatWatch.
 *
 * FatWatch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FatWatch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
 */

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


@interface TrendViewController : UIViewController
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
