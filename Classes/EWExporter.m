/*
 * EWExporter.m
 * Created by Benjamin Ragheb on 12/18/09.
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

#import "EWExporter.h"
#import "EWDatabase.h"
#import "EWDBIterator.h"
#import "EWDBMonth.h"
#import "EWWeightFormatter.h"
#import "EWDateFormatter.h"


NSArray *EWFatFormatterNames() {
	return @[@"Percentage (0...100)", @"Ratio (0...1)"];
}


NSFormatter *EWFatFormatterAtIndex(int i) {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[formatter setMinimum:@0.0f];
	[formatter setMaximum:@1.0f];
	if (i == 0) {
		[formatter setMultiplier:@100.0f];
	}
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setLocale:locale];
	return formatter;
}


@implementation EWExporter
{
	int fieldCount;
	EWExporterField fieldOrder[EWExporterFieldCount];
	NSString *fieldNames[EWExporterFieldCount];
	NSFormatter *fieldFormatters[EWExporterFieldCount];
	NSDate *beginDate;
	NSDate *endDate;
}

@synthesize beginDate;
@synthesize endDate;


#pragma mark Public API


- (void)addField:(EWExporterField)field name:(NSString *)name formatter:(NSFormatter *)formatter {
	NSAssert(fieldCount < EWExporterFieldCount, @"too many fields!");
	NSAssert(fieldNames[field] == nil, @"duplicate field");
	NSAssert(fieldFormatters[field] == nil, @"duplicate formatter");
	NSAssert(name != nil, @"must have a name");
	NSAssert(field < EWExporterFieldCount, @"invalid field ID");
	
	fieldOrder[fieldCount] = field;
	fieldCount += 1;
	
	fieldNames[field] = [name copy];
	fieldFormatters[field] = formatter;
}


- (void)addBackupFields {
	NSFormatter *weightFormatter = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleExport];
	
	[self addField:EWExporterFieldDate 
			  name:@"Date"
		 formatter:[[EWISODateFormatter alloc] init]];
	[self addField:EWExporterFieldWeight 
			  name:@"Weight" 
		 formatter:weightFormatter];
	[self addField:EWExporterFieldTrendWeight
			  name:@"Trend"
		 formatter:weightFormatter];
	[self addField:EWExporterFieldFat
			  name:@"BodyFat"
		 formatter:EWFatFormatterAtIndex(0)];
	[self addField:EWExporterFieldFlag0 
			  name:@"Mark1"
		 formatter:nil];
	[self addField:EWExporterFieldFlag1
			  name:@"Mark2"
		 formatter:nil];
	[self addField:EWExporterFieldFlag2 
			  name:@"Mark3"
		 formatter:nil];
	[self addField:EWExporterFieldFlag3 
			  name:@"Mark4"
		 formatter:nil];
	[self addField:EWExporterFieldNote
			  name:@"Note"
		 formatter:nil];
}


- (NSArray *)orderedFieldNames {
	NSMutableArray *names = [NSMutableArray array];
	for (int i = 0; i < fieldCount; i++) {
		EWExporterField f = fieldOrder[i];
		[names addObject:fieldNames[f]];
	}
	return names;
}


- (void)performExportOfDatabase:(EWDatabase *)db {
	EWMonthDay beginMonthDay, endMonthDay;

	if (beginDate) {
		beginMonthDay = EWMonthDayFromDate(beginDate);
	} else {
		beginMonthDay = EWMonthDayMake(db.earliestMonth, 1);
	}
	if (endDate) {
		endMonthDay = EWMonthDayFromDate(endDate);
	} else {
		endMonthDay = EWMonthDayMake(db.latestMonth, 31);
	}

	EWDBIterator *it = [db iterator];
	it.earliestMonthDay = beginMonthDay;
	it.latestMonthDay = endMonthDay;
	it.skipEmptyRecords = YES;
	const EWDBDay *dd;

	while ((dd = [it nextDBDay])) {
        @autoreleasepool {
            [self beginRecord];
            for (int i = 0; i < fieldCount; i++) {
                EWExporterField f = fieldOrder[i];
                id value;
                
                switch (f) {
                    case EWExporterFieldDate:
                        value = @(it.currentMonthDay);
                        break;
                    case EWExporterFieldWeight:
                        value = @(dd->scaleWeight);
                        break;
                    case EWExporterFieldTrendWeight:
                        value = @(dd->trendWeight);
                        break;
                    case EWExporterFieldFat: {
                        float ratio;
                        if (dd->scaleFatWeight > 0 && dd->scaleWeight > 0) {
                            ratio = dd->scaleFatWeight / dd->scaleWeight;
                        } else {
                            ratio = 0;
                        }
                        value = @(ratio);
                        break;
                    }
                    case EWExporterFieldFlag0:
                        value = @(dd->flags[0]);
                        break;
                    case EWExporterFieldFlag1:
                        value = @(dd->flags[1]);
                        break;
                    case EWExporterFieldFlag2:
                        value = @(dd->flags[2]);
                        break;
                    case EWExporterFieldFlag3:
                        value = @(dd->flags[3]);
                        break;
                    case EWExporterFieldNote:
                        value = (__bridge NSString *)dd->note;
                        break;
                    default:
                        value = nil;
                        break;
                }
                
                [self exportField:f value:value];
            }
            [self endRecord];
        }
	}
}


#pragma mark Optional Overrides


- (void)beginRecord {
}


- (void)exportField:(EWExporterField)field value:(id)value {
	NSFormatter *formatter = fieldFormatters[field];
	NSString *string;
	if (formatter) {
		string = [formatter stringForObjectValue:value];
	} else {
		string = [value description];
	}
	[self exportField:field formattedValue:string];
}


- (void)endRecord {
}


#pragma mark Mandatory Overrides


- (NSString *)fileExtension {
	NSAssert(NO, @"must override");
	return nil;
}


- (NSString *)contentType {
	NSAssert(NO, @"must override");
	return nil;
}


- (void)exportField:(EWExporterField)field formattedValue:(NSString *)string {
	NSAssert(NO, @"must override");
}


- (NSData *)dataExportedFromDatabase:(EWDatabase *)db {
	NSAssert(NO, @"must override");
	return nil;
}

@end
