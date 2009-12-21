//
//  BRTableRow.h
//  TimeTracker
//
//  Created by Benjamin Ragheb on 7/18/08.
//  Copyright 2008 Benjamin Ragheb. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BRTableSection;


@interface BRTableRow : NSObject {
	BRTableSection *section;
	id object;
	NSString *title;
	UITextAlignment titleAlignment;
	UIColor *titleColor;
	UITableViewCellAccessoryType accessoryType;
	UIView *accessoryView;
}
+ (BRTableRow *)rowWithTitle:(NSString *)aTitle;
+ (BRTableRow *)rowWithObject:(id)anObject;
@property (nonatomic,retain) NSString *title;
@property (nonatomic) UITextAlignment titleAlignment;
@property (nonatomic,retain) UIColor *titleColor;
@property (nonatomic) UITableViewCellAccessoryType accessoryType;
@property (nonatomic,retain) UIView *accessoryView;
@property (nonatomic,retain) id object;
@property (nonatomic,readonly) BRTableSection *section;
- (NSString *)reuseableCellIdentifier;
- (UITableViewCell *)createCell;
- (void)configureCell:(UITableViewCell *)cell;
- (UITableViewCell *)cell;
- (NSIndexPath *)indexPath;
- (void)didAddToSection:(BRTableSection *)section;
- (void)willRemoveFromSection;
- (void)didSelect;
- (void)updateCell;
- (void)deselectAnimated:(BOOL)animated;
@end
