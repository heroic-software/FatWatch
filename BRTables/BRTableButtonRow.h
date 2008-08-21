//
//  BRTableButtonRow.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/25/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTableRow.h"


/* For a button row that opens an URL, set target to nil and the object to an instance of NSURL. */


@interface BRTableButtonRow : BRTableRow {
	id target;
	SEL action;
	BOOL disabled;
	UIImage *image;
}
+ (BRTableButtonRow *)rowWithTitle:(NSString *)aTitle target:(id)aTarget action:(SEL)anAction;
@property (nonatomic,assign) id target;
@property (nonatomic) SEL action;
@property (nonatomic) BOOL disabled;
@property (nonatomic,retain) UIImage *image;
@end
