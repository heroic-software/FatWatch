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
#endif


#if DEBUG_LAUNCH_STAGE_ENABLED

@interface DebugViewController : UIViewController 
@end

#endif // DEBUG_LAUNCH_STAGE_ENABLED
