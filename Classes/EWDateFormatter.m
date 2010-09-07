//
//  EWDateFormatter.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 2/10/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "EWDateFormatter.h"
#import "EWDate.h"


@implementation EWDateFormatter

+ (NSFormatter *)formatterWithDateFormat:(NSString *)format {
	if ([format isEqualToString:@"y-MM-dd"]) {
		return [[[EWISODateFormatter alloc] init] autorelease];
	} else {
		return [[[EWDateFormatter alloc] initWithDateFormat:format] autorelease];
	}
}

- (id)initWithDateFormat:(NSString *)format {
	if ((self = [super init])) {
		realFormatter = [[NSDateFormatter alloc] init];
		[realFormatter setDateFormat:format];
	}
	return self;
}

- (NSString *)stringForObjectValue:(id)obj {
	NSDate *date = EWDateFromMonthDay([obj intValue]);
	return [realFormatter stringFromDate:date];
}

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error {
	NSDate *date = nil;
	if ([realFormatter getObjectValue:&date forString:string errorDescription:error]) {
		*obj = [NSNumber numberWithInt:EWMonthDayFromDate(date)];
		return YES;
	}
	return NO;
}

- (void)dealloc {
	[realFormatter release];
	[super dealloc];
}

@end


@implementation EWISODateFormatter

- (NSString *)stringForObjectValue:(id)obj {
	EWMonthDay md = [obj intValue];
	EWMonth m = EWMonthDayGetMonth(md);
	EWDay d = EWMonthDayGetDay(md);
	NSInteger year = (24012 + m) / 12; 	// 0 = 2001-01
	NSInteger m0 = (m % 12) + 1;
	if (m0 < 1) m0 += 12;
	return [NSString stringWithFormat:@"%04d-%02d-%02d", year, m0, d];
}

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error {
	NSScanner *scanner = [[NSScanner alloc] initWithString:string];
	NSInteger year, month, day;
	
	NSCharacterSet *digitSet = [NSCharacterSet decimalDigitCharacterSet];
	
	BOOL success = ([scanner scanInteger:&year] &&
					[scanner scanUpToCharactersFromSet:digitSet intoString:nil] &&
					[scanner scanInteger:&month] &&
					[scanner scanUpToCharactersFromSet:digitSet intoString:nil] &&
					[scanner scanInteger:&day]);
	
	[scanner release];
	
	if (success) {
		EWMonth m = ((year - 2001) * 12) + (month - 1);
		*obj = [NSNumber numberWithInt:EWMonthDayMake(m, day)];
	} else {
		*error = [NSError errorWithDomain:@"EWDate" code:1 userInfo:nil];
	}

	return success;
}

@end
