//
//  EWTrendButton.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/24/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
	EWTrendButtonAccessoryNone,
	EWTrendButtonAccessoryDisclosureIndicator,
	EWTrendButtonAccessoryToggle
} EWTrendButtonAccessoryType;


@interface EWTrendButton : UIControl
@property (nonatomic) EWTrendButtonAccessoryType accessoryType;
- (void)setText:(NSString *)text forPart:(int)part;
- (void)setTextColor:(UIColor *)color forPart:(int)part;
- (void)setFont:(UIFont *)font forPart:(int)part;
@end
