//
//  CSVReader.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/17/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CSVReader : NSObject {
	NSData *data;
	NSUInteger dataIndex;
	NSNumberFormatter *floatFormatter;
	NSStringEncoding dataEncoding;
}
@property (nonatomic,retain) NSNumberFormatter *floatFormatter;
@property (nonatomic,readonly) float progress;
- (id)initWithData:(NSData *)csvData encoding:(NSStringEncoding)encoding;
- (BOOL)nextRow;
- (NSString *)readString;
- (float)readFloat;
- (BOOL)readBoolean;
@end
