//
//  BRTableSwitchRow.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/25/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTableRow.h"


@interface BRTableSwitchRow : BRTableRow {
	NSString *key;
}
@property (nonatomic,retain) NSString *key;
@end
