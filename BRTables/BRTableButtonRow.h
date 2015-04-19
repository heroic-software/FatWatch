/*
 * BRTableButtonRow.h
 * Created by Benjamin Ragheb on 7/25/08.
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


/* For a button row that opens an URL, set target to nil and the object to an instance of NSURL. */


@interface BRTableButtonRow : BRTableRow
+ (BRTableButtonRow *)rowWithTitle:(NSString *)aTitle target:(id)aTarget action:(SEL)anAction;
@property (nonatomic,weak) id target;
@property (nonatomic) SEL action;
@property (nonatomic) BOOL disabled;
@property (nonatomic) BOOL followURLRedirects;
@end
