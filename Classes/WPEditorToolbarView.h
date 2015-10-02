#import <UIKit/UIKit.h>

@class WPEditorToolbarView;
@class ZSSBarButtonItem;

/**
 *  The types of toolbar items that can be added
 */
typedef NS_ENUM(NSInteger, ZSSRichTextEditorToolbar) {
    ZSSRichTextEditorToolbarBold = 1,
    ZSSRichTextEditorToolbarItalic = 1 << 0,
    ZSSRichTextEditorToolbarSubscript = 1 << 1,
    ZSSRichTextEditorToolbarSuperscript = 1 << 2,
    ZSSRichTextEditorToolbarStrikeThrough = 1 << 3,
    ZSSRichTextEditorToolbarUnderline = 1 << 4,
    ZSSRichTextEditorToolbarRemoveFormat = 1 << 5,
    ZSSRichTextEditorToolbarJustifyLeft = 1 << 6,
    ZSSRichTextEditorToolbarJustifyCenter = 1 << 7,
    ZSSRichTextEditorToolbarJustifyRight = 1 << 8,
    ZSSRichTextEditorToolbarJustifyFull = 1 << 9,
    ZSSRichTextEditorToolbarH1 = 1 << 10,
    ZSSRichTextEditorToolbarH2 = 1 << 11,
    ZSSRichTextEditorToolbarH3 = 1 << 12,
    ZSSRichTextEditorToolbarH4 = 1 << 13,
    ZSSRichTextEditorToolbarH5 = 1 << 14,
    ZSSRichTextEditorToolbarH6 = 1 << 15,
    ZSSRichTextEditorToolbarTextColor = 1 << 16,
    ZSSRichTextEditorToolbarBackgroundColor = 1 << 17,
    ZSSRichTextEditorToolbarUnorderedList = 1 << 18,
    ZSSRichTextEditorToolbarOrderedList = 1 << 19,
    ZSSRichTextEditorToolbarHorizontalRule = 1 << 20,
    ZSSRichTextEditorToolbarIndent = 1 << 21,
    ZSSRichTextEditorToolbarOutdent = 1 << 22,
    ZSSRichTextEditorToolbarInsertImage = 1 << 23,
    ZSSRichTextEditorToolbarInsertLink = 1 << 24,
    ZSSRichTextEditorToolbarRemoveLink = 1 << 25,
    ZSSRichTextEditorToolbarQuickLink = 1 << 26,
    ZSSRichTextEditorToolbarUndo = 1 << 27,
    ZSSRichTextEditorToolbarRedo = 1 << 28,
    ZSSRichTextEditorToolbarViewSource = 1 << 29,
    ZSSRichTextEditorToolbarBlockQuote = 1 << 30,
    ZSSRichTextEditorToolbarAll = 1 << 31,
    ZSSRichTextEditorToolbarNone = 1 << 32,
};

typedef enum
{
    kWPEditorViewControllerElementTagUnknown = -1,
    kWPEditorViewControllerElementTagJustifyLeftBarButton,
    kWPEditorViewControllerElementTagJustifyCenterBarButton,
    kWPEditorViewControllerElementTagJustifyRightBarButton,
    kWPEditorViewControllerElementTagJustifyFullBarButton,
    kWPEditorViewControllerElementTagBackgroundColorBarButton,
    kWPEditorViewControllerElementTagBlockQuoteBarButton,
    kWPEditorViewControllerElementTagBoldBarButton,
    kWPEditorViewControllerElementTagH1BarButton,
    kWPEditorViewControllerElementTagH2BarButton,
    kWPEditorViewControllerElementTagH3BarButton,
    kWPEditorViewControllerElementTagH4BarButton,
    kWPEditorViewControllerElementTagH5BarButton,
    kWPEditorViewControllerElementTagH6BarButton,
    kWPEditorViewControllerElementTagHorizontalRuleBarButton,
    kWPEditorViewControllerElementTagIndentBarButton,
    kWPEditorViewControllerElementTagInsertImageBarButton,
    kWPEditorViewControllerElementTagInsertLinkBarButton,
    kWPEditorViewControllerElementTagItalicBarButton,
    kWPEditorViewControllerElementOrderedListBarButton,
    kWPEditorViewControllerElementOutdentBarButton,
    kWPEditorViewControllerElementQuickLinkBarButton,
    kWPEditorViewControllerElementRedoBarButton,
    kWPEditorViewControllerElementRemoveFormatBarButton,
    kWPEditorViewControllerElementRemoveLinkBarButton,
    kWPEditorViewControllerElementShowSourceBarButton,
    kWPEditorViewControllerElementiPhoneShowSourceBarButton,
    kWPEditorViewControllerElementStrikeThroughBarButton,
    kWPEditorViewControllerElementSubscriptBarButton,
    kWPEditorViewControllerElementSuperscriptBarButton,
    kWPEditorViewControllerElementTextColorBarButton,
    kWPEditorViewControllerElementUnderlineBarButton,
    kWPEditorViewControllerElementUnorderedListBarButton,
    kWPEditorViewControllerElementUndoBarButton,
    
} WPEditorViewControllerElementTag;

@protocol WPEditorToolbarViewDelegate <NSObject>
@required
/**
 *  @brief      Tell the delegate to show the source view.
 *  @todo       This callback method should be replaced at some point by a better customization
 *              mechanism for the toolbar items.  The reason it's here now is that we need to make
 *              the refactoring easier to avoid adding unnecessary bugs - and the customization
 *              mechnism is probably going to be moderately complex.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(WPEditorToolbarView*)editorToolbarView
           showHTMLSource:(UIBarButtonItem *)barButtonItem;
@end

/**
 *  @class      WPEditorToolbarView
 *  @brief      Takes care of all the toolbar view visualization logic.
 */
@interface WPEditorToolbarView : UIView

#pragma mark - Properties: toolbar scrollview

@property (nonatomic, weak) UIScrollView *toolbarScroll;

#pragma mark - Properties: toolbar items

@property (nonatomic, copy, readwrite) NSArray* items;

#pragma mark - Properties: color

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

#pragma mark - Properties: delegate

/**
 *  @brief      The toolbar delegate.
 */
@property (nonatomic, weak, readwrite) id<WPEditorToolbarViewDelegate> delegate;

#pragma mark - Toolbar size

/**
 *  @brief      The size of the toolbar.
 *  @details    The width can be variable, but this should be set appropriately in the frame setup.
 *
 *  @returns    The toolbar height.
 */
+ (CGFloat)height;

#pragma mark - Toolbar buttons

- (ZSSBarButtonItem*)barButtonItemWithTag:(WPEditorViewControllerElementTag)tag
                             htmlProperty:(NSString*)htmlProperty
                                imageName:(NSString*)imageName
                                   target:(id)target
                                 selector:(SEL)selector
                       accessibilityLabel:(NSString*)accessibilityLabel;

#pragma mark - Toolbar items

/**
 *  @brief      Call this method to know if a certain toolbar option can be shown.
 *
 *  @returns    YES if the option can be shown.  NO otherwise.
 */
- (BOOL)canShowToolbarOption:(ZSSRichTextEditorToolbar)toolbarOption;

- (void)enableToolbarItems:(BOOL)enable
    shouldShowSourceButton:(BOOL)showSource;

/**
 *  @brief      Call this method to know if there are enabled toolbar items.
 *
 *  @returns    YES if there are enabled toolbar items, NO otherwise.
 */
- (BOOL)hasSomeEnabledToolbarItems;

/**
 *  @brief      Clears all selected toolbar items.
 */
- (void)clearSelectedToolbarItems;

- (void)selectToolbarItemsForStyles:(NSArray*)styles;

@end
