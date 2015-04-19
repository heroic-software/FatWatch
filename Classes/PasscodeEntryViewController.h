/*
 * PasscodeEntryViewController.h
 * Created by Benjamin Ragheb on 7/22/08.
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


@interface PasscodeEntryViewController : UIViewController
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet UIView *digitGroupView;
@property (nonatomic, weak) IBOutlet UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet UILabel *smallLabel;
@property (nonatomic, weak) IBOutlet UIImageView *digit0View;
@property (nonatomic, weak) IBOutlet UIImageView *digit1View;
@property (nonatomic, weak) IBOutlet UIImageView *digit2View;
@property (nonatomic, weak) IBOutlet UIImageView *digit3View;
@property (nonatomic, weak) IBOutlet UITextField *codeField;
+ (BOOL)authorizationRequired;
+ (void)removePasscode;
+ (PasscodeEntryViewController *)controllerForSettingCode;
+ (PasscodeEntryViewController *)controllerForAuthorization;
- (IBAction)codeFieldEditingChanged:(id)sender;
// Abstract:
- (BOOL)shouldDismissEnteredCode:(NSString *)userCode;
- (void)dismissView;
- (IBAction)cancelAction;
@end
