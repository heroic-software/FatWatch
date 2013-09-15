//
//  GraphSegment.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 9/15/13.
//
//

#import "GraphSegment.h"

@implementation GraphSegment

- (void)dealloc
{
    [_view removeFromSuperview];
    [_view release];
    CGImageRelease(_imageRef);
    [_operation cancel];
    [_operation release];
    [super dealloc];
}

- (void)setImageRef:(CGImageRef)imageRef
{
    if (_imageRef != imageRef) {
        [self willChangeValueForKey:@"imageRef"];
        CGImageRef temp = _imageRef;
        _imageRef = CGImageRetain(imageRef);
        CGImageRelease(temp);
        [self didChangeValueForKey:@"imageRef"];
    }
}

@end
