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
#import "LogTableViewCell.h"
#import "EWWeightFormatter.h"
#import "NSUserDefaults+EWAdditions.h"
#import "EWFlagButton.h"


enum {
	kAuxiliaryInfoTypeVariance,
	kAuxiliaryInfoTypeBMI,
	kAuxiliaryInfoTypeFatPercent,
	kAuxiliaryInfoTypeFatWeight,
	kAuxiliaryInfoTypeTrend,
	kNumberOfAuxiliaryInfoTypes
};


NSString * const kLogCellReuseIdentifier = @"LogCell";

static NSString * const AuxiliaryInfoTypeKey = @"AuxiliaryInfoType";
static NSString * const AuxiliaryInfoTypeChangedNotification = @"AuxiliaryInfoTypeChanged";

static NSString * const kLozengeString = @"\xe2\x97\x86"; // LOZENGE
static NSString * const kEmDashString = @"\xe2\x80\x95"; // HORIZONTAL BAR

static NSInteger gAuxiliaryInfoType;



@implementation LogTableViewCell


+ (void)initialize {
	gAuxiliaryInfoType = [[NSUserDefaults standardUserDefaults] integerForKey:AuxiliaryInfoTypeKey];
}


+ (BOOL)isAuxiliaryInfoTypeEnabled:(NSInteger)infoType {
	switch (infoType) {
		case kAuxiliaryInfoTypeBMI:
			return [[NSUserDefaults standardUserDefaults] isBMIEnabled];
		default:
			return YES;
	}
}


+ (NSInteger)auxiliaryInfoType {
	if (![self isAuxiliaryInfoTypeEnabled:gAuxiliaryInfoType]) {
		[self setAuxiliaryInfoType:kAuxiliaryInfoTypeVariance];
	}
	return gAuxiliaryInfoType;
}


+ (void)setAuxiliaryInfoType:(NSInteger)infoType {
	gAuxiliaryInfoType = infoType;
	[[NSUserDefaults standardUserDefaults] setInteger:gAuxiliaryInfoType forKey:AuxiliaryInfoTypeKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:AuxiliaryInfoTypeChangedNotification object:nil];
}


+ (NSString *)nameForAuxiliaryInfoType:(NSInteger)infoType {
	switch (infoType) {
		case kAuxiliaryInfoTypeVariance: return @"Weight & Variance";
		case kAuxiliaryInfoTypeBMI: return @"Weight & BMI";
		case kAuxiliaryInfoTypeFatPercent: return @"Body Fat Percentage";
		case kAuxiliaryInfoTypeFatWeight: return @"Body Fat Weight";
		case kAuxiliaryInfoTypeTrend: return @"Weight & Trend";
		default: return @"Unknown";
	}
}


+ (NSArray *)availableAuxiliaryInfoTypes {
	NSMutableArray *array = [NSMutableArray array];
	for (NSInteger t = 0; t < kNumberOfAuxiliaryInfoTypes; t++) {
		if ([self isAuxiliaryInfoTypeEnabled:t]) {
			[array addObject:[NSNumber numberWithInt:t]];
		}
	}
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
		
		highlightWeekends = [[NSUserDefaults standardUserDefaults] highlightWeekends];
		
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
	logContentView.dd = [monthData getDBDayOnDay:day];
	
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


- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		weightFormatter = [[EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleDisplay] retain];
		varianceFormatter = [[EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleVariance] retain];
		[self bmiStatusDidChange:nil];
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver:self selector:@selector(bmiStatusDidChange:) name:EWBMIStatusDidChangeNotification object:nil];
		[center addObserver:self selector:@selector(flagIconDidChange:) name:EWFlagButtonIconDidChangeNotification object:nil];
	}
	return self;
}


- (void)bmiStatusDidChange:(NSNotification *)notification {
	[bmiFormatter release];
	if ([[NSUserDefaults standardUserDefaults] isBMIEnabled]) {
		bmiFormatter = [[EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleBMI] retain];
	} else {
		bmiFormatter = nil;
	}
}


- (void)flagIconDidChange:(NSNotification *)notification {
	[self setNeedsDisplay];
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[weightFormatter release];
	[varianceFormatter release];
	[bmiFormatter release];
	[super dealloc];
}


- (void)drawRect:(CGRect)rect {
	CGFloat cellWidth = CGRectGetWidth(self.bounds);
	CGFloat cellHeight = CGRectGetHeight(self.bounds);
	
	static const CGFloat dateWidth = 34;
	
	const CGFloat weightX = dateWidth + 4;
	static const CGFloat weightWidth = 133;
	
	const CGFloat auxiliaryX = weightX + weightWidth + 4;
	static const CGFloat auxiliaryWidth = 117;
	
	static const CGFloat numberRowY = 13;
	static const CGFloat numberRowHeight = 24;
	
	static const CGFloat flagWidth = 20;
	const CGFloat flagX = cellWidth - flagWidth;

	const CGFloat noteX = dateWidth + 4;
	const CGFloat noteWidth = cellWidth - noteX - flagWidth;
	const CGFloat noteHeight = 16;
	const CGFloat noteY = cellHeight - noteHeight;
	
	BOOL inverse = cell.highlighted || cell.selected;
	
	if (day) {
		if (inverse) {
			[[UIColor whiteColor] set];
		} else {
			if (highlightDate) {
				[[UIColor colorWithWhite:0.75f alpha:1] set];
			} else {
				[cell.tableView.separatorColor set];
			}
			UIRectFill(CGRectMake(0, 0, dateWidth, cellHeight));
			[[UIColor blackColor] set];
		}
		[weekday drawInRect:CGRectMake(0, 5, dateWidth, 15)
				   withFont:[UIFont systemFontOfSize:12]
			  lineBreakMode:UILineBreakModeClip
				  alignment:UITextAlignmentCenter];
		[day drawInRect:CGRectMake(0, 21, dateWidth, 24)
			   withFont:[UIFont systemFontOfSize:20]
		  lineBreakMode:UILineBreakModeClip 
			  alignment:UITextAlignmentCenter];
	}
	
	if (dd->scaleWeight > 0) {
		NSString *mainInfoString;
		UIColor *mainInfoColor;

		switch (gAuxiliaryInfoType) {
			case kAuxiliaryInfoTypeFatWeight:
			{
				if (dd->scaleFatWeight > 0) {
					mainInfoString = [weightFormatter stringForFloat:dd->scaleFatWeight];
				} else {
					mainInfoString = kEmDashString;
				}
				mainInfoColor = [UIColor blackColor];
				break;
			}
			case kAuxiliaryInfoTypeTrend:
			{
				mainInfoString = [weightFormatter stringForFloat:dd->scaleWeight];
				float diff = dd->scaleWeight - dd->trendWeight;
				mainInfoColor = [BRColorPalette colorNamed:((diff > 0)
															? @"BadText"
															: @"GoodText")];
				break;
			}
			default:
			{
				mainInfoString = [weightFormatter stringForFloat:dd->scaleWeight];
				mainInfoColor = [UIColor blackColor];
				break;
			}
		}

		NSString *auxInfoString;
		UIColor *auxInfoColor;
		
		switch (gAuxiliaryInfoType) {
			case kAuxiliaryInfoTypeVariance:
			{
				float diff = dd->scaleWeight - dd->trendWeight;
				auxInfoColor = [BRColorPalette colorNamed:((diff > 0)
														   ? @"BadText"
														   : @"GoodText")];
				auxInfoString = [varianceFormatter stringForFloat:diff];
				break;
			}
			case kAuxiliaryInfoTypeTrend:
			{
				auxInfoColor = [UIColor darkGrayColor];
				auxInfoString = [weightFormatter stringForFloat:dd->trendWeight];
				break;
			}
			case kAuxiliaryInfoTypeBMI:
			{
				auxInfoColor = [EWWeightFormatter colorForWeight:dd->scaleWeight];
				auxInfoString = [bmiFormatter stringForFloat:dd->scaleWeight];
				break;
			}
			case kAuxiliaryInfoTypeFatPercent:
			{
				auxInfoColor = [UIColor darkGrayColor];
				if (dd->scaleFatWeight > 0) {
					NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
					[nf setNumberStyle:NSNumberFormatterPercentStyle];
					[nf setMaximumFractionDigits:1];
					[nf setMinimumFractionDigits:1];
					auxInfoString = [nf stringForFloat:(dd->scaleFatWeight / dd->scaleWeight)];
					[nf release];
				} else {
					auxInfoString = kEmDashString;
				}
				break;
			}
			case kAuxiliaryInfoTypeFatWeight:
			{
				if (dd->scaleFatWeight > 0) {
					float diff = dd->scaleFatWeight - dd->trendFatWeight;
					auxInfoColor = [BRColorPalette colorNamed:((diff > 0)
															   ? @"BadText"
															   : @"GoodText")];
					auxInfoString = [varianceFormatter stringForFloat:diff];
				} else {
					auxInfoColor = nil;
					auxInfoString = nil;
				}
				break;
			}
			default:
			{
				auxInfoColor = [UIColor blackColor];
				auxInfoString = [NSString stringWithFormat:@"¿%d?", gAuxiliaryInfoType];
				break;
			}
		}
		
		[mainInfoColor set];
		[mainInfoString drawInRect:CGRectMake(weightX, numberRowY, 
											  weightWidth, numberRowHeight)
						  withFont:[UIFont boldSystemFontOfSize:20]
					 lineBreakMode:UILineBreakModeClip
						 alignment:UITextAlignmentRight];
		[auxInfoColor set];
		[auxInfoString drawInRect:CGRectMake(auxiliaryX, numberRowY, 
											 auxiliaryWidth, numberRowHeight)
						 withFont:[UIFont systemFontOfSize:20]
					lineBreakMode:UILineBreakModeClip
						alignment:UITextAlignmentLeft];
	}
	
	if (dd->note) {
		[(inverse ? [UIColor lightGrayColor] : [UIColor darkGrayColor]) set];
		[dd->note drawInRect:CGRectMake(noteX, noteY, noteWidth, noteHeight)
					withFont:[UIFont systemFontOfSize:12]
			   lineBreakMode:UILineBreakModeMiddleTruncation
				   alignment:UITextAlignmentCenter];
	}
	
	{
		static const float flagMargin = 4.5f;
		CGRect flagRect = CGRectMake(flagX, flagMargin, flagWidth, cellHeight);

		flagRect.origin.x += roundf((flagWidth - 15) / 2);
		flagRect.size.width = 15;
		flagRect.size.height = 10;

		const CGFloat R = 5;
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL,    -R, -R);
		CGPathAddLineToPoint(path, NULL,  R, -R);
		CGPathAddLineToPoint(path, NULL,  R,  R);
		CGPathAddLineToPoint(path, NULL, -R,  R);
		CGPathCloseSubpath(path);
		
		CGContextRef ctxt = UIGraphicsGetCurrentContext();
		CGContextSetLineWidth(ctxt, 1);
		
		if (inverse) {
			CGContextSetRGBStrokeColor(ctxt, 1, 1, 1, 1);
		} else {
			CGContextSetRGBStrokeColor(ctxt, 0.8f, 0.8f, 0.8f, 1);
		}
		
		for (int f = 0; f < 4; f++) {
			NSString *key = [NSString stringWithFormat:@"Flag%d", f];
			[[BRColorPalette colorNamed:key] setFill];
			EWFlagValue value = dd->flags[f];
			
			if ([[NSUserDefaults standardUserDefaults] isNumericFlag:f]) {
				if (inverse) [[UIColor whiteColor] setFill];
				NSString *string;
				if (value) {
					string = [NSString stringWithFormat:@"%d", value];
				} else {
					string = kLozengeString;
				}
				[string drawInRect:flagRect 
						  withFont:[UIFont boldSystemFontOfSize:12]
					 lineBreakMode:UILineBreakModeClip
						 alignment:UITextAlignmentCenter];
			}
			else {
				CGContextSaveGState(ctxt);
				CGContextTranslateCTM(ctxt, CGRectGetMidX(flagRect), CGRectGetMidY(flagRect));
				CGContextAddPath(ctxt, path);
				CGContextDrawPath(ctxt, value ? kCGPathFillStroke : kCGPathStroke);
				CGContextRestoreGState(ctxt);
			}
			flagRect.origin.y += flagRect.size.height;
		}
	}
}


@end
