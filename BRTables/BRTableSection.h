/*
 * BRTableSection.h
 * Created by Benjamin Ragheb on 7/18/08.
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


@class BRTableViewController;
@class BRTableRow;


@interface BRTableSection : NSObject
+ (BRTableSection *)section;
@property (nonatomic,strong) NSString *headerTitle;
@property (nonatomic,strong) NSString *footerTitle;
@property (weak, nonatomic,readonly) BRTableViewController *controller;
- (void)didAddToController:(BRTableViewController *)aController;
- (void)willRemoveFromController;
- (NSUInteger)numberOfRows;
- (BRTableRow *)rowAtIndex:(NSUInteger)index;
- (NSIndexPath *)indexPathOfRow:(BRTableRow *)row;
- (void)addRow:(BRTableRow *)tableRow animated:(BOOL)animated;
- (void)removeRowAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (UITableViewCell *)cellForRow:(BRTableRow *)row;
- (void)configureCell:(UITableViewCell *)cell forRowAtIndex:(NSUInteger)index;
- (void)didSelectRowAtIndex:(NSUInteger)index;
@end


@interface BRTableRadioSection : BRTableSection
@property (nonatomic) NSInteger selectedIndex;
@property (weak, nonatomic,readonly) BRTableRow *selectedRow;
@end
