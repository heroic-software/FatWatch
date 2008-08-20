//
//  BRTableViewController.h
//  TimeTracker
//
//  Created by Benjamin Ragheb on 7/18/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BRTableSection.h"
#import "BRTableRow.h"

@interface BRTableViewController : UITableViewController {
	NSMutableArray *sections;
}
- (NSUInteger)numberOfSections;
- (void)addSection:(BRTableSection *)tableSection animated:(BOOL)animated;
- (BRTableSection *)addNewSection;
- (void)removeSectionsAtIndexes:(NSIndexSet *)indexSet animated:(BOOL)animated;
- (void)removeAllSections;
- (BRTableSection *)sectionAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfSection:(BRTableSection *)section;
- (void)presentViewController:(UIViewController *)controller forRow:(BRTableRow *)row;
- (void)dismissViewController:(UIViewController *)controller forRow:(BRTableRow *)row;
@end
