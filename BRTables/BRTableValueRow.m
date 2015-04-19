/*
 * BRTableValueRow.m
 * Created by Benjamin Ragheb on 7/26/08.
 * Copyright 2015 Heroic Software Inc
 *
 * This file is part of FatWatch.
 *
 * FatWatch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FatWatch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "BRTableValueRow.h"


@implementation BRTableValueRow
{
	NSString *key;
	NSFormatter	*formatter;
	id <BRColorFormatter> textColorFormatter;
	id <BRColorFormatter> backgroundColorFormatter;
	BOOL disabled;
	NSString *valueDescription;
}

@synthesize key;
@synthesize formatter;
@synthesize disabled;
@synthesize textColorFormatter;
@synthesize backgroundColorFormatter;
@synthesize valueDescription;


- (void)dealloc {
	self.object = nil;
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

	NSString *oldKey = key;
	if (oldKey != nil && self.object != nil) {
		[self.object removeObserver:self forKeyPath:oldKey];
	}
	key = [newKey copy];
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
	[super configureCell:cell];
	id value = self.value;
	if (value) {
		cell.textLabel.text = [self stringForValue:value];
		cell.textLabel.textColor = self.titleColor;
	} else {
		cell.textLabel.text = self.title;
		cell.textLabel.textColor = [UIColor grayColor];
	}
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// id value = [change objectForKey:NSKeyValueChangeNewKey];
	UITableViewCell *cell = [self cell];
	[self configureCell:cell];
	[cell setHighlighted:YES animated:YES];
}


- (void)didSelect {
	[self deselectAnimated:YES];
}


@end
