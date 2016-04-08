#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WPLegacyKeyboardToolbarButtonItem.h"

@protocol WPLegacyKeyboardToolbarDelegate <NSObject>
- (void)keyboardToolbarButtonItemPressed:(WPLegacyKeyboardToolbarButtonItem *)buttonItem;
@end

@interface WPLegacyKeyboardToolbarBase : UIToolbar

@property (nonatomic, weak) id<WPLegacyKeyboardToolbarDelegate> delegate;

- (void)setupView;
- (void)setupFormatView;

@end
