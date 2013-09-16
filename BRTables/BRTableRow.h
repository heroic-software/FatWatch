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
	BRTableSection *__weak section;
	id object;
	UITableViewCellStyle cellStyle;
	NSString *title;
	NSString *detail;
	UITextAlignment titleAlignment;
	UIColor *titleColor;
	UITableViewCellAccessoryType accessoryType;
	UIView *accessoryView;
	UITableViewCellSelectionStyle selectionStyle;
	UIImage *image;
}
+ (BRTableRow *)rowWithTitle:(NSString *)aTitle;
+ (BRTableRow *)rowWithObject:(id)anObject;
@property (nonatomic) UITableViewCellStyle cellStyle;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *detail;
@property (nonatomic) UITextAlignment titleAlignment;
@property (nonatomic,strong) UIColor *titleColor;
@property (nonatomic) UITableViewCellAccessoryType accessoryType;
@property (nonatomic,strong) UIView *accessoryView;
@property (nonatomic) UITableViewCellSelectionStyle selectionStyle;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) id object;
@property (weak, nonatomic,readonly) BRTableSection *section;
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
