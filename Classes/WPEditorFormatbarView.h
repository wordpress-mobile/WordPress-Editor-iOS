#import <UIKit/UIKit.h>

@class WPEditorFormatbarView;
@class ZSSBarButtonItem;

extern const CGFloat WPEditorFormatbarViewToolbarHeight;

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
 *  @brief      Tell the delegate the strikethrough button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
            setStrikeThrough:(UIBarButtonItem *)barButtonItem;

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
@property (nonatomic, copy, readwrite) UIColor* borderColor UI_APPEARANCE_SELECTOR;

/**
 *  Color to tint the toolbar items
 */
@property (nonatomic, strong) UIColor *itemTintColor UI_APPEARANCE_SELECTOR;

/**
 *  Color to tint the toolbar items when the toolbar is disabled
 */
@property (nonatomic, strong) UIColor *disabledItemTintColor UI_APPEARANCE_SELECTOR;

/**
 *  Color to tint selected items
 */
@property (nonatomic, strong) UIColor *selectedItemTintColor UI_APPEARANCE_SELECTOR;

#pragma mark - Toolbar items

/**
 *  @brief      Returns a toolbar item (if any) matching the specified tag.
 *
 *  @param      tag     WPEditorViewControllerElementTag of the item to return.
 *  @return     A toolbar item with the specified tag.
 */
- (UIBarButtonItem *)toolBarItemWithTag:(WPEditorViewControllerElementTag)tag;

/**
 *  @brief      Makes a toolbar item visible or hidden
 *
 *  @param      tag     WPEditorViewControllerElementTag of the item to alter.
 *  @param      visible YES to make the item visible, NO to hide it.
 */
- (void)toolBarItemWithTag:(WPEditorViewControllerElementTag)tag setVisible:(BOOL)visible;

/**
 *  @brief      Selects or deselects a toolbar item
 *
 *  @param      tag      WPEditorViewControllerElementTag of the item to alter.
 *  @param      selected YES to make the item selected, NO to deselect it.
 */
- (void)toolBarItemWithTag:(WPEditorViewControllerElementTag)tag setSelected:(BOOL)selected;

/**
 *  @brief      Toggles the on / off selection state for a toolbar item
 *
 *  @param      tag      WPEditorViewControllerElementTag of the item to alter.
 */
- (void)toggleSelectionForToolBarItemWithTag:(WPEditorViewControllerElementTag)tag;

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
