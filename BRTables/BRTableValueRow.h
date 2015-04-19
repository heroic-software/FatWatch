/*
 * BRTableValueRow.h
 * Created by Benjamin Ragheb on 7/26/08.
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
#import "BRTableRow.h"


@protocol BRColorFormatter
- (UIColor *)colorForObjectValue:(id)anObject;
@end


@interface BRTableValueRow : BRTableRow
@property (nonatomic,strong) NSString *key;
@property (nonatomic,strong) NSFormatter *formatter;
@property (nonatomic,strong) id <BRColorFormatter> textColorFormatter;
@property (nonatomic,strong) id <BRColorFormatter> backgroundColorFormatter;
@property (nonatomic) BOOL disabled;
@property (nonatomic,strong) id value;
@property (nonatomic,strong) NSString *valueDescription;
@end
