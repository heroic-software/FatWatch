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
	id __weak target;
	NSString *key;
}
@property (nonatomic,weak) id target;
@property (nonatomic,copy) NSString *key;
@property (nonatomic,strong) IBOutlet UISegmentedControl *rungControl;
@property (nonatomic,strong) IBOutlet UILabel *rungLabel;
@property (nonatomic,strong) IBOutlet UILabel *ladderLabel;
@property (nonatomic,strong) IBOutlet UILabel *bendLabel;
@property (nonatomic,strong) IBOutlet UILabel *sitUpLabel;
@property (nonatomic,strong) IBOutlet UILabel *legLiftLabel;
@property (nonatomic,strong) IBOutlet UILabel *pushUpLabel;
@property (nonatomic,strong) IBOutlet UILabel *stepsLabel;
@property (nonatomic,strong) IBOutlet UILabel *setsLabel;
@property (nonatomic,strong) IBOutlet UILabel *extraStepsLabel;
- (IBAction)changeRung;
- (IBAction)dismiss;
- (IBAction)clearRungAndDismiss;
- (IBAction)saveRungAndDismiss;
@end
