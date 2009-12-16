//
//  LogTableViewCell.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/29/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRColorPalette.h"
#import "EWDBMonth.h"
#import "EWDate.h"
#import "EWGoal.h"
#import "LogTableViewCell.h"
#import "WeightFormatters.h"


enum {
	kVarianceAuxiliaryInfoType,
	kBMIAuxiliaryInfoType,
	kFatPercentAuxiliaryInfoType,
	kFatWeightAuxiliaryInfoType,
	kLeanWeightAuxiliaryInfoType
};


NSString * const kLogCellReuseIdentifier = @"LogCell";

static NSString * const AuxiliaryInfoTypeChangedNotification = @"AuxiliaryInfoTypeChanged";

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


@synthesize tableView;
@synthesize logContentView;


- (id)init {
	if ([super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLogCellReuseIdentifier]) {
		logContentView = [[LogTableViewCellContentView alloc] initWithFrame:self.contentView.bounds];
		[self.contentView addSubview:logContentView];
		[logContentView release];
		
		logContentView.cell = self;
		logContentView.opaque = YES;
		logContentView.backgroundColor = [UIColor clearColor];
		logContentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | 
										   UIViewAutoresizingFlexibleHeight);
		
		highlightWeekends = [[NSUserDefaults standardUserDefaults] boolForKey:@"HighlightWeekends"];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(auxiliaryInfoTypeChanged:) name:AuxiliaryInfoTypeChangedNotification object:nil];
	}
	return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	[logContentView setNeedsDisplay];
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	[logContentView setNeedsDisplay];
}


- (void)auxiliaryInfoTypeChanged:(NSNotification *)notification {
	[logContentView setNeedsDisplay];
}


- (void)updateWithMonthData:(EWDBMonth *)monthData day:(EWDay)day {
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"EEE"];
	
	logContentView.day = [[NSNumber numberWithInt:day] description];
	logContentView.weekday = [df stringFromDate:EWDateFromMonthAndDay(monthData.month, day)];
	logContentView.highlightDate = (highlightWeekends && 
									EWMonthAndDayIsWeekend(monthData.month, day));
	logContentView.dd = [monthData getDBDay:day];
	
	[df release];

	[logContentView setNeedsDisplay];
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


@end


@implementation LogTableViewCellContentView


@synthesize cell;
@synthesize day;
@synthesize weekday;
@synthesize dd;
@synthesize highlightDate;


- (void)drawRect:(CGRect)rect {
	CGFloat cellWidth = CGRectGetWidth(self.bounds);
	CGFloat cellHeight = CGRectGetHeight(self.bounds);
	
	const CGFloat dateWidth = 34;
	const CGFloat weightX = dateWidth + 4;
	const CGFloat weightWidth = 133;
	const CGFloat auxiliaryX = weightX + weightWidth + 4;
	const CGFloat auxiliaryWidth = 117;
	const CGFloat numberRowY = 16;
	const CGFloat flagWidth = 20;
	const CGFloat flagX = cellWidth - flagWidth;
	const CGFloat noteX = dateWidth + 4;
	const CGFloat noteWidth = cellWidth - noteX - flagWidth;
	const CGFloat noteHeight = 15;
	const CGFloat noteY = cellHeight - noteHeight;
	
	BOOL inverse = cell.highlighted || cell.selected;
	
	if (day) {
		if (!inverse) {
			if (highlightDate) {
				[[UIColor colorWithWhite:0.8 alpha:1.0] set];
			} else {
				[cell.tableView.separatorColor set];
			}
			UIRectFill(CGRectMake(0, 0, dateWidth, cellHeight));
		}
		
		[(inverse ? [UIColor whiteColor] : [UIColor blackColor]) set];
		[weekday drawInRect:CGRectMake(0, 10, dateWidth, 15)
				   withFont:[UIFont systemFontOfSize:12]
			  lineBreakMode:UILineBreakModeClip
				  alignment:UITextAlignmentCenter];
		[day drawInRect:CGRectMake(0, 26, dateWidth, 24)
			   withFont:[UIFont systemFontOfSize:20]
		  lineBreakMode:UILineBreakModeClip 
			  alignment:UITextAlignmentCenter];
	}
	
	if (dd->scaleWeight > 0) {
		NSString *scaleWeight = [WeightFormatters stringForWeight:dd->scaleWeight];
		[scaleWeight drawInRect:CGRectMake(weightX, numberRowY, 
										   weightWidth, 24)
					   withFont:[UIFont boldSystemFontOfSize:20]
				  lineBreakMode:UILineBreakModeClip
					  alignment:UITextAlignmentRight];
		
		NSString *auxInfoString;
		UIColor *auxInfoColor;

		switch (gAuxiliaryInfoType) {
			case kVarianceAuxiliaryInfoType:
			{
				float weightDiff = dd->scaleWeight - dd->trendWeight;
				auxInfoColor = (weightDiff > 0
								? [BRColorPalette colorNamed:@"BadText"]
								: [BRColorPalette colorNamed:@"GoodText"]);
				auxInfoString = [WeightFormatters stringForVariance:weightDiff];
			}
				break;
			case kBMIAuxiliaryInfoType:
			{
				float bmi = [WeightFormatters bodyMassIndexForWeight:dd->scaleWeight];
				auxInfoColor = [WeightFormatters colorForBodyMassIndex:bmi];
				auxInfoString = [NSString stringWithFormat:@"%.1f", bmi];
			}
				break;
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
		
		[auxInfoColor set];
		[auxInfoString drawInRect:CGRectMake(auxiliaryX, numberRowY, 
											 auxiliaryWidth, 24)
						 withFont:[UIFont systemFontOfSize:20]
					lineBreakMode:UILineBreakModeClip
						alignment:UITextAlignmentLeft];
	}
	
	if (dd->note) {
		[(inverse ? [UIColor lightGrayColor] : [UIColor darkGrayColor]) set];
		[dd->note drawInRect:CGRectMake(noteX, noteY, noteWidth, 15)
					withFont:[UIFont systemFontOfSize:12]
			   lineBreakMode:UILineBreakModeMiddleTruncation
				   alignment:UITextAlignmentCenter];
	}
	
	{
		int f;
		CGRect rect = CGRectMake(flagX, 0, flagWidth, cellHeight);

		rect.origin.x += roundf((flagWidth - 15) / 2);
		rect.size.width = 15;
		rect.size.height = 15;

		CGContextRef ctxt = UIGraphicsGetCurrentContext();
		
		[(inverse ? [UIColor whiteColor] : [UIColor grayColor]) setStroke];

		for (f = 0; f < 4; f++) {
			CGRect dotRect = CGRectInset(rect, 2.25, 2.25);
			if (dd->flags & (1 << f)) {
				NSString *key = [NSString stringWithFormat:@"Flag%d", f+1];
				UIColor *color = [BRColorPalette colorNamed:key];
				[color setFill];
				CGContextFillRect(ctxt, dotRect);
			}
			CGContextStrokeRect(ctxt, dotRect);
			rect.origin.y += 15;
		}
		// draw text size 12 in last position if measuring exercise rungs
	}
	
	if (dd->scaleFat > 0 && !inverse) {
		CGRect fatRect = CGRectMake(dateWidth, 0, cellWidth-dateWidth, 4);
		fatRect.size.width *= dd->scaleFat;
		[cell.tableView.separatorColor set];
		UIRectFill(fatRect);
	}
}


@end
