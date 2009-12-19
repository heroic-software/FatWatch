//
//  BRJSON.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/18/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (BRJSON)
- (void)appendJSONRepresentationToData:(NSMutableData *)json;
@end

@interface NSDictionary (BRJSON)
- (void)appendJSONRepresentationToData:(NSMutableData *)json;
@end

@interface NSArray (BRJSON)
- (void)appendJSONRepresentationToData:(NSMutableData *)json;
@end

@interface NSNumber (BRJSON)
- (void)appendJSONRepresentationToData:(NSMutableData *)json;
@end

@interface NSNull (BRJSON)
- (void)appendJSONRepresentationToData:(NSMutableData *)json;
@end
