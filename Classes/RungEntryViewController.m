//
//  RungEntryViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 12/21/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "RungEntryViewController.h"


enum {
	EWLadderBend,
	EWLadderSitUp,
	EWLadderLegLift,
	EWLadderPushUp,
	EWLadderSteps
};


static unsigned short EWLadder[48][5] = {
	// Introductory Ladder
	{	2,	3,	4,	2,	105 },
	{	3,	4,	5,	3,	140 },
	{	4,	6,	6,	3,	170 },
	{	6,	7,	8,	4,	200 },
	{	7,	9,	9,	5,	225 },
	{	8,	10,	10,	6,	255 },
	{	10,	11,	12,	7,	280 },
	{	12,	13,	14,	8,	305 },
	{	14,	15,	16,	9,	325 },
	{	16,	16,	18,	11,	350 },
	{	18,	18,	20,	12,	370 },
	{	20,	20,	22,	13,	390 },
	{	23,	21,	25,	15,	405 },
	{	25,	23,	27,	16,	425 },
	{	28,	25,	30,	18,	440 },
	// Lifetime Ladder
	{	14,	10,	12,	9,	340	},
	{	15,	11,	14,	10,	355	},	
	{	16,	12,	16,	11,	375	},
	{	18,	13,	17,	12,	390	},
	{	19,	14,	19,	13,	405	},
	{	21,	15,	21,	14,	420	},
	{	22,	16,	23,	15,	435	},
	{	24,	17,	25,	16,	445	},
	{	25,	18,	27,	17,	460	},
	{	27,	20,	29,	18,	470	},
	{	29,	21,	31,	19,	480	},
	{	31,	23,	33,	20,	490	},
	{	33,	24,	36,	21,	500	},
	{	34,	26,	38,	22,	510	},
	{	36,	28,	40,	23,	515	},
	{	38,	29,	43,	24,	525	},
	{	40,	31,	45,	25,	530	},
	{	43,	33,	48,	26,	535	},
	{	45,	35,	51,	27,	540	},
	{	47,	37,	54,	28,	540	},
	{	49,	39,	56,	29,	545	},
	{	51,	41,	59,	30,	545	},
	{	54,	43,	62,	31,	545	},
	{	56,	46,	65,	32,	550	},
	{	59,	48,	68,	33,	555	},
	{	61,	50,	72,	34,	555	},
	{	64,	53,	75,	35,	555	},
	{	66,	55,	78,	36,	560	},
	{	69,	58,	81,	37,	560	},
	{	72,	61,	85,	38,	560	},
	{	74,	64,	88,	39,	575	},
	{	77,	66,	92,	40,	575	},
	{	80,	69,	96,	41,	575	}
};


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
@synthesize setsLabel;
@synthesize extraStepsLabel;


- (id)init {
	return [self initWithNibName:@"RungEntryView" bundle:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)updateRungControls {
	BOOL isIntroductoryLadder = rung < 16;
	
	rungLabel.text = [NSString stringWithFormat:@"Rung %d", rung];
	[rungControl setEnabled:(rung > 1) forSegmentAtIndex:0];
	[rungControl setEnabled:(rung < 48) forSegmentAtIndex:1];

	UILabel *setsLabelLabel = (UILabel *)[self.view viewWithTag:757];
	if (isIntroductoryLadder) {
		ladderLabel.text = NSLocalizedString(@"Introductory Ladder", nil);
		setsLabelLabel.text = NSLocalizedString(@"sets of 75 steps, 7 jumps", nil);
	} else {
		ladderLabel.text = NSLocalizedString(@"Lifetime Ladder", nil);
		setsLabelLabel.text = NSLocalizedString(@"sets of 75 steps, 10 jumps", nil);
	}

	unsigned short *n = EWLadder[rung - 1];
	unsigned short sets = n[EWLadderSteps] / 75;
	unsigned short extra = n[EWLadderSteps] % 75;
	
	bendLabel.text = [NSString stringWithFormat:@"%d", n[EWLadderBend]];
	sitUpLabel.text = [NSString stringWithFormat:@"%d", n[EWLadderSitUp]];
	legLiftLabel.text = [NSString stringWithFormat:@"%d", n[EWLadderLegLift]];
	pushUpLabel.text = [NSString stringWithFormat:@"%d", n[EWLadderPushUp]];
	stepsLabel.text = [NSString stringWithFormat:@"%d", n[EWLadderSteps]];
	setsLabel.text = [NSString stringWithFormat:@"%d", sets];
	extraStepsLabel.text = [NSString stringWithFormat:@"%d", extra];
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


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
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
	[self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)clearRungAndDismiss {
	[target setValue:@0 forKey:key];
	[self dismiss];
}


- (IBAction)saveRungAndDismiss {
	[target setValue:@(rung) forKey:key];
	[[NSUserDefaults standardUserDefaults] setInteger:rung forKey:@"LastSavedRung"];
	[self dismiss];
}


#pragma mark Cleanup


- (void)viewDidUnload {
	self.rungControl = nil;
	self.rungLabel = nil;
	self.ladderLabel = nil;
	self.bendLabel = nil;
	self.sitUpLabel = nil;
	self.legLiftLabel = nil;
	self.pushUpLabel = nil;
	self.stepsLabel = nil;
	self.setsLabel = nil;
	self.extraStepsLabel = nil;
	[super viewDidUnload];
}




@end
