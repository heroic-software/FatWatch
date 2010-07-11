//
//  BRPickerViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 7/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BRTableValueRow;
@class BRTableNumberPickerRow;
@class BRTableDatePickerRow;


@interface BRPickerViewController : UIViewController {
	BRTableValueRow *tableRow;
}
- (id)initWithRow:(BRTableValueRow *)aRow;
@end


@interface BRNumberPickerViewController : BRPickerViewController <UIPickerViewDelegate, UIPickerViewDataSource>{
}
@end


@interface BRDatePickerViewController : BRPickerViewController {
}
@end


