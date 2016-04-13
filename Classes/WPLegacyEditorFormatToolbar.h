#import <UIKit/UIKit.h>
#import "WPLegacyEditorFormatAction.h"

@class WPLegacyEditorFormatToolbar;

@protocol WPLegacyEditorFormatToolbarDelegate <NSObject>

- (void)formatToolbar:(WPLegacyEditorFormatToolbar *)formatToolbar actionPressed:(WPLegacyEditorFormatAction)formatAction;

@end

@interface WPLegacyEditorFormatToolbar : UIToolbar

@property (nonatomic, weak) id<WPLegacyEditorFormatToolbarDelegate> formatDelegate;

- (void)disableAllButtons;

- (void)configureForHorizontalSizeClass:(UIUserInterfaceSizeClass)sizeClass;

@end
