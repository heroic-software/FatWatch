//
//  DataViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 4/25/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import "DataViewController.h"
#import "Database.h"

@implementation DataViewController

@synthesize dataView;

- (id)init
{
	return [super initWithNibName:nil bundle:nil];
}

- (NSString *)message
{
	return nil;
}

- (UIView *)loadDataView
{
	return nil;
}

- (void)dataChanged
{
}

- (void)loadView
{
	UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	mainView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	mainView.autoresizesSubviews = YES;
	mainView.backgroundColor = [UIColor lightGrayColor];
	self.view = mainView;
	[mainView release];
	
	messageView = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 320-40, 411)];
	messageView.backgroundColor = mainView.backgroundColor;
	messageView.text = [self message];
	messageView.lineBreakMode = UILineBreakModeWordWrap;
	messageView.numberOfLines = 0;
	
	dataView = [[self loadDataView] retain];
}

- (void)viewWillAppear:(BOOL)animated
{
	Database *database = [Database sharedDatabase];
	
	if ([database changeCount] != dbChangeCount) {
		if ([database weightCount] > 1) {
			if ([dataView superview] == nil) {
				[messageView removeFromSuperview];
				[self.view addSubview:dataView];
				dataView.frame = self.view.bounds;
			}
			[self dataChanged];
		} else {
			if ([messageView superview] == nil) {
				[dataView removeFromSuperview];
				[self.view addSubview:messageView];
			}
		}
		dbChangeCount = [database changeCount];
	}
}

- (void)didReceiveMemoryWarning {
	BOOL shouldReleaseSubviews = ([self.view superview] == nil);
	[super didReceiveMemoryWarning];
	if (shouldReleaseSubviews) {
		[messageView release]; messageView = nil;
		[dataView release]; dataView = nil;
	}
}

- (void)dealloc {
	[messageView release];
	[dataView release];
	[super dealloc];
}


@end
