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
#import "EWDateFormatter.h"
#import "EWExporter.h"


NSString * const kEWLastImportKey = @"EWLastImportDate";
NSString * const kEWLastExportKey = @"EWLastExportDate";


@interface EWImporter ()
- (void)continueImportToDatabase:(EWDatabase *)db;
@end


@implementation EWImporter


@synthesize delegate;
@synthesize deleteFirst;
@synthesize importing;
@synthesize columnNames;
@synthesize columnDefaults = importDefaults;


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
					[samples[c] addObject:value];
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
			NSString *name = [columnNames[c] lowercaseString];
			NSString *field = map[name];
			if (field) {
				defaults[field] = [NSNumber numberWithInt:(c+1)];
			}
		}
		
		[map release];
		
		importDefaults = [defaults copy];
		[defaults release];
	}
	return self;
}


- (void)autodetectFields {
    NSNumber *idx;
    
    idx = importDefaults[@"importDate"];
    if (idx) {
        [self setColumn:[idx integerValue] forField:EWImporterFieldDate];
        NSFormatter *df = [[EWISODateFormatter alloc] init];
        [self setFormatter:df forField:EWImporterFieldDate];
        [df release];
    }
    
    idx = importDefaults[@"importWeight"];
    if (idx) {
        [self setColumn:[idx integerValue] forField:EWImporterFieldWeight];
        NSFormatter *wf = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleExport];
        [self setFormatter:wf forField:EWImporterFieldWeight];
    }
    
    idx = importDefaults[@"importFat"];
    if (idx) {
        NSUInteger i = [idx unsignedIntegerValue];
        [self setColumn:i forField:EWImporterFieldFatRatio];
        float v = [[sampleValues[i] lastObject] floatValue];
        NSFormatter *ff;
        if (v == 0 || v > 1) {
            ff = EWFatFormatterAtIndex(0); // percentage (0%-100%)
        } else {
            ff = EWFatFormatterAtIndex(1); // ratio (0-1)
        }
        [self setFormatter:ff forField:EWImporterFieldFatRatio];
    }
    
    idx = importDefaults[@"importFlag0"];
    if (idx) {
        [self setColumn:[idx integerValue] forField:EWImporterFieldFlag0];
    }
    
    idx = importDefaults[@"importFlag1"];
    if (idx) {
        [self setColumn:[idx integerValue] forField:EWImporterFieldFlag1];
    }

    idx = importDefaults[@"importFlag2"];
    if (idx) {
        [self setColumn:[idx integerValue] forField:EWImporterFieldFlag2];
    }

    idx = importDefaults[@"importFlag3"];
    if (idx) {
        [self setColumn:[idx integerValue] forField:EWImporterFieldFlag3];
    }

    idx = importDefaults[@"importNote"];
    if (idx) {
        [self setColumn:[idx integerValue] forField:EWImporterFieldNote];
    }
}


- (NSDictionary *)infoForJavaScript {
	return @{@"columns": columnNames,
			@"samples": sampleValues,
			@"importDefaults": importDefaults};
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

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self continueImportToDatabase:db];
    });

	return YES;
}


- (id)valueForField:(EWImporterField)field inArray:(NSArray *)rowArray {
	NSUInteger i = columnForField[field] - 1;
	if (i >= [rowArray count]) return nil; // not enough data in row
	id value = rowArray[i];
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
    NSDate *updateDate = [NSDate date];
	NSUInteger rowCount = 0;
	NSUInteger importedCount = 0;
	
	if (self.deleteFirst) {
		[EWGoal deleteGoal];
		[db deleteAllData];
	}
	
	NSArray *rowArray;
	while ((rowArray = [reader readRow])) {
        @autoreleasepool {
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
            if (value) dd.note = (__bridge CFStringRef)value;
            
            [dbm setDBDay:&dd onDay:day];
            
            importedCount += 1;
            
            if ([updateDate timeIntervalSinceNow] < 0) {
                float progress = reader.progress;
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [delegate importer:self importProgress:progress];
                });
#if TARGET_IPHONE_SIMULATOR
                [NSThread sleepForTimeInterval:0.1];
#endif
                updateDate = [NSDate dateWithTimeIntervalSinceNow:0.05];
            }
        }
	}

    [db commitChanges];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        importing = NO;
        [delegate importer:self didImportNumberOfMeasurements:importedCount outOfNumberOfRows:rowCount];
    });
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
