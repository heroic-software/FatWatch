/*
 * EWTrendButton.h
 * Created by Benjamin Ragheb on 12/24/09.
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


typedef enum {
	EWTrendButtonAccessoryNone,
	EWTrendButtonAccessoryDisclosureIndicator,
	EWTrendButtonAccessoryToggle
} EWTrendButtonAccessoryType;


@interface EWTrendButton : UIControl
@property (nonatomic) EWTrendButtonAccessoryType accessoryType;
- (void)setText:(NSString *)text forPart:(int)part;
- (void)setTextColor:(UIColor *)color forPart:(int)part;
- (void)setFont:(UIFont *)font forPart:(int)part;
@end
