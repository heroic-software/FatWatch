//
//  EWExporter.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/18/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "EWExporter.h"
#import "EWDatabase.h"
#import "EWDBMonth.h"
#import "EWWeightFormatter.h"
#import "EWDateFormatter.h"


NSArray *EWFatFormatterNames() {
	return [NSArray arrayWithObjects:
			@"Percentage (0...100)", 
			@"Ratio (0...1)",
			nil];
}


NSFormatter *EWFatFormatterAtIndex(int index) {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[formatter setMinimum:[NSNumber numberWithFloat:0]];
	[formatter setMaximum:[NSNumber numberWithFloat:1]];
	if (index == 0) {
		[formatter setMultiplier:[NSNumber numberWithFloat:100]];
	}
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setLocale:locale];
	[locale release];
	return [formatter autorelease];
}


@implementation EWExporter


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
	fieldFormatters[field] = [formatter retain];
}


- (void)addBackupFields {
	NSFormatter *weightFormatter = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleExport];
	
	[self addField:EWExporterFieldDate 
			  name:@"Date"
		 formatter:[[[EWISODateFormatter alloc] init] autorelease]];
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


- (void)performExport {
	EWDatabase *db = [EWDatabase sharedDatabase];

	EWMonth beginMonth, endMonth;
	EWDay beginDay, endDay;
	
	if (beginDate) {
		EWMonthDay beginMD = EWMonthDayFromDate(beginDate);
		beginMonth = EWMonthDayGetMonth(beginMD);
		beginDay = EWMonthDayGetDay(beginMD);
	} else {
		beginMonth = db.earliestMonth;
		beginDay = 1;
	}

	if (endDate) {
		EWMonthDay endMD = EWMonthDayFromDate(endDate);
		endMonth = EWMonthDayGetMonth(endMD);
		endDay = EWMonthDayGetDay(endMD);
	} else {
		endMonth = db.latestMonth;
		endDay = 31;
	}
	
	EWDBMonth *dbm = [db getDBMonth:beginMonth];
	
	while (dbm && dbm.month <= endMonth) {
		EWDay firstDay = (dbm.month == beginMonth) ? beginDay : 1;
		EWDay lastDay = (dbm.month == endMonth) ? endDay : 31;
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		for (EWDay day = firstDay; day <= lastDay; day++) {
			if (! [dbm hasDataOnDay:day]) continue;
			
			const EWDBDay *dd = [dbm getDBDayOnDay:day];
			
			[self beginRecord];
			
			for (int i = 0; i < fieldCount; i++) {
				EWExporterField f = fieldOrder[i];
				id value;
				
				switch (f) {
					case EWExporterFieldDate:
						value = [NSNumber numberWithInt:EWMonthDayMake(dbm.month, day)];
						break;
					case EWExporterFieldWeight:
						value = [NSNumber numberWithFloat:dd->scaleWeight];
						break;
					case EWExporterFieldTrendWeight:
						value = [NSNumber numberWithFloat:dd->trendWeight];
						break;
					case EWExporterFieldFat:
						value = [NSNumber numberWithFloat:dd->scaleFat];
						break;
					case EWExporterFieldFlag0:
						value = [NSNumber numberWithUnsignedChar:dd->flags[0]];
						break;
					case EWExporterFieldFlag1:
						value = [NSNumber numberWithUnsignedChar:dd->flags[1]];
						break;
					case EWExporterFieldFlag2:
						value = [NSNumber numberWithUnsignedChar:dd->flags[2]];
						break;
					case EWExporterFieldFlag3:
						value = [NSNumber numberWithUnsignedChar:dd->flags[3]];
						break;
					case EWExporterFieldNote:
						value = dd->note;
						break;
					default:
						value = nil;
						break;
				}
				
				[self exportField:f value:value];
			}
			
			[self endRecord];
		}
		[pool drain];
		
		dbm = dbm.next;
#if TARGET_IPHONE_SIMULATOR
		[NSThread sleepForTimeInterval:1.0/12.0];
#endif
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


- (NSData *)exportedData {
	NSAssert(NO, @"must override");
	return nil;
}


#pragma mark Cleanup


- (void)dealloc {
	for (int i = 0; i < EWExporterFieldCount; i++) {
		[fieldNames[i] release];
		[fieldFormatters[i] release];
	}
	[beginDate release];
	[endDate release];
	[super dealloc];
}

@end
