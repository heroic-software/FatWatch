//
//  FlagTabView.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/16/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FlagTabView : UIView {
	CGRect tabRect;
}
- (void)selectTabAroundRect:(CGRect)rect;
@end
