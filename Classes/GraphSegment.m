/*
 * GraphSegment.m
 * Created by Benjamin Ragheb on 9/15/13.
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
