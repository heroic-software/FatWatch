//
//  LogEntryViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 3/30/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "LogEntryViewController.h"
#import "EWDatabase.h"
#import "EWDBMonth.h"
#import "EWWeightFormatter.h"
#import "NSUserDefaults+EWAdditions.h"
#import "BRTextView.h"
#import "RungEntryViewController.h"
#import "EWFlagButton.h"


static const CGFloat kWeightPickerComponentWidth = 320 - 88;
static const float kDefaultWeight = 200.0f;
static const float kDefaultFatRatio = 0.25f;


enum {
	kModeWeightAndFat,
	kModeWeight,
	kModeNone
};


static UIViewAnimationOptions BRViewAnimationOptionForCurve(UIViewAnimationCurve curve)
{
    switch (curve) {
        case UIViewAnimationCurveEaseIn: return UIViewAnimationOptionCurveEaseIn;
        case UIViewAnimationCurveEaseInOut: return UIViewAnimationOptionCurveEaseInOut;
        case UIViewAnimationCurveEaseOut: return UIViewAnimationOptionCurveEaseOut;
        case UIViewAnimationCurveLinear: return UIViewAnimationOptionCurveLinear;
    }
    return 0;
}


@interface LogEntryViewController ()
- (void)keyboardWillShow:(NSNotification *)notice;
- (void)keyboardWillHide:(NSNotification *)notice;
@end


@implementation LogEntryViewController


+ (LogEntryViewController *)sharedController {
	static LogEntryViewController *controller = nil;
	
	if (controller == nil) {
		controller = [[LogEntryViewController alloc] init];
		[controller view];
	}
	
	return controller;
}


@synthesize weightControl;
@synthesize weightContainerView;
@synthesize weightPickerView;
@synthesize noWeightView;
@synthesize noteView;
@synthesize annotationContainerView;
@synthesize navigationBar;
@synthesize flag0Button;
@synthesize flag1Button;
@synthesize flag2Button;
@synthesize flag3Button;


- (id)init {
	if ((self = [super initWithNibName:@"LogEntryView" bundle:nil])) {
		scaleIncrement = [[NSUserDefaults standardUserDefaults] weightIncrement];
		weightFormatter = [[EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleDisplay] retain];
		NSAssert(scaleIncrement > 0, @"scale increment must be greater than 0");
	}
	return self;
}


- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
								  UIViewAutoresizingFlexibleHeight);
	
	flagButtons[0] = flag0Button;
	flagButtons[1] = flag1Button;
	flagButtons[2] = flag2Button;
	flagButtons[3] = flag3Button;
}


- (void)dealloc {
	[weightControl release];
	[weightContainerView release];
	[weightPickerView release];
	[noWeightView release];
	[flag0Button release];
	[flag1Button release];
	[flag2Button release];
	[flag3Button release];
	[noteView release];
	[annotationContainerView release];
	[navigationBar release];
	[weightFormatter release];
	[super dealloc];
}


- (NSInteger)pickerRowForWeight:(float)weight {
	return roundf(weight / scaleIncrement);
}


- (float)weightForPickerRow:(NSInteger)row {
	return row * scaleIncrement;
}


- (NSInteger)pickerRowForFatRatio:(float)ratio {
	return roundf(ratio * 1000.0f);
}


- (float)fatRatioForPickerRow:(NSInteger)row {
	return row / 1000.0f;
}


- (void)toggleWeight {
	if (weightMode == kModeWeight || weightMode == kModeWeightAndFat) {
		if ([weightPickerView superview] == nil) {
			[noWeightView removeFromSuperview];
			[weightContainerView addSubview:weightPickerView];
		}
		[weightPickerView reloadAllComponents];
		[weightPickerView selectRow:weightRow inComponent:0 animated:NO];
		if (weightMode == kModeWeightAndFat) {
			[weightPickerView selectRow:fatRow inComponent:1 animated:NO];
		}
	} else {
		if ([noWeightView superview] == nil) {
			[weightPickerView removeFromSuperview];
			[weightContainerView addSubview:noWeightView];
		}
	}
}


- (void)toggleWeightAction:(id)sender {
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionPush];
	[animation setSubtype:((weightMode < weightControl.selectedSegmentIndex) 
						   ? kCATransitionFromRight
						   : kCATransitionFromLeft)];

	weightMode = weightControl.selectedSegmentIndex;
	[self toggleWeight];
	
	[[weightContainerView layer] addAnimation:animation forKey:nil];
}


- (int)rung {
	return [[flag3Button titleForState:UIControlStateNormal] intValue];
}


- (void)setValue:(EWFlagValue)value forFlagIndex:(int)f {
	NSString *title;
	if ([[NSUserDefaults standardUserDefaults] isNumericFlag:f]) {
		if (value) {
			title = [NSString stringWithFormat:@"%d", value];
		} else {
			title = @"\xe2\x97\x86"; // LOZENGE
		}
	} else {
		title = @"";
	}
	[flagButtons[f] setTitle:title forState:UIControlStateNormal];
	flagButtons[f].selected = (value > 0);
}


- (void)setRung:(int)rung {
	[self setValue:rung forFlagIndex:3];
}


- (IBAction)toggleFlagButton:(UIButton *)sender {
	for (int f = 0; f < 4; f++) {
		if (flagButtons[f] == sender) {
			if ([[NSUserDefaults standardUserDefaults] isNumericFlag:f]) {
				RungEntryViewController *controller = [[RungEntryViewController alloc] init];
				controller.target = self;
				controller.key = @"rung";
				[self presentModalViewController:controller animated:YES];
				[controller release];
			} else {
				sender.selected = !sender.selected;
			}
			return;
		}
	}
}


- (IBAction)cancelAction:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)saveAction:(id)sender {
	EWDBDay dbd;
	
	if (weightMode == kModeWeight) {
		dbd.scaleWeight = [self weightForPickerRow:weightRow];
		dbd.scaleFatWeight = 0;
	} else if (weightMode == kModeWeightAndFat) {
		dbd.scaleWeight = [self weightForPickerRow:weightRow];
		dbd.scaleFatWeight = dbd.scaleWeight * [self fatRatioForPickerRow:fatRow];
	} else {
		dbd.scaleWeight = 0;
		dbd.scaleFatWeight = 0;
	}
	
	for (int f = 0; f < 4; f++) {
		if ([[NSUserDefaults standardUserDefaults] isNumericFlag:f]) {
			dbd.flags[f] = [[flagButtons[f] titleForState:UIControlStateNormal] intValue];
		} else {
			dbd.flags[f] = flagButtons[f].selected ? 1 : 0;
		}
	}
	
	dbd.note = CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)noteView.text);

	[monthData setDBDay:&dbd onDay:day];

	[monthData.database commitChanges];
	
	[self dismissModalViewControllerAnimated:YES];
}


- (float)chooseDefaultWeight {
	// no weight on this day, so get the trend on this day, searching earlier months if needed
	float weight = [monthData inputTrendOnDay:day];
	if (weight > 0) return weight;
	
	// there is no weight on or earlier than this day, so find first measurement
	weight = [monthData.database earliestWeight];
	if (weight > 0) return weight;

	// database is empty!
	return kDefaultWeight;
}


- (float)chooseDefaultFatWeight {
	// no fat today, search earlier
	float fatWeight = [monthData inputFatTrendOnDay:day];
	if (fatWeight > 0) return fatWeight;
	
	// nothing on or earlier, find first
	fatWeight = [monthData.database earliestFatWeight];
	if (fatWeight > 0) return fatWeight;
	
    // database is empty
	return 0;
}


- (void)layoutSubviewsWithoutKeyboard {
	CGFloat y = CGRectGetMaxY(weightContainerView.frame);
	CGRect newFrame = self.view.bounds;
	if (newFrame.origin.y == y) return;
	newFrame.origin.y = y;
	newFrame.size.height -= y;
	weightControl.alpha = 1;
	weightContainerView.alpha = 1;
	annotationContainerView.frame = newFrame;
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self
			   selector:@selector(keyboardWillShow:)
				   name:UIKeyboardWillShowNotification
				 object:nil];
	[center addObserver:self
			   selector:@selector(keyboardWillHide:)
				   name:UIKeyboardWillHideNotification
				 object:nil];
	
	[self layoutSubviewsWithoutKeyboard];
	[weightPickerView becomeFirstResponder];
	[[weightContainerView layer] removeAnimationForKey:kCATransition];
}


- (void)configureForDay:(EWDay)aDay dbMonth:(EWDBMonth *)aDBMonth {
	day = aDay;
	[monthData release];
	monthData = [aDBMonth retain];
	
	[self view]; // force the view to load
	
	NSDate *date = EWDateFromMonthAndDay(monthData.month, day);
	NSDateFormatter *titleFormatter = [[NSDateFormatter alloc] init];
	[titleFormatter setDateStyle:NSDateFormatterMediumStyle];
	[titleFormatter setTimeStyle:NSDateFormatterNoStyle];
	navigationBar.topItem.title = [titleFormatter stringFromDate:date];
	[titleFormatter release];
    
    BOOL isEmpty = ![monthData hasDataOnDay:day];
    BOOL isToday = (EWMonthDayToday() == EWMonthDayMake(monthData.month, day));
    
    const EWDBDay *dd = [monthData getDBDayOnDay:day];

    // 1/5: Set Mode
    
    if (isEmpty && isToday) {
        // This is a weigh-in, show pickers based on previous entry:
        if ([monthData didRecordFatBeforeDay:day]) {
            weightMode = kModeWeightAndFat;
        } else {
            weightMode = kModeWeight;
        }
    } else {
        // This is an edit, show pickers based on data
        if (dd->scaleFatWeight > 0) {
            weightMode = kModeWeightAndFat;
        } else if (dd->scaleWeight > 0) {
            weightMode = kModeWeight;
        } else {
            weightMode = kModeNone;
        }
    }
    
    // 2/5: Set Weight Picker
    
    float weight = [self chooseDefaultWeight];
    weightRow = [self pickerRowForWeight:weight];
    
    // 3/5: Set Fat Picker
    
    float fatWeight = [self chooseDefaultFatWeight];
    if (fatWeight > 0) {
        fatRow = [self pickerRowForFatRatio:(fatWeight / weight)];
    } else {
        fatRow = [self pickerRowForFatRatio:kDefaultFatRatio];
    }
    
    // 4/5: Set Marks
    
	for (int f = 0; f < 4; f++) {
		[self setValue:dd->flags[f] forFlagIndex:f];
	}

    // 5/5: Set Note
    
    noteView.text = (NSString *)dd->note;

    // Update views

	weightControl.selectedSegmentIndex = weightMode;
	[self toggleWeight];
}


- (void)prepareAnimationsWithUserInfo:(NSDictionary *)userInfo {
	NSNumber *value;
	
	value = userInfo[UIKeyboardAnimationCurveUserInfoKey];
	[UIView setAnimationCurve:[value intValue]];
	
	value = userInfo[UIKeyboardAnimationDurationUserInfoKey];
	[UIView setAnimationDuration:[value doubleValue]];
}


- (void)animateWithKeyboardInfo:(NSDictionary *)info
                     animations:(void (^)(void))animations {
    NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [info[UIKeyboardAnimationCurveUserInfoKey] intValue];
    UIViewAnimationOptions options = BRViewAnimationOptionForCurve(curve);
    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:animations
                     completion:NULL];
}


- (void)keyboardWillShow:(NSNotification *)notice {
	NSDictionary *info = [notice userInfo];

	CGRect kbFrameScreen = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGRect kbFrameWindow = [self.view.window convertRect:kbFrameScreen fromWindow:nil];
	CGRect kbFrame = [self.view convertRect:kbFrameWindow fromView:nil];

	CGFloat navHeight = CGRectGetHeight(self.navigationBar.bounds);
	
	CGRect newFrame = self.view.bounds;
	newFrame.origin.y += navHeight;
	newFrame.size.height -= (navHeight + CGRectGetHeight(kbFrame));

    [self animateWithKeyboardInfo:info animations:^(void) {
        weightControl.alpha = 0;
        weightContainerView.alpha = 0;
        annotationContainerView.frame = newFrame;
    }];
}


- (void)keyboardWillHide:(NSNotification *)notice {
    [self animateWithKeyboardInfo:[notice userInfo] animations:^(void) {
        [self layoutSubviewsWithoutKeyboard];
    }];
}


- (void)viewWillDisappear:(BOOL)animated {
	[noteView resignFirstResponder];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewWillDisappear:animated];
}


#pragma mark UITextFieldDelegate (Optional)


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return [textField resignFirstResponder];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if ([text length] > 0 && [text characterAtIndex:0] == '\n') {
		[textView resignFirstResponder];
		return NO;
	}
	return YES;
}


#pragma mark UIPickerViewDelegate (Required)


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	if (weightMode == kModeWeight) {
		return 1;
	} else {
		return 2;
	}
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if (component == 0) {
		return [self pickerRowForWeight:500.0f];
	} else {
		return [self pickerRowForFatRatio:1.0f];
	}
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if (component == 0) {
		weightRow = row;
	} else {
		fatRow = row;
	}
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel *label;

	if ([view isKindOfClass:[UILabel class]]) {
		label = (UILabel *)view;
	} else {
        CGRect frame = CGRectZero;
        frame.size = [pickerView rowSizeForComponent:component];
		label = [[[UILabel alloc] initWithFrame:frame] autorelease];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.textAlignment = UITextAlignmentCenter;
		label.textColor = [UIColor blackColor];
        label.opaque = NO;
		label.font = [UIFont boldSystemFontOfSize:20];
	}
	
	if (component == 0) {
		float weight = [self weightForPickerRow:row];
		label.text = [weightFormatter stringForFloat:weight];
		label.backgroundColor = [EWWeightFormatter colorForWeight:weight alpha:0.4f];
	} else {
		float fatRatio = [self fatRatioForPickerRow:row];
		label.text = [NSString stringWithFormat:@"%0.1f%%", (100.0f * fatRatio)];
		label.backgroundColor = nil;
	}

	return label;
}


@end
