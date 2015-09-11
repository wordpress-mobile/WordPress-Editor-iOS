#import <UIKit/UIKit.h>

@class WPEditorFormatbarView;
@class ZSSBarButtonItem;

/**
 *  The types of toolbar items that can be added
 */
typedef NS_ENUM(NSInteger, ZSSRichTextEditorToolbar) {
    ZSSRichTextEditorToolbarBold = 1,
    ZSSRichTextEditorToolbarItalic = 1 << 0,
    ZSSRichTextEditorToolbarStrikeThrough = 1 << 1,
    ZSSRichTextEditorToolbarUnorderedList = 1 << 2,
    ZSSRichTextEditorToolbarOrderedList = 1 << 3,
    ZSSRichTextEditorToolbarInsertImage = 1 << 4,
    ZSSRichTextEditorToolbarInsertLink = 1 << 5,
    ZSSRichTextEditorToolbarViewSource = 1 << 6,
    ZSSRichTextEditorToolbarBlockQuote = 1 << 7,
    ZSSRichTextEditorToolbarAll = 1 << 8,
    ZSSRichTextEditorToolbarNone = 1 << 9,
};

typedef enum
{
    kWPEditorViewControllerElementTagUnknown = -1,
    kWPEditorViewControllerElementTagBlockQuoteBarButton,
    kWPEditorViewControllerElementTagBoldBarButton,
    kWPEditorViewControllerElementTagInsertImageBarButton,
    kWPEditorViewControllerElementTagInsertLinkBarButton,
    kWPEditorViewControllerElementTagItalicBarButton,
    kWPEditorViewControllerElementOrderedListBarButton,
    kWPEditorViewControllerElementShowSourceBarButton,
    kWPEditorViewControllerElementiPhoneShowSourceBarButton,
    kWPEditorViewControllerElementStrikeThroughBarButton,
    kWPEditorViewControllerElementUnorderedListBarButton,
    
} WPEditorViewControllerElementTag;

@protocol WPEditorFormatbarViewDelegate <NSObject>
@required

/**
 *  @brief      Tell the delegate the insert image button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
           insertImage:(UIBarButtonItem *)barButtonItem;

/**
 *  @brief      Tell the delegate the bold button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
           setBold:(UIBarButtonItem *)barButtonItem;

/**
 *  @brief      Tell the delegate the italic button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
                  setItalic:(UIBarButtonItem *)barButtonItem;

/**
 *  @brief      Tell the delegate the blockquote button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
                setBlockquote:(UIBarButtonItem *)barButtonItem;

/**
 *  @brief      Tell the delegate the unordered list button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
            setUnorderedList:(UIBarButtonItem *)barButtonItem;

/**
 *  @brief      Tell the delegate the ordered list button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
         setOrderedList:(UIBarButtonItem *)barButtonItem;

/**
 *  @brief      Tell the delegate the insert link button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
           insertLink:(UIBarButtonItem *)barButtonItem;

/**
 *  @brief      Tell the delegate the HTML button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
           showHTMLSource:(UIBarButtonItem *)barButtonItem;

@end


@interface WPEditorFormatbarView : UIView

#pragma mark - Properties: delegate

/**
 *  @brief      The toolbar delegate.
 */
@property (nonatomic, weak, readwrite) id<WPEditorFormatbarViewDelegate> delegate;

#pragma mark - Properties: colors

/**
 *	@brief		The border color for the toolbar.
 */
@property (nonatomic, copy, readwrite) UIColor* borderColor;

/**
 *  Color to tint the toolbar items
 */
@property (nonatomic, strong) UIColor *itemTintColor;

/**
 *  Color to tint the toolbar items when the toolbar is disabled
 */
@property (nonatomic, strong) UIColor *disabledItemTintColor;

/**
 *  Color to tint selected items
 */
@property (nonatomic, strong) UIColor *selectedItemTintColor;

#pragma mark - Toolbar items

/**
 *  @brief      Enables and disables the toolbar items.
 *
 *  @param      enable       YES to enable the toolbar buttons; NO to disable them.
 *  @param      showSource   YES to enable the HTML mode button; NO to disable it.
 */
- (void)enableToolbarItems:(BOOL)enable
    shouldShowSourceButton:(BOOL)showSource;

/**
 *  @brief      Clears all selected toolbar items.
 */
- (void)clearSelectedToolbarItems;

- (void)selectToolbarItemsForStyles:(NSArray*)styles;

@end
