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


@implementation FlagIconViewController


@synthesize flagTabView;
@synthesize iconArea;


- (id)init {
    if (self = [super initWithNibName:@"FlagIconView" bundle:nil]) {
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	if (iconPaths == nil) {
		iconPaths = [[[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"MarkIcons"] copy];
	}
	int i = 0;
	for (NSString *path in iconPaths) {
		UIImage *image = [UIImage imageWithContentsOfFile:path];
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.tag = i;
		button.frame = CGRectMake(18+60*(i%5), 18+60*(i/5), 42, 42);
		[button addTarget:self action:@selector(iconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[button setImage:image forState:UIControlStateNormal];
		i++;
		[iconArea addSubview:button];
	}
	iconArea.contentSize = CGSizeMake(320, 18+60*(i/5));
}


- (IBAction)flagButtonAction:(UIButton *)sender {
	[flagTabView selectTabAroundRect:[sender frame]];
	flagIndex = (sender.tag % 10);
}


- (IBAction)iconButtonAction:(UIButton *)sender {
	NSString *path = [iconPaths objectAtIndex:sender.tag];
	NSString *name = [[path lastPathComponent] stringByDeletingPathExtension];
	[EWFlagButton updateIconName:name forFlagIndex:flagIndex];
}


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
