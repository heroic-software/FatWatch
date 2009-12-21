//
//  RungEntryViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/21/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "RungEntryViewController.h"


@implementation RungEntryViewController


@synthesize target;
@synthesize key;
@synthesize rungControl;
@synthesize rungLabel;
@synthesize ladderLabel;
@synthesize bendLabel;
@synthesize sitUpLabel;
@synthesize legLiftLabel;
@synthesize pushUpLabel;
@synthesize stepsLabel;
@synthesize countLabel;


- (id)init {
	return [self initWithNibName:@"RungEntryView" bundle:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)updateRungControls {
	rungLabel.text = [NSString stringWithFormat:@"Rung %d", rung];
	ladderLabel.text = (rung < 16) ? @"Introductory Ladder" : @"Lifetime Ladder";
	[rungControl setEnabled:(rung > 1) forSegmentAtIndex:0];
	[rungControl setEnabled:(rung < 48) forSegmentAtIndex:1];
}


- (void)viewWillAppear:(BOOL)animated {
	rung = [[target valueForKey:key] intValue];
	if (rung == 0) {
		rung = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastSavedRung"];
	}
	if (rung == 0) {
		rung = 1;
	}
	[self updateRungControls];
}


#pragma mark IBAction


- (IBAction)changeRung {
	if (rungControl.selectedSegmentIndex == 0) {
		if (rung > 1) rung -= 1;
	} else {
		if (rung < 48) rung += 1;
	}
	[self updateRungControls];
}


- (IBAction)dismiss {
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)clearRungAndDismiss {
	[target setValue:[NSNumber numberWithInt:0] forKey:key];
	[self dismiss];
}


- (IBAction)saveRungAndDismiss {
	[target setValue:[NSNumber numberWithInt:rung] forKey:key];
	[[NSUserDefaults standardUserDefaults] setInteger:rung forKey:@"LastSavedRung"];
	[self dismiss];
}


#pragma mark Cleanup


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
