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


@interface BRTableSection : NSObject
+ (BRTableSection *)section;
@property (nonatomic,strong) NSString *headerTitle;
@property (nonatomic,strong) NSString *footerTitle;
@property (weak, nonatomic,readonly) BRTableViewController *controller;
- (void)didAddToController:(BRTableViewController *)aController;
- (void)willRemoveFromController;
- (NSUInteger)numberOfRows;
- (BRTableRow *)rowAtIndex:(NSUInteger)index;
- (NSIndexPath *)indexPathOfRow:(BRTableRow *)row;
- (void)addRow:(BRTableRow *)tableRow animated:(BOOL)animated;
- (void)removeRowAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (UITableViewCell *)cellForRow:(BRTableRow *)row;
- (void)configureCell:(UITableViewCell *)cell forRowAtIndex:(NSUInteger)index;
- (void)didSelectRowAtIndex:(NSUInteger)index;
@end


@interface BRTableRadioSection : BRTableSection
@property (nonatomic) NSInteger selectedIndex;
@property (weak, nonatomic,readonly) BRTableRow *selectedRow;
@end
