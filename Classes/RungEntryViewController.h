/*
 * RungEntryViewController.h
 * Created by Benjamin Ragheb on 12/21/09.
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


@interface RungEntryViewController : UIViewController
@property (nonatomic,weak) id target;
@property (nonatomic,copy) NSString *key;
@property (nonatomic,strong) IBOutlet UISegmentedControl *rungControl;
@property (nonatomic,strong) IBOutlet UILabel *rungLabel;
@property (nonatomic,strong) IBOutlet UILabel *ladderLabel;
@property (nonatomic,strong) IBOutlet UILabel *bendLabel;
@property (nonatomic,strong) IBOutlet UILabel *sitUpLabel;
@property (nonatomic,strong) IBOutlet UILabel *legLiftLabel;
@property (nonatomic,strong) IBOutlet UILabel *pushUpLabel;
@property (nonatomic,strong) IBOutlet UILabel *stepsLabel;
@property (nonatomic,strong) IBOutlet UILabel *setsLabel;
@property (nonatomic,strong) IBOutlet UILabel *extraStepsLabel;
- (IBAction)changeRung;
- (IBAction)dismiss;
- (IBAction)clearRungAndDismiss;
- (IBAction)saveRungAndDismiss;
@end
