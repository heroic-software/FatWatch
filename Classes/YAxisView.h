//
//  YAxisView.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 8/12/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphDrawingOperation.h"


@interface YAxisView : UIView {
	GraphViewParameters *p;
}
- (void)useParameters:(GraphViewParameters *)parameters;
@end
