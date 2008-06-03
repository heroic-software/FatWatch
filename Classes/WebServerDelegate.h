//
//  WebServerDelegate.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/17/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MicroWebServer.h"

@interface WebServerDelegate : NSObject <MicroWebServerDelegate> {
	NSData *importData;
	BOOL importReplace;
}

@end
