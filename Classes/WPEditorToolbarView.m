#import "WPEditorToolbarView.h"
#import "WPDeviceIdentification.h"
#import "WPEditorToolbarButton.h"
#import "ZSSBarButtonItem.h"

static int kDefaultToolbarItemPadding = 10;
static int kDefaultToolbarLeftPadding = 10;

static int kNegativeToolbarItemPadding = 12;
static int kNegativeSixPlusToolbarItemPadding = 2;
static int kNegativeLeftToolbarLeftPadding = 3;
static int kNegativeRightToolbarPadding = 20;
static int kNegativeSixPlusRightToolbarPadding = 24;

static const CGFloat WPEditorToolbarHeight = 40;
static const CGFloat WPEditorToolbarButtonHeight = 40;
static const CGFloat WPEditorToolbarButtonWidth = 40;
static const CGFloat WPEditorToolbarDefaultFontSize = 28.5f;
static const CGFloat WPEditorToolbarDividerLineHeight = 28;
static const CGFloat WPEditorToolbarDividerLineWidth = 0.6f;

@interface WPEditorToolbarView ()

#pragma mark - Properties: Toolbar
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIView *topBorderView;
@property (nonatomic, weak) UIToolbar *leftToolbar;
@property (nonatomic, weak) UIToolbar *rightToolbar;
@property (nonatomic, weak) UIView *rightToolbarHolder;
@property (nonatomic, weak) UIView *rightToolbarDivider;
@property (nonatomic, weak) UIScrollView *toolbarScroll;

#pragma mark - Properties: Toolbar items
@property (nonatomic, strong, readwrite) UIBarButtonItem* htmlBarButtonItem;
@property (nonatomic, strong) NSMutableArray *customBarButtonItems;

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
    NSMutableArray *items = [self.items mutableCopy];
    
    CGFloat toolbarItemsSeparation = 0.0f;
    
    if ([WPDeviceIdentification isIPhoneSixPlus]) {
        toolbarItemsSeparation = kNegativeSixPlusToolbarItemPadding;
    } else {
        toolbarItemsSeparation = kNegativeToolbarItemPadding;
    }
    
    CGFloat toolbarWidth = 0.0f;
    NSUInteger numberOfItems = items.count;
    
    if (numberOfItems > 0) {
        CGFloat finalPaddingBetweenItems = kDefaultToolbarItemPadding - toolbarItemsSeparation;
        
        toolbarWidth += (numberOfItems * WPEditorToolbarButtonWidth);
        toolbarWidth += (numberOfItems * finalPaddingBetweenItems);
    }
    
    if (self.customBarButtonItems != nil)
    {
        [items addObjectsFromArray:self.customBarButtonItems];
        
        for(UIBarButtonItem *buttonItem in self.customBarButtonItems)
        {
            toolbarWidth += buttonItem.customView.frame.size.width;
        }
    }
    
    UIBarButtonItem *negativeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                       target:nil
                                                                                       action:nil];
    negativeSeparator.width = -toolbarItemsSeparation;
    
    // This code adds a negative separator between all the toolbar buttons
    for (NSInteger i = [items count]; i >= 0; i--) {
        [items insertObject:negativeSeparator atIndex:i];
    }
    
    UIBarButtonItem *negativeSeparatorForToolbar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                                 target:nil
                                                                                                 action:nil];
    
    CGFloat finalToolbarLeftPadding = kDefaultToolbarLeftPadding - kNegativeLeftToolbarLeftPadding;
    
    negativeSeparatorForToolbar.width = -kNegativeLeftToolbarLeftPadding;
    toolbarWidth += finalToolbarLeftPadding;
    
    [items insertObject:negativeSeparatorForToolbar atIndex:0];
    
    self.leftToolbar.items = items;
    self.leftToolbar.frame = CGRectMake(0,
                                        0,
                                        toolbarWidth,
                                        WPEditorToolbarHeight);
    self.toolbarScroll.contentSize = CGSizeMake(CGRectGetWidth(self.leftToolbar.frame),
                                                WPEditorToolbarHeight);
}

#pragma mark - Custom toolbar items

- (void)addCustomToolbarItemWithButton:(UIButton *)button
{
    if(self.customBarButtonItems == nil)
    {
        self.customBarButtonItems = [NSMutableArray array];
    }
    
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:WPEditorToolbarDefaultFontSize];
    [button setTitleColor:self.itemTintColor forState:UIControlStateNormal];
    [button setTitleColor:self.selectedItemTintColor forState:UIControlStateHighlighted];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.customBarButtonItems addObject:barButtonItem];
    
    [self reloadItems];
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
    
    subviewFrame.size.height = 1.0f;
    
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
    
    CGFloat scrollviewHeight = CGRectGetWidth(self.frame);
    
    if (!IS_IPAD) {
        scrollviewHeight -= WPEditorToolbarButtonWidth;
    }
    
    CGRect toolbarScrollFrame = CGRectMake(0,
                                           0,
                                           scrollviewHeight,
                                           WPEditorToolbarHeight);
    
    UIScrollView* toolbarScroll = [[UIScrollView alloc] initWithFrame:toolbarScrollFrame];
    toolbarScroll.showsHorizontalScrollIndicator = NO;
    toolbarScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.contentView addSubview:toolbarScroll];
    self.toolbarScroll = toolbarScroll;
}


#pragma mark - Toolbar size

+ (CGFloat)height
{
    return WPEditorToolbarHeight;
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
    
    WPEditorToolbarButton* customButton = [[WPEditorToolbarButton alloc] initWithFrame:CGRectMake(0,
                                                                                                  0,
                                                                                                  WPEditorToolbarButtonWidth,
                                                                                                  WPEditorToolbarButtonHeight)];
    [customButton setImage:buttonImage forState:UIControlStateNormal];
    customButton.normalTintColor = self.itemTintColor;
    customButton.selectedTintColor = self.selectedItemTintColor;
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
        UIBarButtonItem* htmlBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"HTML"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:nil
                                                                              action:nil];
        
        UIFont * font = [UIFont boldSystemFontOfSize:10];
        NSDictionary * attributes = @{NSFontAttributeName: font};
        [htmlBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
        htmlBarButtonItem.accessibilityLabel = NSLocalizedString(@"Display HTML",
                                                                 @"Accessibility label for display HTML button on formatting toolbar.");
        
        CGRect customButtonFrame = CGRectMake(0,
                                              0,
                                              WPEditorToolbarButtonWidth,
                                              WPEditorToolbarButtonHeight);
        
        WPEditorToolbarButton* customButton = [[WPEditorToolbarButton alloc] initWithFrame:customButtonFrame];
        [customButton setTitle:@"HTML" forState:UIControlStateNormal];
        customButton.normalTintColor = self.itemTintColor;
        customButton.selectedTintColor = self.selectedItemTintColor;
        customButton.reversesTitleShadowWhenHighlighted = YES;
        customButton.titleLabel.font = font;
        [customButton addTarget:self
                         action:@selector(showHTMLSource:)
               forControlEvents:UIControlEventTouchUpInside];
        
        htmlBarButtonItem.customView = customButton;
        
        _htmlBarButtonItem = htmlBarButtonItem;
    }
    
    return _htmlBarButtonItem;
}

- (UIView*)rightToolbarHolder
{
    UIView* rightToolbarHolder = _rightToolbarHolder;
    
    if (!rightToolbarHolder) {
        
        UIView* rightToolbarDivider = _rightToolbarDivider;
        if (!rightToolbarDivider) {
            CGRect dividerLineFrame = CGRectMake(0.0f,
                                                 floorf((WPEditorToolbarHeight - WPEditorToolbarDividerLineHeight) / 2),
                                                 WPEditorToolbarDividerLineWidth,
                                                 WPEditorToolbarDividerLineHeight);
            rightToolbarDivider = [[UIView alloc] initWithFrame:dividerLineFrame];
            rightToolbarDivider.backgroundColor = self.borderColor;
            rightToolbarDivider.alpha = 0.7f;
            _rightToolbarDivider = rightToolbarDivider;
        }
        
        CGRect rightSpacerFrame = CGRectMake(CGRectGetMaxX(self.rightToolbarDivider.frame),
                                             0.0f,
                                             kNegativeRightToolbarPadding / 2,
                                             WPEditorToolbarHeight);
        UIView *rightSpacer = [[UIView alloc] initWithFrame:rightSpacerFrame];
        
        CGRect rightToolbarHolderFrame = CGRectMake(CGRectGetWidth(self.frame) - (WPEditorToolbarButtonWidth + CGRectGetWidth(self.rightToolbarDivider.frame) + CGRectGetWidth(rightSpacer.frame)),
                                                    0.0f,
                                                    WPEditorToolbarButtonWidth + CGRectGetWidth(self.rightToolbarDivider.frame) + CGRectGetWidth(rightSpacer.frame),
                                                    WPEditorToolbarHeight);
        rightToolbarHolder = [[UIView alloc] initWithFrame:rightToolbarHolderFrame];
        rightToolbarHolder.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        rightToolbarHolder.clipsToBounds = YES;
        
        CGRect toolbarFrame = CGRectMake(CGRectGetMaxX(rightSpacer.frame),
                                         0.0f,
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
        if ([WPDeviceIdentification isIPhoneSixPlus]) {
            negativeSeparator.width = -kNegativeSixPlusRightToolbarPadding;
        } else {
            negativeSeparator.width = -kNegativeRightToolbarPadding;
        }
        
        toolbar.items = @[negativeSeparator, [self htmlBarButtonItem]];
        toolbar.barTintColor = self.backgroundColor;
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
