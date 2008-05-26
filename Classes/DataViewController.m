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

- (id)init {
	return [super initWithNibName:nil bundle:nil];
}


- (NSString *)message {
	return nil;
}


- (UIView *)loadDataView {
	return nil;
}


- (void)databaseDidChange:(NSNotification *)notice {
	if ([[Database sharedDatabase] weightCount] > 1) {
		[self dataChanged];
		if ([dataView superview] == nil) {
			[messageView removeFromSuperview];
			dataView.frame = self.view.bounds;
			[self.view addSubview:dataView];
		}
	} else {
		if ([messageView superview] == nil) {
			[dataView removeFromSuperview];
			messageView.frame = CGRectInset(self.view.bounds, 20, 20);
			[self.view addSubview:messageView];
		}
	}
}


- (void)startObservingDatabase {
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(databaseDidChange:) 
												 name:EWDatabaseDidChangeNotification 
											   object:nil];
	[self databaseDidChange:nil];
}


- (void)stopObservingDatabase {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dataChanged {
}


- (void)loadView {
	UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	mainView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	mainView.autoresizesSubviews = YES;
	mainView.backgroundColor = [UIColor lightGrayColor];
	self.view = [mainView autorelease];
	
	messageView = [[UILabel alloc] initWithFrame:CGRectZero];
	messageView.backgroundColor = mainView.backgroundColor;
	messageView.text = [self message];
	messageView.lineBreakMode = UILineBreakModeWordWrap;
	messageView.numberOfLines = 0;
	messageView.textAlignment = UITextAlignmentCenter;
	
	dataView = [[self loadDataView] retain];
}


- (void)viewWillAppear:(BOOL)animated {
	[self startObservingDatabase];
}


- (void)viewWillDisappear:(BOOL)animated {
	[self stopObservingDatabase];
}


- (void)viewDidDisappear:(BOOL)animated {
	[messageView removeFromSuperview];
	[dataView removeFromSuperview];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	if ([messageView superview] == nil) {
		[messageView release]; messageView = nil;
	}
	if ([dataView superview] == nil) {
		[dataView release]; dataView = nil;
	}
}


- (void)dealloc {
	[messageView release];
	[dataView release];
	[super dealloc];
}


@end
