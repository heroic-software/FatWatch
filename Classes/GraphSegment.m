//
//  GraphSegment.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 9/15/13.
//
//

#import "GraphSegment.h"
#import "GraphView.h"
#import "GraphDrawingOperation.h"


@implementation GraphSegment

@synthesize view = _view;
@synthesize operation = _operation;
@synthesize imageRef = _imageRef;

- (void)dealloc
{
    [_view removeFromSuperview];
    CGImageRelease(_imageRef);
    [_operation cancel];
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
