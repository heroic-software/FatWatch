/*
 * BRTableRow.h
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


@class BRTableSection;


@interface BRTableRow : NSObject
+ (BRTableRow *)rowWithTitle:(NSString *)aTitle;
+ (BRTableRow *)rowWithObject:(id)anObject;
@property (nonatomic) UITableViewCellStyle cellStyle;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *detail;
@property (nonatomic) UITextAlignment titleAlignment;
@property (nonatomic,strong) UIColor *titleColor;
@property (nonatomic) UITableViewCellAccessoryType accessoryType;
@property (nonatomic,strong) UIView *accessoryView;
@property (nonatomic) UITableViewCellSelectionStyle selectionStyle;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) id object;
@property (weak, nonatomic,readonly) BRTableSection *section;
- (NSString *)reuseableCellIdentifier;
- (UITableViewCell *)createCell;
- (void)configureCell:(UITableViewCell *)cell;
- (UITableViewCell *)cell;
- (NSIndexPath *)indexPath;
- (void)didAddToSection:(BRTableSection *)section;
- (void)willRemoveFromSection;
- (void)didSelect;
- (void)updateCell;
- (void)deselectAnimated:(BOOL)animated;
@end
