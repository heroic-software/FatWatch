//
//  EWImporter.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/21/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CSVReader;
@class EWImporter;


typedef enum {
	EWImporterFieldDate,
	EWImporterFieldWeight,
	EWImporterFieldFat,
	EWImporterFieldFlag0,
	EWImporterFieldFlag1,
	EWImporterFieldFlag2,
	EWImporterFieldFlag3,
	EWImporterFieldNote,
	EWImporterFieldCount
} EWImporterField;


@protocol EWImporterDelegate
- (void)importer:(EWImporter *)importer importProgress:(float)progress;
- (void)importer:(EWImporter *)importer didImportNumberOfMeasurements:(int)importedCount outOfNumberOfRows:(int)rowCount;
@end


@interface EWImporter : NSObject {
	CSVReader *reader;
	NSArray *columnNames;
	NSArray *sampleValues;
	NSDictionary *importDefaults;
	int columnForField[EWImporterFieldCount];
	NSFormatter *formatterForField[EWImporterFieldCount];
	id <EWImporterDelegate> delegate;
	BOOL deleteFirst;
	int rowCount, importedCount;
}
@property (nonatomic,assign) id <EWImporterDelegate> delegate;
@property (nonatomic) BOOL deleteFirst;
- (id)initWithData:(NSData *)aData encoding:(NSStringEncoding)anEncoding;
- (NSDictionary *)infoForJavaScript;
- (void)setColumn:(int)column forField:(EWImporterField)field;
- (void)setFormatter:(NSFormatter *)formatter forField:(EWImporterField)field;
- (BOOL)performImport;
- (void)continueImport;
- (void)concludeImport;
@end
