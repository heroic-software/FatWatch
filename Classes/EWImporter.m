//
//  EWImporter.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/21/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "EWImporter.h"
#import "CSVReader.h"
#import "EWWeightFormatter.h"
#import "EWDatabase.h"
#import "EWDBMonth.h"
#import "EWGoal.h"


@implementation EWImporter


@synthesize delegate;
@synthesize deleteFirst;
@synthesize importing;


- (id)initWithData:(NSData *)aData encoding:(NSStringEncoding)anEncoding {
	if ((self = [self init])) {
		reader = [[CSVReader alloc] initWithData:aData encoding:anEncoding];
		
		columnNames = [[reader readRow] copy];
		
		NSMutableArray *samples = [[NSMutableArray alloc] init];
		for (NSUInteger c = 0; c < [columnNames count]; c++) {
			[samples addObject:[NSMutableArray array]];
		}
		for (NSUInteger r = 0; r < 5; r++) {
			for (NSUInteger c = 0; c < [columnNames count]; c++) {
				NSString *value = [reader readString];
				if ([value length] > 0) {
					[[samples objectAtIndex:c] addObject:value];
				}
			}
			[reader nextRow];
		}
		sampleValues = [samples copy];
		[samples release];
		
		[reader reset];
		
		NSString *mapPath = [[NSBundle mainBundle] pathForResource:@"ImportColumns" ofType:@"plist"];
		NSDictionary *map = [[NSDictionary alloc] initWithContentsOfFile:mapPath];
		
		NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
		for (NSUInteger c = 0; c < [columnNames count]; c++) {
			NSString *name = [[columnNames objectAtIndex:c] lowercaseString];
			NSString *field = [map objectForKey:name];
			if (field) {
				[defaults setObject:[NSNumber numberWithInt:(c+1)] forKey:field];
			}
		}
		
		[map release];
		
		importDefaults = [defaults copy];
		[defaults release];
	}
	return self;
}


- (NSDictionary *)infoForJavaScript {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			columnNames, @"columns",
			sampleValues, @"samples",
			importDefaults, @"importDefaults",
			nil];
}


- (void)setColumn:(int)column forField:(EWImporterField)field {
	NSAssert(field >= 0 && field < EWImporterFieldCount, @"field out of range");
	NSAssert(columnForField[field] == 0, @"double set column!");
	columnForField[field] = column;
}


- (void)setFormatter:(NSFormatter *)formatter forField:(EWImporterField)field {
	NSAssert([formatter isKindOfClass:[NSFormatter class]], @"not a formatter!");
	NSAssert(field >= 0 && field < EWImporterFieldCount, @"field out of range");
	NSAssert(formatterForField[field] == nil, @"double set formatter!");
	formatterForField[field] = [formatter retain];
}


- (BOOL)performImportToDatabase:(EWDatabase *)db {
	importing = YES;
	rowCount = 0;
	importedCount = 0;
	
	if (self.deleteFirst) {
		[EWGoal deleteGoal];
		[db deleteAllData];
	}
	
	[self performSelector:@selector(continueImportToDatabase:) withObject:db afterDelay:0];
	return YES;
}


- (id)valueForField:(EWImporterField)field inArray:(NSArray *)rowArray {
	NSUInteger i = columnForField[field] - 1;
	if (i >= [rowArray count]) return nil; // not enough data in row
	id value = [rowArray objectAtIndex:i];
	if ([value length] == 0) return nil; // no value
	NSFormatter *formatter = formatterForField[field];
	if (formatter) {
		id objectValue = nil;
		NSString *error = nil;
		if ([formatter getObjectValue:&objectValue forString:value errorDescription:&error]) {
			return objectValue;
		} else {
			NSLog(@"Can't interpret '%@' with %@: %@", value, formatter, error);
			return nil;
		}
	}
	return value;
}


- (void)continueImportToDatabase:(EWDatabase *)db {
	NSDate *recessDate = [NSDate dateWithTimeIntervalSinceNow:0.1];

	NSArray *rowArray;
	while ((rowArray = [reader readRow])) {
		rowCount += 1;
				
		NSNumber *monthDay = [self valueForField:EWImporterFieldDate inArray:rowArray];
		if (monthDay == nil) continue;

		EWMonthDay md = [monthDay intValue];
		EWDBMonth *dbm = [db getDBMonth:EWMonthDayGetMonth(md)];
		EWDay day = EWMonthDayGetDay(md);
		EWDBDay dd;

		bcopy([dbm getDBDayOnDay:day], &dd, sizeof(EWDBDay));
		
		id value;
		
		value = [self valueForField:EWImporterFieldWeight inArray:rowArray];
		if (value) dd.scaleWeight = [value floatValue];
		
		value = [self valueForField:EWImporterFieldFatRatio inArray:rowArray];
		if (value && dd.scaleWeight > 0) {
			dd.scaleFatWeight = [value floatValue] * dd.scaleWeight;
		}

		value = [self valueForField:EWImporterFieldFlag0 inArray:rowArray];
		if (value) dd.flags[0] = [value intValue];
		value = [self valueForField:EWImporterFieldFlag1 inArray:rowArray];
		if (value) dd.flags[1] = [value intValue];
		value = [self valueForField:EWImporterFieldFlag2 inArray:rowArray];
		if (value) dd.flags[2] = [value intValue];
		value = [self valueForField:EWImporterFieldFlag3 inArray:rowArray];
		if (value) dd.flags[3] = [value intValue];

		value = [self valueForField:EWImporterFieldNote inArray:rowArray];
		if (value) dd.note = value;
		
		[dbm setDBDay:&dd onDay:day];

		importedCount += 1;

		if ([recessDate timeIntervalSinceNow] < 0) {
			[delegate importer:self importProgress:reader.progress];
#if TARGET_IPHONE_SIMULATOR
			[self performSelector:@selector(continueImportToDatabase:) withObject:db afterDelay:1];
#else
			[self performSelector:@selector(continueImportToDatabase:) withObject:db afterDelay:0];
#endif
			return;
		}
	}

	[self concludeImportToDatabase:db];
}


- (void)concludeImportToDatabase:(EWDatabase *)db {
	[db commitChanges];
	importing = NO;
	[delegate importer:self didImportNumberOfMeasurements:importedCount outOfNumberOfRows:rowCount];
}


- (void)dealloc {
	[reader release];
	[columnNames release];
	[sampleValues release];
	[importDefaults release];
	for (int f = 0; f < EWImporterFieldCount; f++) {
		[formatterForField[f] release];
	}
	[super dealloc];
}


@end
