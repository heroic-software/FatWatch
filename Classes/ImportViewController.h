/*
 * ImportViewController.h
 * Created by Benjamin Ragheb on 5/1/11.
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
#import "EWImporter.h"

@interface ImportViewController : UIViewController <EWImporterDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *importProgressView;
@property (nonatomic, strong) IBOutlet UILabel *detailLabel;
@property (nonatomic, strong) IBOutlet UIButton *okButton;
@property (nonatomic) BOOL promptBeforeImport;
- (id)initWithImporter:(EWImporter *)theImporter database:(EWDatabase *)db;
- (IBAction)okAction;
@end
