#import <UIKit/UIKit.h>

/**
 UITextView subclass that allows basic styling of text using the floating format
 menu or via keyboard shortcuts (which may be defined in a containing view 
 controller by implementing `keyCommands`). 
 
 Defers marking up or styling the text to another class through a number of 
 blocks. These are executed whenever the user uses the format menu or presses
 the standard keyboard shortcut associated with a particular formatting action.
 
 This is necessary to add keyboard shortcut functionality to the legacy editor,
 because of an iOS 9 bug where http://www.openradar.me/25463955 shortcuts for
 bold, italic, and underline don't work correctly. The workaround is to set
 `allowsEditingTextAttributes` to YES on the textview, and implement
 `toggleBoldface:`, `toggleItalics:`, and `toggleUnderline:` on the textview to
 handle the actions.	
 */
@interface WPLegacyEditorStyledTextView : UITextView

@property (nonatomic, copy) void (^toggleBoldBlock)();
@property (nonatomic, copy) void (^toggleItalicBlock)();
@property (nonatomic, copy) void (^toggleUnderlineBlock)();

@end
