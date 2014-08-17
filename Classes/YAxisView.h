//
//  YAxisView.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 8/12/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphDrawingOperation.h"


@class EWDatabase;


@interface YAxisView : UIView
@property (nonatomic,strong) EWDatabase *database;
- (void)useParameters:(GraphViewParameters *)parameters;
@end
