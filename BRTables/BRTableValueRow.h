//
//  BRTableValueRow.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTableRow.h"


@interface BRTableValueRow : BRTableRow {
	NSString *key;
	NSFormatter	*formatter;
	UITableViewCellAccessoryType accessoryType;
}
@property (nonatomic,retain) NSString *key;
@property (nonatomic,retain) NSFormatter *formatter;
@property (nonatomic) UITableViewCellAccessoryType accessoryType;
@end
