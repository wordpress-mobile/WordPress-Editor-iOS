#import <UIKit/UIKit.h>

@protocol WPLegacyEditorFormatToolbarDelegate <NSObject>
- (void)keyboardToolbarButtonItemPressed:(UIBarButtonItem *)buttonItem;
@end

@interface WPLegacyEditorFormatToolbar : UIToolbar

@property (nonatomic, weak) id<WPLegacyEditorFormatToolbarDelegate> formatDelegate;

- (void)disableAllButtons;

@end
