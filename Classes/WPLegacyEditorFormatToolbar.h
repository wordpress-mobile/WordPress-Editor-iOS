#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WPLegacyKeyboardToolbarButtonItem.h"

@protocol WPLegacyEditorFormatToolbarDelegate <NSObject>
- (void)keyboardToolbarButtonItemPressed:(WPLegacyKeyboardToolbarButtonItem *)buttonItem;
@end

@interface WPLegacyEditorFormatToolbar : UIToolbar

@property (nonatomic, weak) id<WPLegacyEditorFormatToolbarDelegate> formatDelegate;

- (void)setupView;
- (void)setupFormatView;
- (void)disableAllButtons;

@end
