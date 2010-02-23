//
//  NSDataSearching.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/15/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "DataSearch.h"

// An implementation of the Boyer-Moore-Horspool algorithm
// <http://en.wikipedia.org/wiki/Boyer-Moore-Horspool_algorithm>

@implementation DataSearch

- (id)initWithData:(NSData *)haystackData patternData:(NSData *)needleData {
	if ([super init]) {
		NSAssert([needleData length], @"pattern must be at least one byte");
		
		haystack = [haystackData retain];
		needle = [needleData retain];

		const unsigned char *needleBytes = [needle bytes];
		const NSUInteger needleLength = [needle length];
		const NSUInteger needleLastIndex = needleLength - 1;

		// by default, if we hit a character that isn't in the pattern, we advance the length of the pattern
		for (int i = 0; i < 256; i++) {
			skipTable[i] = needleLength;
		}
		
		// if the character is in the pattern, we only jump ahead so that it may match
		for (int i = 0; i < needleLastIndex; i++) {
			skipTable[needleBytes[i]] = needleLastIndex - i;
		}
	}
	return self;
}


- (void)dealloc {
	[needle release];
	[haystack release];
	[super dealloc];
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
