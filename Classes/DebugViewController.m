/*
 * DebugViewController.m
 * Created by Benjamin Ragheb on 9/7/10.
 * Copyright 2015 Heroic Software Inc
 *
 * This file is part of FatWatch.
 *
 * FatWatch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FatWatch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "DebugViewController.h"
#import "EatWatchAppDelegate.h"


#if DEBUG_LAUNCH_STAGE_ENABLED


@implementation DebugViewController
{
	NSArray *profileNames;
}

- (id)init {
	if ((self = [super initWithNibName:nil bundle:nil])) {
		NSArray *allPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"test.db" inDirectory:nil];
		NSMutableArray *names = [NSMutableArray arrayWithCapacity:[allPaths count]];
		for (NSString *path in allPaths) {
			NSString *basename = [path lastPathComponent];
			[names addObject:[basename substringToIndex:([basename length] - 3)]];
		}
		profileNames = [names copy];
	}
	return self;
}


- (void)resetDatabaseNamed:(NSString *)name {
	EatWatchAppDelegate *appdel = (id)[[UIApplication sharedApplication] delegate];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;

	if ([fileManager removeItemAtPath:[appdel databasePath] error:&error]) {
		NSLog(@"Database deleted.");
	} else {
		NSLog(@"Unable to delete database: %@", [error localizedDescription]);
	}

	if (name) {
		NSString *srcPath = [[NSBundle mainBundle] pathForResource:name ofType:@"db"];
		if ([fileManager copyItemAtPath:srcPath toPath:[appdel databasePath] error:&error]) {
			NSLog(@"Copy database template: %@", srcPath);
		} else {
			NSLog(@"Unable to copy database: %@", [error localizedDescription]);
		}
	}
}


- (void)resetDefaultsNamed:(NSString *)name {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	if (name) {
		NSString *srcPath = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
		if (srcPath) {
			NSLog(@"Loading user defaults from: %@", srcPath);
			NSDictionary *srcDict = [[NSDictionary alloc] initWithContentsOfFile:srcPath];
			for (NSString *key in srcDict) {
				id value = srcDict[key];
				[ud setObject:value forKey:key];
			}
		} else {
			NSLog(@"No defaults to load for '%@'", name);
		}
	} else {
		NSLog(@"Deleting all user defaults.");
		NSArray *keys = [[[ud dictionaryRepresentation] allKeys] copy];
		for (NSString *key in keys) {
			[ud removeObjectForKey:key];
		}
	}
}


- (void)dismissView {
	[(id)[[UIApplication sharedApplication] delegate] continueLaunchSequence];
}


- (void)doReset:(id)sender {
	NSString *name = profileNames[[sender tag]];
	[self resetDatabaseNamed:name];
	[self resetDefaultsNamed:name];
	[self dismissView];
}


- (void)doDelete {
	[self resetDatabaseNamed:nil];
	[self resetDefaultsNamed:nil];
	[self dismissView];
}


- (void)doCancel {
	[self dismissView];
}


- (void)loadView {
	CGRect baseFrame = [[UIScreen mainScreen] bounds];
	UIView *baseView = [[UIView alloc] initWithFrame:baseFrame];
	baseView.backgroundColor = [UIColor yellowColor];
	baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	UIViewAutoresizing mask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

	CGRect messageFrame = baseFrame;
	messageFrame.size.height = 100;

	UILabel *message = [[UILabel alloc] initWithFrame:messageFrame];
	message.text = @"Reset everything?";
	message.textAlignment = NSTextAlignmentCenter;
	message.backgroundColor = baseView.backgroundColor;
	message.shadowColor = [UIColor brownColor];
	message.autoresizingMask = mask;
	[baseView addSubview:message];

	UIButton *button;

	CGFloat buttonHeight = ((CGRectGetHeight(baseFrame) - CGRectGetHeight(messageFrame)) /
							([profileNames count] + 2));

	CGRect buttonFrame = CGRectIntegral(CGRectMake(0,
												   CGRectGetMaxY(messageFrame),
												   CGRectGetWidth(baseFrame),
												   buttonHeight));
	NSInteger tag = 0;

	for (NSString *name in profileNames) {
		button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[button setTitle:name forState:UIControlStateNormal];
		[button setFrame:CGRectInset(buttonFrame, 8, 4)];
		[button addTarget:self action:@selector(doReset:) forControlEvents:UIControlEventTouchUpInside];
		[button setTag:tag];
		[button setAutoresizingMask:mask];
		[baseView addSubview:button];
		buttonFrame.origin.y += buttonFrame.size.height;
		tag += 1;
	}

	button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setTitle:@"Factory Restore" forState:UIControlStateNormal];
	[button setFrame:CGRectInset(buttonFrame, 8, 4)];
	[button addTarget:self action:@selector(doDelete) forControlEvents:UIControlEventTouchUpInside];
	[button setAutoresizingMask:mask];
	[baseView addSubview:button];

	buttonFrame.origin.y += buttonFrame.size.height;

	button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setTitle:@"Normal Launch" forState:UIControlStateNormal];
	[button setFrame:CGRectInset(buttonFrame, 8, 4)];
	[button addTarget:self action:@selector(doCancel) forControlEvents:UIControlEventTouchUpInside];
	[button setAutoresizingMask:mask];
	[baseView addSubview:button];

	self.view = baseView;
}




@end


#endif // DEBUG_LAUNCH_STAGE_ENABLED
