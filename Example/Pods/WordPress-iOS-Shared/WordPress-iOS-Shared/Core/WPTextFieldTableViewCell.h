#import <Foundation/Foundation.h>
#import "WPTableViewCell.h"

@class WPTextFieldTableViewCell;

@protocol WPTextFieldTableViewCellDelegate <NSObject>

- (void)cellWantsToSelectNextField:(WPTextFieldTableViewCell *)cell;
@optional
- (void)cellTextDidChange:(WPTextFieldTableViewCell *)cell;

@end

@interface WPTextFieldTableViewCell : WPTableViewCell

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign) BOOL shouldDismissOnReturn;
@property (nonatomic, weak) id<WPTextFieldTableViewCellDelegate> delegate;
@property (nonatomic, assign) CGFloat minimumLabelWidth;

@end
