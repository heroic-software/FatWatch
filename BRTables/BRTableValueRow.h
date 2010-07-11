//
//  BRTableValueRow.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTableRow.h"


@protocol BRColorFormatter
- (UIColor *)colorForObjectValue:(id)anObject;
@end


@interface BRTableValueRow : BRTableRow {
	NSString *key;
	NSFormatter	*formatter;
	id <BRColorFormatter> textColorFormatter;
	id <BRColorFormatter> backgroundColorFormatter;
	BOOL disabled;
	NSString *valueDescription;
}
@property (nonatomic,retain) NSString *key;
@property (nonatomic,retain) NSFormatter *formatter;
@property (nonatomic,retain) id <BRColorFormatter> textColorFormatter;
@property (nonatomic,retain) id <BRColorFormatter> backgroundColorFormatter;
@property (nonatomic) BOOL disabled;
@property (nonatomic,retain) id value;
@property (nonatomic,retain) NSString *valueDescription;
@end
