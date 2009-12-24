//
//  RungEntryViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/21/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RungEntryViewController : UIViewController {
	UISegmentedControl *rungControl;
	UILabel *rungLabel;
	UILabel *ladderLabel;
	UILabel *bendLabel;
	UILabel *sitUpLabel;
	UILabel *legLiftLabel;
	UILabel *pushUpLabel;
	UILabel *stepsLabel;
	UILabel *setsLabel;
	UILabel *extraStepsLabel;
	int rung;
	id target;
	NSString *key;
}
@property (nonatomic,assign) id target;
@property (nonatomic,copy) NSString *key;
@property (nonatomic,retain) IBOutlet UISegmentedControl *rungControl;
@property (nonatomic,retain) IBOutlet UILabel *rungLabel;
@property (nonatomic,retain) IBOutlet UILabel *ladderLabel;
@property (nonatomic,retain) IBOutlet UILabel *bendLabel;
@property (nonatomic,retain) IBOutlet UILabel *sitUpLabel;
@property (nonatomic,retain) IBOutlet UILabel *legLiftLabel;
@property (nonatomic,retain) IBOutlet UILabel *pushUpLabel;
@property (nonatomic,retain) IBOutlet UILabel *stepsLabel;
@property (nonatomic,retain) IBOutlet UILabel *setsLabel;
@property (nonatomic,retain) IBOutlet UILabel *extraStepsLabel;
- (IBAction)changeRung;
- (IBAction)dismiss;
- (IBAction)clearRungAndDismiss;
- (IBAction)saveRungAndDismiss;
@end
