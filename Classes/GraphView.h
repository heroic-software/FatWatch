//
//  GraphView.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/16/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWDate.h"


typedef struct {
	float minWeight;
	float maxWeight;
	float scaleX;
	float scaleY;
} GraphViewParameters;


@interface GraphView : UIView {
	GraphViewParameters *p;
	EWMonth month;
}
- (id)initWithParameters:(GraphViewParameters *)parameters;
- (void)setMonth:(EWMonth)m;
@end
