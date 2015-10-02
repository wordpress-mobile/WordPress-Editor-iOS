#import "WPEditorToolbarView.h"
#import "WPDeviceIdentification.h"
#import "WPEditorToolbarButton.h"
#import "ZSSBarButtonItem.h"

static int kDefaultToolbarItemPadding = 10;
static int kDefaultToolbarLeftPadding = 5;

static int kNegativeToolbarItemPadding = 16;
static int kNegativeSixToolbarItemPadding = 10;
static int kNegativeSixPlusToolbarItemPadding = 6;
static int kNegativeLeftToolbarLeftPadding = 3;
static int kNegativeRightToolbarPadding = 20;
static int kNegativeSixPlusRightToolbarPadding = 24;

static const CGFloat WPEditorToolbarHeightiPad = 49.0;
static const CGFloat WPEditorToolbarButtonHeightiPad = 49.0;
static const CGFloat WPEditorToolbarButtonWidthiPad = 49.0;
static const CGFloat WPEditorToolbarHeight = 44.0;
static const CGFloat WPEditorToolbarButtonHeight = 44.0;
static const CGFloat WPEditorToolbarButtonWidth = 44.0;
static const CGFloat WPEditorToolbarDividerLineHeight = 34.0;
static const CGFloat WPEditorToolbarDividerLineWidth = 0.6;

@interface WPEditorToolbarView ()

#pragma mark - Properties: Toolbar
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIView *topBorderView;
@property (nonatomic, weak) UIToolbar *leftToolbar;
@property (nonatomic, weak) UIToolbar *rightToolbar;
@property (nonatomic, weak) UIView *rightToolbarHolder;
@property (nonatomic, weak) UIView *rightToolbarDivider;

#pragma mark - Properties: Toolbar items
@property (nonatomic, strong, readwrite) UIBarButtonItem* htmlBarButtonItem;

/**
 *  Toolbar items to include
 */
@property (nonatomic, assign, readwrite) ZSSRichTextEditorToolbar enabledToolbarItems;

@end

@implementation WPEditorToolbarView

/**
 *  @brief      Initializer for the view with a certain frame.
 *
 *  @param      frame       The frame for the view.
 *
 *  @return     The initialized object.
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _enabledToolbarItems = [self defaultToolbarItems];
        [self buildToolbar];
    }
    
    return self;
}

#pragma mark - Toolbar building

- (void)buildToolbar
{
    [self buildMainToolbarHolder];
    [self buildToolbarScroll];
    [self buildLeftToolbar];
    
    if (!IS_IPAD) {
        [self.contentView addSubview:[self rightToolbarHolder]];
    }
}

- (void)reloadItems
{
    if (IS_IPAD) {
        [self reloadiPadItems];
    } else {
        [self reloadiPhoneItems];
    }
}

- (void)reloadiPhoneItems
{
    NSMutableArray *items = [self.items mutableCopy];
    CGFloat toolbarItemsSeparation = 0.0;
    
    if ([WPDeviceIdentification isiPhoneSixPlus]) {
        toolbarItemsSeparation = kNegativeSixPlusToolbarItemPadding;
    } else if ([WPDeviceIdentification isiPhoneSix]) {
        toolbarItemsSeparation = kNegativeSixToolbarItemPadding;
    } else {
        toolbarItemsSeparation = kNegativeToolbarItemPadding;
    }
    
    CGFloat toolbarWidth = 0.0;
    NSUInteger numberOfItems = items.count;
    if (numberOfItems > 0) {
        CGFloat finalPaddingBetweenItems = kDefaultToolbarItemPadding - toolbarItemsSeparation;
        
        toolbarWidth += (numberOfItems * WPEditorToolbarButtonWidth);
        toolbarWidth += (numberOfItems * finalPaddingBetweenItems);
    }
    
    UIBarButtonItem *negativeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                       target:nil
                                                                                       action:nil];
    negativeSeparator.width = -toolbarItemsSeparation;
    
    // This code adds a negative separator between all the toolbar buttons
    for (NSInteger i = [items count]; i >= 0; i--) {
        [items insertObject:negativeSeparator atIndex:i];
    }
    
    CGFloat finalToolbarLeftPadding = kDefaultToolbarLeftPadding - kNegativeLeftToolbarLeftPadding;
    toolbarWidth += finalToolbarLeftPadding;
    self.leftToolbar.items = items;
    self.leftToolbar.frame = CGRectMake(0.0, 0.0, toolbarWidth, WPEditorToolbarHeight);
    self.toolbarScroll.contentSize = CGSizeMake(CGRectGetWidth(self.leftToolbar.frame),
                                                WPEditorToolbarHeight);
}

- (void)reloadiPadItems
{
    NSMutableArray *items = [self.items mutableCopy];
    CGFloat toolbarWidth = CGRectGetWidth(self.toolbarScroll.frame);
    UIBarButtonItem *flexSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil
                                                                                action:nil];
    UIBarButtonItem *buttonSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                  target:nil
                                                                                  action:nil];
    buttonSpacer.width = WPEditorToolbarButtonWidth;
    [items insertObject:buttonSpacer atIndex:1];
    [items insertObject:buttonSpacer atIndex:5];
    [items insertObject:buttonSpacer atIndex:7];
    [items insertObject:buttonSpacer atIndex:11];
    [items insertObject:flexSpacer atIndex:0];
    [items insertObject:flexSpacer atIndex:items.count];
    self.leftToolbar.items = items;
    self.leftToolbar.frame = CGRectMake(0.0, 0.0, toolbarWidth, WPEditorToolbarHeightiPad);
    self.toolbarScroll.contentSize = CGSizeMake(CGRectGetWidth(self.leftToolbar.frame), WPEditorToolbarHeightiPad);
}

#pragma mark - Toolbar building helpers

- (void)buildLeftToolbar
{
    NSAssert(_leftToolbar == nil, @"This is supposed to be called only once.");
    
    UIToolbar* leftToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    leftToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    leftToolbar.barTintColor = self.backgroundColor;
    leftToolbar.translucent = NO;
    
    // We had some issues with the left toolbar not resizing properly - and we didn't realize
    // immediately.  Clipping to bounds is a good way to realize sooner and not later.
    //
    leftToolbar.clipsToBounds = YES;
    
    [self.toolbarScroll addSubview:leftToolbar];
    self.leftToolbar = leftToolbar;
}

- (void)buildMainToolbarHolder
{    
    CGRect subviewFrame = self.frame;
    subviewFrame.origin = CGPointZero;
    
    UIView* mainToolbarHolderContent = [[UIView alloc] initWithFrame:subviewFrame];
    mainToolbarHolderContent.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    subviewFrame.size.height = 1.0;
    
    UIView* mainToolbarHolderTopBorder = [[UIView alloc] initWithFrame:subviewFrame];
    mainToolbarHolderTopBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    mainToolbarHolderTopBorder.backgroundColor = self.borderColor;
    
    [self addSubview:mainToolbarHolderContent];
    [self addSubview:mainToolbarHolderTopBorder];
    
    self.contentView = mainToolbarHolderContent;
    self.topBorderView = mainToolbarHolderTopBorder;
}

- (void)buildToolbarScroll
{
    NSAssert(_toolbarScroll == nil, @"This is supposed to be called only once.");
    
    CGFloat scrollviewWidth = CGRectGetWidth(self.frame);
    CGRect toolbarScrollFrame;
    if (IS_IPAD) {
        toolbarScrollFrame = CGRectMake(0.0, 0.0, scrollviewWidth, WPEditorToolbarHeightiPad);
    } else {
        scrollviewWidth -= WPEditorToolbarButtonWidth;
        toolbarScrollFrame = CGRectMake(0.0, 0.0, scrollviewWidth, WPEditorToolbarHeight);
    }
    
    UIScrollView* toolbarScroll = [[UIScrollView alloc] initWithFrame:toolbarScrollFrame];
    toolbarScroll.showsHorizontalScrollIndicator = NO;
    if (IS_IPAD) {
        toolbarScroll.scrollEnabled = NO;
    }
    toolbarScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.contentView addSubview:toolbarScroll];
    self.toolbarScroll = toolbarScroll;
}


#pragma mark - Toolbar size

+ (CGFloat)height
{
    if (IS_IPAD) {
        return WPEditorToolbarHeightiPad;
    } else {
        return WPEditorToolbarHeight;
    }
}

#pragma mark - Toolbar buttons

- (ZSSBarButtonItem*)barButtonItemWithTag:(WPEditorViewControllerElementTag)tag
                             htmlProperty:(NSString*)htmlProperty
                                imageName:(NSString*)imageName
                                   target:(id)target
                                 selector:(SEL)selector
                       accessibilityLabel:(NSString*)accessibilityLabel
{
    ZSSBarButtonItem *barButtonItem = [[ZSSBarButtonItem alloc] initWithImage:nil
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:nil
                                                                       action:nil];
    barButtonItem.tag = tag;
    barButtonItem.htmlProperty = htmlProperty;
    barButtonItem.accessibilityLabel = accessibilityLabel;
    
    UIImage* buttonImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    CGRect buttonSize;
    if (IS_IPAD) {
        buttonSize = CGRectMake(0.0, 0.0, WPEditorToolbarButtonWidthiPad, WPEditorToolbarButtonHeightiPad);
    } else {
        buttonSize = CGRectMake(0.0, 0.0, WPEditorToolbarButtonWidth, WPEditorToolbarButtonHeight);
    }
    WPEditorToolbarButton* customButton = [[WPEditorToolbarButton alloc] initWithFrame:buttonSize];
    [customButton setImage:buttonImage forState:UIControlStateNormal];
    customButton.normalTintColor = self.itemTintColor;
    customButton.selectedTintColor = self.selectedItemTintColor;
    customButton.disabledTintColor = self.disabledItemTintColor;
    [customButton addTarget:target
                     action:selector
           forControlEvents:UIControlEventTouchUpInside];
    barButtonItem.customView = customButton;
    
    return barButtonItem;
}

#pragma mark - Toolbar items

- (BOOL)canShowToolbarOption:(ZSSRichTextEditorToolbar)toolbarOption
{
    return (self.enabledToolbarItems & toolbarOption
            || self.enabledToolbarItems & ZSSRichTextEditorToolbarAll);
}

- (ZSSRichTextEditorToolbar)defaultToolbarItems
{
    ZSSRichTextEditorToolbar defaultToolbarItems = (ZSSRichTextEditorToolbarInsertImage
                                                    | ZSSRichTextEditorToolbarBold
                                                    | ZSSRichTextEditorToolbarItalic
                                                    | ZSSRichTextEditorToolbarInsertLink
                                                    | ZSSRichTextEditorToolbarBlockQuote
                                                    | ZSSRichTextEditorToolbarUnorderedList
                                                    | ZSSRichTextEditorToolbarOrderedList);
    
    // iPad gets the HTML source button too
    if (IS_IPAD) {
        defaultToolbarItems = (defaultToolbarItems
                               | ZSSRichTextEditorToolbarStrikeThrough
                               | ZSSRichTextEditorToolbarViewSource);
    }
    
    return defaultToolbarItems;
}

- (void)enableToolbarItems:(BOOL)enable
    shouldShowSourceButton:(BOOL)showSource
{
    NSArray *items = self.leftToolbar.items;
    
    for (ZSSBarButtonItem *item in items) {
        if (item.tag == kWPEditorViewControllerElementShowSourceBarButton) {
            item.enabled = showSource;
        } else {
            item.enabled = enable;
            
            if (!enable) {
                [item setSelected:NO];
            }
        }
    }
}

- (void)clearSelectedToolbarItems
{
    for (ZSSBarButtonItem *item in self.leftToolbar.items) {
        if (item.tag != kWPEditorViewControllerElementShowSourceBarButton) {
           [item setSelected:NO];
        }
    }
}

- (BOOL)hasSomeEnabledToolbarItems
{
    return !(self.enabledToolbarItems & ZSSRichTextEditorToolbarNone);
}

- (void)selectToolbarItemsForStyles:(NSArray*)styles
{
    NSArray *items = self.leftToolbar.items;
    
    for (UIBarButtonItem *item in items) {
        // Since we're using UIBarItem as negative separators, we need to make sure we don't try to
        // use those here.
        //
        if ([item isKindOfClass:[ZSSBarButtonItem class]]) {
            ZSSBarButtonItem* zssItem = (ZSSBarButtonItem*)item;
            
            if ([styles containsObject:zssItem.htmlProperty]) {
                zssItem.selected = YES;
            } else {
                zssItem.selected = NO;
            }
        }
    }
}

#pragma mark - Getters

- (UIBarButtonItem*)htmlBarButtonItem
{
    if (!_htmlBarButtonItem) {
        NSString* accessibilityLabel = NSLocalizedString(@"Display HTML",
                                                         @"Accessibility label for display HTML button on formatting toolbar.");
        
        ZSSBarButtonItem *htmlButton = [self barButtonItemWithTag:kWPEditorViewControllerElementiPhoneShowSourceBarButton
                                                        htmlProperty:@""
                                                           imageName:@"icon_format_html"
                                                              target:self
                                                            selector:@selector(showHTMLSource:)
                                                  accessibilityLabel:accessibilityLabel];
        _htmlBarButtonItem = htmlButton;
    }
    
    return _htmlBarButtonItem;
}

- (UIView*)rightToolbarHolder
{
    UIView* rightToolbarHolder = _rightToolbarHolder;
    
    if (!rightToolbarHolder) {
        
        UIView* rightToolbarDivider = _rightToolbarDivider;
        if (!rightToolbarDivider) {
            CGRect dividerLineFrame = CGRectMake(0.0,
                                                 floorf((WPEditorToolbarHeight - WPEditorToolbarDividerLineHeight) / 2),
                                                 WPEditorToolbarDividerLineWidth,
                                                 WPEditorToolbarDividerLineHeight);
            rightToolbarDivider = [[UIView alloc] initWithFrame:dividerLineFrame];
            rightToolbarDivider.backgroundColor = self.borderColor;
            rightToolbarDivider.alpha = 0.7;
            _rightToolbarDivider = rightToolbarDivider;
        }
        
        CGRect rightSpacerFrame = CGRectMake(CGRectGetMaxX(self.rightToolbarDivider.frame),
                                             0.0,
                                             kNegativeRightToolbarPadding / 2.0,
                                             WPEditorToolbarHeight);
        UIView *rightSpacer = [[UIView alloc] initWithFrame:rightSpacerFrame];
        rightSpacer.backgroundColor = self.backgroundColor;
        
        CGRect rightToolbarHolderFrame = CGRectMake(CGRectGetWidth(self.frame) - (WPEditorToolbarButtonWidth + CGRectGetWidth(self.rightToolbarDivider.frame) + CGRectGetWidth(rightSpacer.frame)),
                                                    0.0,
                                                    WPEditorToolbarButtonWidth + CGRectGetWidth(self.rightToolbarDivider.frame) + CGRectGetWidth(rightSpacer.frame),
                                                    WPEditorToolbarHeight);
        rightToolbarHolder = [[UIView alloc] initWithFrame:rightToolbarHolderFrame];
        rightToolbarHolder.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        rightToolbarHolder.clipsToBounds = YES;
        rightToolbarHolder.backgroundColor = self.backgroundColor;
        
        CGRect toolbarFrame = CGRectMake(CGRectGetMaxX(rightSpacer.frame),
                                         0.0,
                                         CGRectGetWidth(rightToolbarHolder.frame),
                                         CGRectGetHeight(rightToolbarHolder.frame));
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
        self.rightToolbar = toolbar;
        
        [rightToolbarHolder addSubview:rightSpacer];
        [rightToolbarHolder addSubview:self.rightToolbarDivider];
        [rightToolbarHolder addSubview:toolbar];
        
        UIBarButtonItem *negativeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                           target:nil
                                                                                           action:nil];
        // Negative separator needs to be different on 6+
        if ([WPDeviceIdentification isiPhoneSixPlus]) {
            negativeSeparator.width = -kNegativeSixPlusRightToolbarPadding;
        } else {
            negativeSeparator.width = -kNegativeRightToolbarPadding;
        }
        
        toolbar.items = @[negativeSeparator, [self htmlBarButtonItem]];
        toolbar.barTintColor = self.backgroundColor;
        
        _rightToolbarHolder = rightToolbarHolder;
    }
    
    return rightToolbarHolder;
}

#pragma mark - Setters

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (self.backgroundColor != backgroundColor) {
        super.backgroundColor = backgroundColor;
        
        self.leftToolbar.barTintColor = backgroundColor;
        self.rightToolbar.barTintColor = backgroundColor;
        self.rightToolbarHolder.backgroundColor = backgroundColor;
    }
}

- (void)setBorderColor:(UIColor *)borderColor
{
    if (_borderColor != borderColor) {
        _borderColor = borderColor;
        
        self.topBorderView.backgroundColor = borderColor;
        self.rightToolbarDivider.backgroundColor = borderColor;
    }
}

- (void)setItems:(NSArray*)items
{
    if (_items != items) {
        _items = [items copy];
        
        [self reloadItems];
    }
}

- (void)setItemTintColor:(UIColor *)itemTintColor
{
    _itemTintColor = itemTintColor;
    
    for (UIBarButtonItem *item in self.leftToolbar.items) {
        item.tintColor = _itemTintColor;
    }
    
    if (self.htmlBarButtonItem) {
        WPEditorToolbarButton* htmlButton = (WPEditorToolbarButton*)self.htmlBarButtonItem.customView;
        NSAssert([htmlButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an HTML button of class WPEditorToolbarButton here.");
        
        htmlButton.normalTintColor = itemTintColor;
        self.htmlBarButtonItem.tintColor = itemTintColor;
    }
}

- (void)setDisabledItemTintColor:(UIColor *)disabledItemTintColor
{
    _disabledItemTintColor = disabledItemTintColor;
    
    for (WPEditorToolbarButton *item in self.leftToolbar.items) {
        item.disabledTintColor = _disabledItemTintColor;
    }
}

- (void)setSelectedItemTintColor:(UIColor *)selectedItemTintColor
{
    _selectedItemTintColor = selectedItemTintColor;

    if (self.htmlBarButtonItem) {
        WPEditorToolbarButton* htmlButton = (WPEditorToolbarButton*)self.htmlBarButtonItem.customView;
        NSAssert([htmlButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an HTML button of class WPEditorToolbarButton here.");
        
        htmlButton.selectedTintColor = selectedItemTintColor;
    }
}

#pragma mark - Temporary: added to make the refactor easier, but should be removed at some point

- (void)showHTMLSource:(UIBarButtonItem *)barButtonItem
{
    [self.delegate editorToolbarView:self showHTMLSource:barButtonItem];
}

@end
