//
//  BRTableSection.h
//  TimeTracker
//
//  Created by Benjamin Ragheb on 7/18/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BRTableViewController;
@class BRTableRow;


@interface BRTableSection : NSObject {
	NSMutableArray *rows;
	BRTableViewController *controller;
	NSString *headerTitle, *footerTitle;
}
@property (nonatomic,retain) NSString *headerTitle;
@property (nonatomic,retain) NSString *footerTitle;
@property (nonatomic,readonly) BRTableViewController *controller;
- (void)didAddToController:(BRTableViewController *)aController;
- (NSUInteger)numberOfRows;
- (BRTableRow *)rowAtIndex:(NSUInteger)index;
- (void)addRow:(BRTableRow *)tableRow animated:(BOOL)animated;
- (void)removeRowAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (UITableViewCell *)cellForRow:(BRTableRow *)row;
- (void)configureCell:(UITableViewCell *)cell forRowAtIndex:(NSUInteger)index;
- (void)didSelectRowAtIndex:(NSUInteger)index;
@end


@interface BRTableRadioSection : BRTableSection {
	NSInteger selectedIndex;
}
@property (nonatomic) NSInteger selectedIndex;
@end
