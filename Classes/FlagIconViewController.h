/*
 * FlagIconViewController.h
 * Created by Benjamin Ragheb on 1/16/10.
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

@class FlagTabView;

@interface FlagIconViewController : UIViewController
@property (nonatomic,strong) IBOutlet FlagTabView *flagTabView;
@property (nonatomic,strong) IBOutlet UIScrollView *iconArea;
@property (nonatomic,strong) IBOutlet UIView *enableLadderView;
@property (nonatomic,strong) IBOutlet UIView *disableLadderView;
- (IBAction)flagButtonAction:(UIButton *)sender;
- (IBAction)useLastFlagForLadder:(UIButton *)sender;
- (IBAction)useLastFlagForIcon:(UIButton *)sender;
- (IBAction)explainLadder:(UIButton *)sender;
@end
