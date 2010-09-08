//
//  DebugViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 9/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#if XCODE_CONFIGURATION_Debug

#define DEBUG_LAUNCH_STAGE_ENABLED 1

@interface DebugViewController : UIViewController {
	NSArray *profileNames;
}
@end

#endif // XCODE_CONFIGURATION
