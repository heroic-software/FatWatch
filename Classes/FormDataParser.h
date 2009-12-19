//
//  FormDataParser.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/20/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MicroWebConnection;

@interface FormDataParser : NSObject {
	MicroWebConnection *connection;
	NSMutableDictionary *dictionary;
}
- (id)initWithData:(NSData *)data;
- (id)initWithConnection:(MicroWebConnection *)connection;
- (NSArray *)allKeys;
- (BOOL)hasKey:(NSString *)key;
- (NSData *)dataForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
@end
