//
//  BRColorPalette.h
//
//  Created by Benjamin Ragheb on 7/28/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BRColorPalette : NSObject {
	NSDictionary *colorDictionary;
}
+ (UIColor *)colorNamed:(NSString *)colorName;
+ (BRColorPalette *)sharedPalette;
- (void)addColorsFromFile:(NSString *)path;
- (void)removeAllColors;
- (UIColor *)colorNamed:(NSString *)colorName;
@end
