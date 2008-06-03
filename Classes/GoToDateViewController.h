//
//  GoToDateViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 6/2/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoToDateViewController : UIViewController {
	NSDate *initialDate;
	UIDatePicker *datePicker;
	id target;
	SEL action;
}
@property (nonatomic,assign) id target;
@property (nonatomic,assign) SEL action;
- (id)initWithDate:(NSDate *)date;
@end
