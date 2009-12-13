//
//  LogTableViewCell.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "LogTableViewCell.h"
#import "EWDate.h"
#import "EWDBMonth.h"
#import "WeightFormatters.h"
#import "EWGoal.h"


NSString * const kLogCellReuseIdentifier = @"LogCell";
static NSString * const AuxiliaryInfoTypeChangedNotification = @"AuxiliaryInfoTypeChanged";


enum {
	kVarianceAuxiliaryInfoType,
	kBMIAuxiliaryInfoType,
	kFatPercentAuxiliaryInfoType,
	kFatWeightAuxiliaryInfoType,
	kLeanWeightAuxiliaryInfoType
};


@interface LogTableViewCellContentView : UIView {
	NSString *day;
	NSString *weekday;
	struct EWDBDay *dd;
}
@property (nonatomic,retain) NSString *day;
@property (nonatomic,retain) NSString *weekday;
@property (nonatomic) struct EWDBDay *dd;
@end


static NSInteger gAuxiliaryInfoType = kVarianceAuxiliaryInfoType;


@implementation LogTableViewCell


+ (NSInteger)auxiliaryInfoType {
	return gAuxiliaryInfoType;
}


+ (void)setAuxiliaryInfoType:(NSInteger)infoType {
	gAuxiliaryInfoType = infoType;
	[[NSNotificationCenter defaultCenter] postNotificationName:AuxiliaryInfoTypeChangedNotification object:nil];
}


+ (NSString *)nameForAuxiliaryInfoType:(NSInteger)infoType {
	switch (infoType) {
		case kVarianceAuxiliaryInfoType: return @"Variance";
		case kBMIAuxiliaryInfoType: return @"BMI";
		case kFatPercentAuxiliaryInfoType: return @"Body Fat Percentage";
		case kFatWeightAuxiliaryInfoType: return @"Body Fat Weight";
		case kLeanWeightAuxiliaryInfoType: return @"Body Lean Weight";
		default: return @"Unknown";
	}
}


+ (NSArray *)availableAuxiliaryInfoTypes {
	NSMutableArray *array = [NSMutableArray array];
	[array addObject:[NSNumber numberWithInt:kVarianceAuxiliaryInfoType]];
	if ([EWGoal isBMIEnabled]) {
		[array addObject:[NSNumber numberWithInt:kBMIAuxiliaryInfoType]];
	}
	[array addObject:[NSNumber numberWithInt:kFatPercentAuxiliaryInfoType]];
	[array addObject:[NSNumber numberWithInt:kFatWeightAuxiliaryInfoType]];
	[array addObject:[NSNumber numberWithInt:kLeanWeightAuxiliaryInfoType]];
	return array;
}


- (id)init {
	if ([super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLogCellReuseIdentifier]) {
		logContentView = [[LogTableViewCellContentView alloc] initWithFrame:self.contentView.bounds];
		logContentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | 
										   UIViewAutoresizingFlexibleHeight);
		logContentView.opaque = YES;
		logContentView.tag = kLogContentViewTag;
		[self.contentView addSubview:logContentView];
		[logContentView release];
		
		highlightWeekends = [[NSUserDefaults standardUserDefaults] boolForKey:@"HighlightWeekends"];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(auxiliaryInfoTypeChanged:) name:AuxiliaryInfoTypeChangedNotification object:nil];
	}
	return self;
}


- (void)auxiliaryInfoTypeChanged:(NSNotification *)notification {
	[logContentView setNeedsDisplay];
}


- (void)updateWithMonthData:(EWDBMonth *)monthData day:(EWDay)day {
	logContentView.day = [[NSNumber numberWithInt:day] description];

	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"EEE"];
	logContentView.weekday = [df stringFromDate:EWDateFromMonthAndDay(monthData.month, day)];
	[df release];
	
	if (highlightWeekends && EWMonthAndDayIsWeekend(monthData.month, day)) {
		logContentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
	} else {
		logContentView.backgroundColor = [UIColor whiteColor];
	}

	logContentView.dd = [monthData getDBDay:day];
	
	[logContentView setNeedsDisplay];
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


@end


@implementation LogTableViewCellContentView


@synthesize day;
@synthesize weekday;
@synthesize dd;


- (void)drawRect:(CGRect)rect {
	const CGFloat topMargin = 9;
	const CGFloat numberRowHeight = 33;
	const CGFloat dayRight = 34;
	const CGFloat scaleWeightRight = 174;
	const CGFloat trendDeltaLeft = 178;
	const CGFloat noteY = 28;
	const CGFloat noteRowHeight = 15;
	const CGFloat noteLeft = dayRight + 4;
	const CGFloat noteRight = noteLeft;
	
	CGFloat cellWidth = CGRectGetWidth(self.bounds);
	
	if (day) {
		[[UIColor blackColor] setFill];
		CGRect dayRect = CGRectMake(0, topMargin, dayRight, numberRowHeight);
		[day drawInRect:dayRect
			   withFont:[UIFont systemFontOfSize:20]
		  lineBreakMode:UILineBreakModeClip 
			  alignment:UITextAlignmentRight];
		CGRect weekdayRect = CGRectMake(0, noteY, dayRight, noteRowHeight);
		[weekday drawInRect:weekdayRect
				   withFont:[UIFont systemFontOfSize:12]
			  lineBreakMode:UILineBreakModeClip
				  alignment:UITextAlignmentRight];
	}
	
	if (dd->scaleWeight > 0) {
		NSString *scaleWeight = [WeightFormatters stringForWeight:dd->scaleWeight];
		CGRect scaleWeightRect = CGRectMake(0, topMargin, scaleWeightRight, numberRowHeight);
		[scaleWeight drawInRect:scaleWeightRect
					   withFont:[UIFont boldSystemFontOfSize:20]
				  lineBreakMode:UILineBreakModeClip
					  alignment:UITextAlignmentRight];
		
		NSString *auxInfoString;
		UIColor *auxInfoColor;
		CGRect auxInfoRect = CGRectMake(trendDeltaLeft, 
										topMargin, 
										cellWidth-trendDeltaLeft, 
										numberRowHeight);
		
		switch (gAuxiliaryInfoType) {
			case kVarianceAuxiliaryInfoType: {
				float weightDiff = dd->scaleWeight - dd->trendWeight;
				auxInfoColor = (weightDiff > 0
								? [WeightFormatters badColor]
								: [WeightFormatters goodColor]);
				auxInfoString = [WeightFormatters stringForVariance:weightDiff];
				break;
			}
			case kBMIAuxiliaryInfoType: {
				float bmi = [WeightFormatters bodyMassIndexForWeight:dd->scaleWeight];
				auxInfoColor = [WeightFormatters colorForBodyMassIndex:bmi];
				auxInfoString = [NSString stringWithFormat:@"%.1f", bmi];
				break;
			}
			case kFatPercentAuxiliaryInfoType:
				auxInfoColor = [UIColor darkGrayColor];
				if (dd->scaleFat > 0) {
					auxInfoString = [NSString stringWithFormat:@"%.1f%%", 
									 100.0f * dd->scaleFat];
				} else {
					auxInfoString = @"—";
				}
				break;
			case kFatWeightAuxiliaryInfoType:
				auxInfoColor = [UIColor darkGrayColor];
				if (dd->scaleFat > 0) {
					auxInfoString = [WeightFormatters stringForWeight:
									 (dd->scaleWeight * dd->scaleFat)];
				} else {
					auxInfoString = @"—";
				}
				break;
			case kLeanWeightAuxiliaryInfoType:
				auxInfoColor = [UIColor darkGrayColor];
				if (dd->scaleFat > 0) {
					auxInfoString = [WeightFormatters stringForWeight:
									 (dd->scaleWeight * (1 - dd->scaleFat))];
				} else {
					auxInfoString = @"—";
				}
				break;
			default:
				auxInfoColor = [UIColor blackColor];
				auxInfoString = [NSString stringWithFormat:@"¿%d?", gAuxiliaryInfoType];
				break;
		}
		
		[auxInfoColor setFill];
		[auxInfoString drawInRect:auxInfoRect
						 withFont:[UIFont systemFontOfSize:20]
					lineBreakMode:UILineBreakModeClip
						alignment:UITextAlignmentLeft];
	}
	
	if (dd->note) {
		[[UIColor darkGrayColor] setFill];
		CGRect noteRect = CGRectMake(noteLeft, 
									 noteY,
									 cellWidth-noteLeft-noteRight, 
									 noteRowHeight);
		[dd->note drawInRect:noteRect
					withFont:[UIFont systemFontOfSize:12]
			   lineBreakMode:UILineBreakModeTailTruncation
				   alignment:UITextAlignmentCenter];
	}
	
	if (dd->flags) {
		UIImage *checkImage = [UIImage imageNamed:@"Check.png"];
		[checkImage drawAtPoint:CGPointMake(cellWidth - 30, 10)];
	}
}


@end
