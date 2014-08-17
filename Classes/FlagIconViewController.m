//
//  FlagIconViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/16/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import "FlagIconViewController.h"
#import "FlagTabView.h"
#import "EWFlagButton.h"
#import "NSUserDefaults+EWAdditions.h"
#import "BRConfirmationAlert.h"


#if TARGET_IPHONE_SIMULATOR
#define BOOK_EXERCISE_URL @"http://fatwatchapp.test/goto/hackdiet-exercise"
#else
#define BOOK_EXERCISE_URL @"http://www.fatwatchapp.com/goto/hackdiet-exercise"
#endif


@interface FlagIconViewController ()
- (IBAction)iconButtonAction:(UIButton *)sender;
@end


@implementation FlagIconViewController
{
	FlagTabView *flagTabView;
	UIScrollView *iconArea;
	UIView *enableLadderView;
	UIView *disableLadderView;
	NSArray *iconNames;
	int flagIndex;
	UIView *iconView;
	CGPoint contentOffsets[4];
}

@synthesize flagTabView;
@synthesize iconArea;
@synthesize enableLadderView;
@synthesize disableLadderView;


- (id)init {
    if ((self = [super initWithNibName:@"FlagIconView" bundle:nil])) {
		self.title = NSLocalizedString(@"Marks", nil);
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (iconNames == nil) {
		iconNames = [[EWFlagButton allIconNames] copy];
	}
	
	const CGFloat w = CGRectGetWidth(iconArea.bounds);
	const CGFloat h = 18 + 60 * ceilf([iconNames count] / 5.0f);
	iconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
	
	int i = 0;
	for (NSString *name in iconNames) {
		UIImage *image = [EWFlagButton imageForIconName:name];
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.tag = i;
		button.frame = CGRectMake(18+60*(i%5), 18+60*(i/5), 42, 42);
		[button addTarget:self action:@selector(iconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[button setImage:image forState:UIControlStateNormal];
		i++;
		[iconView addSubview:button];
	}

	[iconArea addSubview:iconView];
	[iconArea setContentSize:iconView.bounds.size];
}


- (void)setLowerView:(UIView *)lowerView otherView:(UIView *)otherView {
	[otherView removeFromSuperview];
	if (otherView == iconArea) [lowerView setFrame:otherView.frame];
	[self.view addSubview:lowerView];
}


- (void)showEnableLadderView:(BOOL)show {
	if (show) {
		[iconArea addSubview:enableLadderView];
		CGRect iconViewFrame = iconView.frame;
		iconViewFrame.origin.y = CGRectGetMaxY(enableLadderView.frame);
		iconView.frame = iconViewFrame;
		CGSize contentSize = iconView.bounds.size;
		contentSize.height += CGRectGetHeight(enableLadderView.frame);
		[iconArea setContentSize:contentSize];
	} else {
		[enableLadderView removeFromSuperview];
		[iconView setFrame:iconView.bounds];
		[iconArea setContentSize:iconView.bounds.size];
	}
}


- (void)updateLowerView {
	BOOL ladderEnabled = [[NSUserDefaults standardUserDefaults] isLadderEnabled];
	
	if (flagIndex == 3 && ladderEnabled) {
		[self setLowerView:disableLadderView otherView:iconArea];
	} else {
		[self setLowerView:iconArea otherView:disableLadderView];
		[self showEnableLadderView:(flagIndex == 3 && !ladderEnabled)];
	}
}


- (IBAction)flagButtonAction:(UIButton *)sender {
	int newFlagIndex = (sender.tag % 10);
	if (flagIndex == newFlagIndex) return;
	[flagTabView selectTabAroundRect:[sender frame]];
	contentOffsets[flagIndex] = [iconArea contentOffset];
	flagIndex = newFlagIndex;
	[self updateLowerView];
	[iconArea setContentOffset:contentOffsets[flagIndex]];
}


- (IBAction)useLastFlagForLadder:(UIButton *)sender {
	[[NSUserDefaults standardUserDefaults] setLadderEnabled:YES];
	[EWFlagButton updateIconName:nil forFlagIndex:flagIndex];
	[self updateLowerView];
}


- (IBAction)useLastFlagForIcon:(UIButton *)sender {
	[[NSUserDefaults standardUserDefaults] setLadderEnabled:NO];
	[EWFlagButton updateIconName:nil forFlagIndex:flagIndex];
	[self updateLowerView];
}


- (IBAction)iconButtonAction:(UIButton *)sender {
	NSString *name = iconNames[sender.tag];
	[EWFlagButton updateIconName:name forFlagIndex:flagIndex];
}


- (IBAction)explainLadder:(UIButton *)sender {
	NSURL *bookURL = [NSURL URLWithString:BOOK_EXERCISE_URL];
	BRConfirmationAlert *alert = [[BRConfirmationAlert alloc] init];
	alert.title = @"Exercise Ladder";
	alert.message = @"Do you want to open this website?";
	alert.buttonTitle = @"Website";
	[[alert confirmBeforeSendingMessageTo:[UIApplication sharedApplication]] openURL:bookURL];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
	self.flagTabView = nil;
	self.iconArea = nil;
	self.enableLadderView = nil;
	self.disableLadderView = nil;
}




@end
