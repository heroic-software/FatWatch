//
//  BRTableValueRow.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTableValueRow.h"


@implementation BRTableValueRow


@synthesize key, formatter, accessoryType;


- (void)dealloc {
	[self.object removeObserver:self forKeyPath:self.key];
	[key release];
	[formatter release];
	[super dealloc];
}


- (void)didAddToSection:(BRTableSection *)aSection {
	[super didAddToSection:aSection];
	[self.object addObserver:self forKeyPath:self.key options:NSKeyValueObservingOptionNew context:NULL];
}


- (void)willRemoveFromSection {
	[self.object removeObserver:self forKeyPath:self.key];
}


- (NSString *)stringForValue:(id)value {
	if (formatter) {
		return [formatter stringForObjectValue:value];
	} else {
		return [value description];
	}
}


- (void)configureCell:(UITableViewCell *)cell {
	[super configureCell:cell];
	id value = [self.object valueForKey:self.key];
	cell.text = [self stringForValue:value];
	cell.accessoryType = accessoryType;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	id value = [change objectForKey:NSKeyValueChangeNewKey];
	UITableViewCell *cell = [self cell];
	cell.text = [self stringForValue:value];
	cell.selected = YES;
}


- (void)didSelect {
	[[self cell] setSelected:NO];
}


@end
