//
//  BRTableValueRow.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/26/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "BRTableValueRow.h"


@implementation BRTableValueRow


@synthesize key, formatter, disabled;


- (void)dealloc {
	self.object = nil;
	[key release];
	[formatter release];
	[super dealloc];
}


- (void)setObject:(id)newObject {
	if (self.object == newObject) return;
	
	id oldObject = self.object;
	if (oldObject != nil && self.key != nil) {
		[oldObject removeObserver:self forKeyPath:self.key];
	}
	[super setObject:newObject];
	if (newObject != nil && self.key != nil) {
		[newObject addObserver:self forKeyPath:self.key options:NSKeyValueObservingOptionNew context:NULL];
	}
}


- (void)setKey:(NSString *)newKey {
	if ([self.key isEqualToString:newKey]) return;

	NSString *oldKey = self.key;
	if (oldKey != nil && self.object != nil) {
		[self.object removeObserver:self forKeyPath:oldKey];
	}
	key = [newKey copy];
	[oldKey release];
	if (newKey != nil && self.object != nil) {
		[self.object addObserver:self forKeyPath:self.key options:NSKeyValueObservingOptionNew context:NULL];
	}
}


- (id)value {
	return [self.object valueForKey:self.key];
}


- (void)setValue:(id)newValue {
	[self.object setValue:newValue forKey:self.key];
}


- (NSString *)stringForValue:(id)value {
	if (self.formatter) {
		return [self.formatter stringForObjectValue:value];
	} else {
		return [value description];
	}
}


- (void)configureCell:(UITableViewCell *)cell {
	id value = self.value;
	if (value) {
		cell.text = [self stringForValue:value];
		cell.textColor = titleColor;
	} else {
		cell.text = title;
		cell.textColor = [UIColor grayColor];
	}
	cell.textAlignment = titleAlignment;
	cell.accessoryType = accessoryType;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// id value = [change objectForKey:NSKeyValueChangeNewKey];
	UITableViewCell *cell = [self cell];
	[self configureCell:cell];
	cell.selected = YES;
}


- (void)didSelect {
	[[self cell] setSelected:NO];
}


@end
