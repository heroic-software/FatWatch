/*
 * EWWeightFormatter.h
 * Created by Benjamin Ragheb on 12/20/09.
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
#import "NSUserDefaults+EWAdditions.h"


typedef enum {
	EWWeightFormatterStyleDisplay,
	EWWeightFormatterStyleVariance,
	EWWeightFormatterStyleWhole,
	EWWeightFormatterStyleGraph,
	EWWeightFormatterStyleExport,
	EWWeightFormatterStyleBMI,
	EWWeightFormatterStyleBMILabeled
} EWWeightFormatterStyle;


@interface NSFormatter (EWAdditions)
- (NSString *)stringForFloat:(float)value;
@end


@interface EWWeightFormatter : NSFormatter {
}
+ (void)getBMIWeights:(float *)weightArray;
+ (UIColor *)colorForWeight:(float)weight alpha:(float)alpha;
+ (UIColor *)colorForWeight:(float)weight;
+ (id)weightFormatterWithStyle:(EWWeightFormatterStyle)style unit:(EWWeightUnit)unit;
+ (id)weightFormatterWithStyle:(EWWeightFormatterStyle)style;
@end
