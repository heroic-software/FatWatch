/*
 * DataSearch.m
 * Created by Benjamin Ragheb on 5/15/08.
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

#import "DataSearch.h"

// An implementation of the Boyer-Moore-Horspool algorithm
// <http://en.wikipedia.org/wiki/Boyer-Moore-Horspool_algorithm>

@implementation DataSearch
{
	NSData *haystack;
	NSData *needle;
	NSUInteger skipTable[256];
	NSUInteger haystackStartIndex;
}

- (id)initWithData:(NSData *)haystackData patternData:(NSData *)needleData {
	if ((self = [super init])) {
		NSAssert([needleData length], @"pattern must be at least one byte");
		
		haystack = haystackData;
		needle = needleData;

		const unsigned char *needleBytes = [needle bytes];
		const NSUInteger needleLength = [needle length];
		const NSUInteger needleLastIndex = needleLength - 1;

		// by default, if we hit a character that isn't in the pattern, we advance the length of the pattern
		for (NSUInteger i = 0; i < 256; i++) {
			skipTable[i] = needleLength;
		}
		
		// if the character is in the pattern, we only jump ahead so that it may match
		for (NSUInteger i = 0; i < needleLastIndex; i++) {
			skipTable[needleBytes[i]] = needleLastIndex - i;
		}
	}
	return self;
}




- (NSUInteger)nextIndex {
	const unsigned char *haystackBytes = [haystack bytes];
	const unsigned char *needleBytes = [needle bytes];
	const NSUInteger needleLastIndex = [needle length] - 1;
	const NSUInteger haystackLength = [haystack length];

	NSUInteger haystackIndex = haystackStartIndex + needleLastIndex;
	while (haystackIndex < haystackLength) {
		NSUInteger matchIndex = haystackIndex;
		NSUInteger needleIndex = needleLastIndex;
		while (haystackBytes[matchIndex] == needleBytes[needleIndex]) {
			if (needleIndex == 0) {
				haystackStartIndex = matchIndex + 1;
				return matchIndex;
			}
			matchIndex--;
			needleIndex--;
		}
		unsigned char c = haystackBytes[haystackIndex];
		haystackIndex += skipTable[c];
	}
	
	haystackStartIndex = haystackLength;
	return NSNotFound;
}


@end
