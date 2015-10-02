#import "WPEditorViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <UIKit/UIKit.h>
#import <WordPressCom-Analytics-iOS/WPAnalytics.h>
#import <WordPress-iOS-Shared/WPFontManager.h>
#import <WordPress-iOS-Shared/WPStyleGuide.h>
#import <WordPress-iOS-Shared/WPTableViewCell.h>
#import <WordPress-iOS-Shared/UIImage+Util.h>
#import <WordPress-iOS-Shared/UIColor+Helpers.h>

#import "WPEditorField.h"
#import "WPEditorToolbarButton.h"
#import "WPEditorToolbarView.h"
#import "WPEditorView.h"
#import "WPImageMeta.h"
#import "ZSSBarButtonItem.h"

#import "WPDeviceIdentification.h"

CGFloat const EPVCStandardOffset = 10.0;
NSInteger const WPImageAlertViewTag = 91;
NSInteger const WPLinkAlertViewTag = 92;

@interface WPEditorViewController () <HRColorPickerViewControllerDelegate, UIAlertViewDelegate, WPEditorToolbarViewDelegate, WPEditorViewDelegate>

@property (nonatomic, strong) NSString *htmlString;
@property (nonatomic, strong) NSArray *editorItemsEnabled;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) NSString *selectedImageURL;
@property (nonatomic, strong) NSString *selectedImageAlt;
@property (nonatomic) BOOL didFinishLoadingEditor;
@property (nonatomic, weak) WPEditorField* focusedField;

#pragma mark - Properties: First Setup On View Will Appear
@property (nonatomic, assign, readwrite) BOOL isFirstSetupComplete;

#pragma mark - Properties: Editing
@property (nonatomic, assign, readwrite, getter=isEditingEnabled) BOOL editingEnabled;
@property (nonatomic, assign, readwrite, getter=isEditing) BOOL editing;
@property (nonatomic, assign, readwrite) BOOL wasEditing;

#pragma mark - Properties: Editor View
@property (nonatomic, strong, readwrite) WPEditorView *editorView;

#pragma mark - Properties: Toolbar
@property (nonatomic, strong, readwrite) WPEditorToolbarView* toolbarView;

@end

@implementation WPEditorViewController

#pragma mark - Initializers

- (instancetype)init
{
	return [self initWithMode:kWPEditorViewControllerModeEdit];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	if (self)
	{
		[self sharedInitializationWithEditing:YES];
	}
	
	return self;
}

- (instancetype)initWithMode:(WPEditorViewControllerMode)mode
{
	self = [super init];
	
	if (self) {
		
		BOOL editing = NO;
		
		if (mode == kWPEditorViewControllerModePreview) {
			editing = NO;
		} else {
			editing = YES;
		}
		
		[self sharedInitializationWithEditing:editing];
	}
	
	return self;
}

#pragma mark - Shared Initialization Code

- (void)sharedInitializationWithEditing:(BOOL)editing
{
	if (editing == kWPEditorViewControllerModePreview) {
		_editing = NO;
	} else {
		_editing = YES;
	}
}

#pragma mark - Creation of subviews

- (void)createToolbarView
{
    NSAssert(!_toolbarView, @"The toolbar view should not exist here.");
    
    CGRect toolbarFrame = CGRectMake(0,
                                     0,
                                     CGRectGetWidth(self.view.frame),
                                     [WPEditorToolbarView height]);
    
    _toolbarView = [[WPEditorToolbarView alloc] initWithFrame:toolbarFrame];
    _toolbarView.delegate = self;
    _toolbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _toolbarView.borderColor = [WPStyleGuide greyLighten10];
    _toolbarView.itemTintColor = [WPStyleGuide greyLighten10];
    _toolbarView.selectedItemTintColor = [WPStyleGuide baseDarkerBlue];
    
    // Explicit design decision to use non-standard colors. See:
    // https://github.com/wordpress-mobile/WordPress-Editor-iOS/issues/657#issuecomment-113651034
    _toolbarView.backgroundColor = [UIColor colorWithHexString:@"F9FBFC"];
    _toolbarView.disabledItemTintColor = [UIColor colorWithRed:0.78
                                                         green:0.84
                                                          blue:0.88
                                                         alpha:0.5];
    /////
    
    _toolbarView.items = [self itemsForToolbar];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // It's important to set this up here, in case the main view of the VC is unloaded due to low
    // memory (it can happen if the view is hidden).
    //
    self.isFirstSetupComplete = NO;
    self.didFinishLoadingEditor = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Calling the fonts we use here so they are availible to the UIWebView
    [WPFontManager merriweatherBoldFontOfSize:16.0];
    [WPFontManager merriweatherBoldItalicFontOfSize:16.0];
    [WPFontManager merriweatherItalicFontOfSize:16.0];
    [WPFontManager merriweatherLightFontOfSize:16.0];
    [WPFontManager merriweatherRegularFontOfSize:16.0];
    [WPFontManager openSansRegularFontOfSize:16.0];
    [WPFontManager openSansItalicFontOfSize:16.0];
    [WPFontManager openSansBoldFontOfSize:16.0];
    [WPFontManager openSansBoldItalicFontOfSize:16.0];
	
    [self createToolbarView];
    [self buildTextViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    if (!self.isFirstSetupComplete) {
        self.isFirstSetupComplete = YES;

        // When restoring state, the navigationController is nil when the view loads,
        // so configure its appearance here instead.
        self.navigationController.navigationBar.translucent = NO;
        
        for (UIView *view in self.navigationController.toolbar.subviews) {
            [view setExclusiveTouch:YES];
        }
        
        if (self.isEditing) {
            [self startEditing];
        }
    }
    
    [self.navigationController setToolbarHidden:YES animated:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFirstSetupComplete) {
        [self restoreEditSelection];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // It's important to save the edit selection before the view disappears, because as soon as it
    // disappears the first responder is changed.
    //
    [self saveEditSelection];
}

#pragma mark - Toolbar items

- (NSMutableArray *)itemsForToolbar
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
	
    if ([self.toolbarView hasSomeEnabledToolbarItems]) {
		if ([self canShowInsertImageBarButton]) {
			[items addObject:[self insertImageBarButton]];
		}
		
		if ([self canShowBoldBarButton]) {
			[items addObject:[self boldBarButton]];
		}
		
		if ([self canShowItalicBarButton]) {
			[items addObject:[self italicBarButton]];
		}
		
		if ([self canShowSubscriptBarButton]) {
			[items addObject:[self subscriptBarButton]];
		}
		
		if ([self canShowSuperscriptBarButton]) {
			[items addObject:[self superscriptBarButton]];
		}
		
		if ([self canShowStrikeThroughBarButton]) {
			[items addObject:[self strikeThroughBarButton]];
		}
		
		if ([self canShowUnderlineBarButton]) {
			[items addObject:[self underlineBarButton]];
		}
		
		if (!IS_IPAD && [self canShowBlockQuoteBarButton]) {
			[items addObject:[self blockQuoteBarButton]];
		}
		
		if ([self canShowRemoveFormatBarButton]) {
			[items addObject:[self removeFormatBarButton]];
		}
		
		if ([self canShowUndoBarButton]) {
			[items addObject:[self undoBarButton]];
		}
		
		if ([self canShowRedoBarButton]) {
			[items addObject:[self redoBarButton]];
		}
		
		if ([self canShowAlignLeftBarButton]) {
			[items addObject:[self alignLeftBarButton]];
		}
		
		if ([self canShowAlignCenterBarButton]) {
			[items addObject:[self alignCenterBarButton]];
		}
		
		if ([self canShowAlignRightBarButton]) {
			[items addObject:[self alignRightBarButton]];
		}
		
		if ([self canShowAlignFullBarButton]) {
			[items addObject:[self alignFullBarButton]];
		}
		
		if ([self canShowHeader1BarButton]) {
			[items addObject:[self header1BarButton]];
		}
		
		if ([self canShowHeader2BarButton]) {
			[items addObject:[self header2BarButton]];
		}
		
		if ([self canShowHeader3BarButton]) {
			[items addObject:[self header3BarButton]];
		}
		
		if ([self canShowHeader4BarButton]) {
			[items addObject:[self header4BarButton]];
		}
		
		if ([self canShowHeader5BarButton]) {
			[items addObject:[self header5BarButton]];
		}
		
		if ([self canShowHeader6BarButton]) {
			[items addObject:[self header6BarButton]];
		}
		
		if ([self canShowTextColorBarButton]) {
			[items addObject:[self textColorBarButton]];
		}
		
		if ([self canShowBackgroundColorBarButton]) {
			[items addObject:[self backgroundColorBarButton]];
		}
        
        if (IS_IPAD && [self canShowInsertLinkBarButton]) {
            [items addObject:[self inserLinkBarButton]];
        }
		
		if ([self canShowUnorderedListBarButton]) {
			[items addObject:[self unorderedListBarButton]];
		}
		
		if ([self canShowOrderedListBarButton]) {
			[items addObject:[self orderedListBarButton]];
		}
		
		if ([self canShowHorizontalRuleBarButton]) {
			[items addObject:[self horizontalRuleBarButton]];
		}
		
		if ([self canShowIndentBarButton]) {
			[items addObject:[self indentBarButton]];
		}
		
		if ([self canShowOutdentBarButton]) {
			[items addObject:[self outdentBarButton]];
		}
		
		if (!IS_IPAD && [self canShowInsertLinkBarButton]) {
			[items addObject:[self inserLinkBarButton]];
		}
        
        if (IS_IPAD && [self canShowBlockQuoteBarButton]) {
            [items addObject:[self blockQuoteBarButton]];
        }
		
		if ([self canShowRemoveLinkBarButton]) {
			[items addObject:[self removeLinkBarButton]];
		}
		
		if ([self canShowQuickLinkBarButton]) {
			[items addObject:[self quickLinkBarButton]];
		}
		
		if ([self canShowSourceBarButton]) {
			[items addObject:[self showSourceBarButton]];
		}
	}
		
	return items;
}

#pragma mark - Toolbar: helper methods

- (void)clearToolbar
{
    if (!self.editorView.isInVisualMode) {
        [self.toolbarView clearSelectedToolbarItems];
    }
}

- (BOOL)canShowToolbarOption:(ZSSRichTextEditorToolbar)toolbarOption
{
    return [self.toolbarView canShowToolbarOption:toolbarOption];
}

- (BOOL)canShowAlignLeftBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarJustifyLeft];
}

- (BOOL)canShowAlignCenterBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarJustifyCenter];
}

- (BOOL)canShowAlignFullBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarJustifyFull];
}

- (BOOL)canShowAlignRightBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarJustifyRight];
}

- (BOOL)canShowBackgroundColorBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarBackgroundColor];
}

- (BOOL)canShowBlockQuoteBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarBlockQuote];
}

- (BOOL)canShowBoldBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarBold];
}

- (BOOL)canShowHeader1BarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarH1];
}

- (BOOL)canShowHeader2BarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarH2];
}

- (BOOL)canShowHeader3BarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarH3];
}

- (BOOL)canShowHeader4BarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarH4];
}

- (BOOL)canShowHeader5BarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarH5];
}

- (BOOL)canShowHeader6BarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarH6];
}

- (BOOL)canShowHorizontalRuleBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarHorizontalRule];
}

- (BOOL)canShowIndentBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarIndent];
}

- (BOOL)canShowInsertImageBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarInsertImage];
}

- (BOOL)canShowInsertLinkBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarInsertLink];
}

- (BOOL)canShowItalicBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarItalic];
}

- (BOOL)canShowOrderedListBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarOrderedList];
}

- (BOOL)canShowOutdentBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarOutdent];
}

- (BOOL)canShowQuickLinkBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarQuickLink];
}

- (BOOL)canShowRedoBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarRedo];
}

- (BOOL)canShowRemoveFormatBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarRemoveFormat];
}

- (BOOL)canShowRemoveLinkBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarRemoveLink];
}

- (BOOL)canShowSourceBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarViewSource];
}

- (BOOL)canShowStrikeThroughBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarStrikeThrough];
}

- (BOOL)canShowSubscriptBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarSubscript];
}

- (BOOL)canShowSuperscriptBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarSuperscript];
}

- (BOOL)canShowTextColorBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarTextColor];
}

- (BOOL)canShowUnderlineBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarUnderline];
}

- (BOOL)canShowUndoBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarUndo];
}

- (BOOL)canShowUnorderedListBarButton
{
	return [self canShowToolbarOption:ZSSRichTextEditorToolbarUnorderedList];
}

#pragma mark - Toolbar: buttons

- (ZSSBarButtonItem*)barButtonItemWithTag:(WPEditorViewControllerElementTag)tag
							 htmlProperty:(NSString*)htmlProperty
								imageName:(NSString*)imageName
								   target:(id)target
								 selector:(SEL)selector
					   accessibilityLabel:(NSString*)accessibilityLabel
{
    return [self.toolbarView barButtonItemWithTag:tag
                                     htmlProperty:htmlProperty
                                        imageName:imageName
                                           target:target
                                         selector:selector
                               accessibilityLabel:accessibilityLabel];
}

- (ZSSBarButtonItem*)alignLeftBarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagJustifyLeftBarButton
													htmlProperty:@"justifyLeft"
													   imageName:@"ZSSleftjustify.png"
														  target:self
														selector:@selector(alignLeft)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)alignCenterBarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagJustifyCenterBarButton
													htmlProperty:@"justifyCenter"
													   imageName:@"ZSScenterjustify.png"
														  target:self
														selector:@selector(alignCenter)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)alignFullBarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagJustifyFullBarButton
													htmlProperty:@"justifyFull"
													   imageName:@"ZSSforcejustify.png"
														  target:self
														selector:@selector(alignFull)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)alignRightBarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagJustifyRightBarButton
													htmlProperty:@"justifyRight"
													   imageName:@"ZSSrightjustify.png"
														  target:self
														selector:@selector(alignRight)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)backgroundColorBarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagBackgroundColorBarButton
													htmlProperty:@"backgroundColor"
													   imageName:@"ZSSbgcolor.png"
														  target:self
														selector:@selector(bgColor)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)blockQuoteBarButton
{
	NSString* accessibilityLabel = NSLocalizedString(@"Block Quote",
													 @"Accessibility label for block quote button on formatting toolbar.");
	
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagBlockQuoteBarButton
													htmlProperty:@"blockquote"
													   imageName:@"icon_format_quote"
														  target:self
														selector:@selector(setBlockQuote)
											  accessibilityLabel:accessibilityLabel];
	
	return barButtonItem;
}

- (UIBarButtonItem*)boldBarButton
{
	NSString* accessibilityLabel = NSLocalizedString(@"Bold",
													 @"Accessibility label for bold button on formatting toolbar.");
	
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagBoldBarButton
													htmlProperty:@"bold"
													   imageName:@"icon_format_bold"
														  target:self
														selector:@selector(setBold)
											  accessibilityLabel:accessibilityLabel];
	
	return barButtonItem;
}

- (UIBarButtonItem*)header1BarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagH1BarButton
													htmlProperty:@"h1"
													   imageName:@"ZSSh1.png"
														  target:self
														selector:@selector(heading1)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)header2BarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagH2BarButton
													htmlProperty:@"h2"
													   imageName:@"ZSSh2.png"
														  target:self
														selector:@selector(heading2)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)header3BarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagH3BarButton
													htmlProperty:@"h3"
													   imageName:@"ZSSh3.png"
														  target:self
														selector:@selector(heading3)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)header4BarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagH4BarButton
													htmlProperty:@"h4"
													   imageName:@"ZSSh4.png"
														  target:self
														selector:@selector(heading4)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)header5BarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagH5BarButton
													htmlProperty:@"h5"
													   imageName:@"ZSSh5.png"
														  target:self
														selector:@selector(heading5)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)header6BarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagH6BarButton
													htmlProperty:@"h6"
													   imageName:@"ZSSh6.png"
														  target:self
														selector:@selector(heading6)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}
		
- (UIBarButtonItem*)horizontalRuleBarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagHorizontalRuleBarButton
													htmlProperty:@"horizontalRule"
													   imageName:@"ZSShorizontalrule.png"
														  target:self
														selector:@selector(setHR)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)indentBarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagIndentBarButton
													htmlProperty:@"indent"
													   imageName:@"ZSSindent.png"
														  target:self
														selector:@selector(setIndent)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)insertImageBarButton
{
	NSString* accessibilityLabel = NSLocalizedString(@"Insert Image",
													 @"Accessibility label for insert image button on formatting toolbar.");
	
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagInsertImageBarButton
													htmlProperty:@"image"
													   imageName:@"icon_format_media"
														  target:self
														selector:@selector(didTouchMediaOptions)
											  accessibilityLabel:accessibilityLabel];
	
	return barButtonItem;
}

- (UIBarButtonItem*)inserLinkBarButton
{
	NSString* accessibilityLabel = NSLocalizedString(@"Insert Link",
													 @"Accessibility label for insert link button on formatting toolbar.");
	
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagInsertLinkBarButton
													htmlProperty:@"link"
													   imageName:@"icon_format_link"
														  target:self
														selector:@selector(linkBarButtonTapped:)
											  accessibilityLabel:accessibilityLabel];
	
	return barButtonItem;
}

- (UIBarButtonItem*)italicBarButton
{
	NSString* accessibilityLabel = NSLocalizedString(@"Italic",
													 @"Accessibility label for italic button on formatting toolbar.");
	
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTagItalicBarButton
													htmlProperty:@"italic"
													   imageName:@"icon_format_italic"
														  target:self
														selector:@selector(setItalic)
											  accessibilityLabel:accessibilityLabel];
	
	return barButtonItem;
}

- (UIBarButtonItem*)orderedListBarButton
{
	NSString* accessibilityLabel = NSLocalizedString(@"Ordered List",
													 @"Accessibility label for ordered list button on formatting toolbar.");
	
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementOrderedListBarButton
													htmlProperty:@"orderedList"
													   imageName:@"icon_format_ol"
														  target:self
														selector:@selector(setOrderedList)
											  accessibilityLabel:accessibilityLabel];
	
	return barButtonItem;
}

- (UIBarButtonItem*)outdentBarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementOutdentBarButton
													htmlProperty:@"outdent"
													   imageName:@"ZSSoutdent.png"
														  target:self
														selector:@selector(setOutdent)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)quickLinkBarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementQuickLinkBarButton
													htmlProperty:@"quickLink"
													   imageName:@"ZSSquicklink.png"
														  target:self
														selector:@selector(quickLink)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)redoBarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementRedoBarButton
												  htmlProperty:@"redo"
													 imageName:@"ZSSredo.png"
														target:self
														selector:@selector(redo:)
											accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)removeFormatBarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementRemoveFormatBarButton
													htmlProperty:@"removeFormat"
													   imageName:@"ZSSclearstyle.png"
														  target:self
														selector:@selector(removeFormat)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)removeLinkBarButton
{
	NSString* accessibilityLabel = NSLocalizedString(@"Remove Link",
													 @"Accessibility label for remove link button on formatting toolbar.");
	
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementRemoveFormatBarButton
													htmlProperty:@"link"
													   imageName:@"icon_format_unlink"
														  target:self
														selector:@selector(removeLink)
											  accessibilityLabel:accessibilityLabel];
	
	return barButtonItem;
}

- (UIBarButtonItem*)showSourceBarButton
{
    NSString* accessibilityLabel = NSLocalizedString(@"HTML",
                                                     @"Accessibility label for HTML button on formatting toolbar.");
    
    ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementShowSourceBarButton
													htmlProperty:@"source"
													   imageName:@"icon_format_html"
														  target:self
														selector:@selector(showHTMLSource:)
											  accessibilityLabel:accessibilityLabel];
	
	return barButtonItem;
}

- (UIBarButtonItem*)strikeThroughBarButton
{
	NSString* accessibilityLabel = NSLocalizedString(@"Strike Through",
													 @"Accessibility label for strikethrough button on formatting toolbar.");
	
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementStrikeThroughBarButton
													htmlProperty:@"strikeThrough"
													   imageName:@"icon_format_strikethrough"
														  target:self
														selector:@selector(setStrikethrough)
											  accessibilityLabel:accessibilityLabel];
	
	return barButtonItem;
}

- (UIBarButtonItem*)subscriptBarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementSubscriptBarButton
													htmlProperty:@"subscript"
													   imageName:@"ZSSsubscript.png"
														  target:self
														selector:@selector(setSubscript)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)superscriptBarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementSuperscriptBarButton
													htmlProperty:@"superscript"
													   imageName:@"ZSSsuperscript.png"
														  target:self
														selector:@selector(setSuperscript)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)textColorBarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementTextColorBarButton
													htmlProperty:@"textColor"
													   imageName:@"ZSStextcolor.png"
														  target:self
														selector:@selector(textColor)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

- (UIBarButtonItem*)underlineBarButton
{
	NSString* accessibilityLabel = NSLocalizedString(@"Underline",
													 @"Accessibility label for underline button on formatting toolbar.");
	
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementUnderlineBarButton
													htmlProperty:@"underline"
													   imageName:@"icon_format_underline"
														  target:self
														selector:@selector(setUnderline)
											  accessibilityLabel:accessibilityLabel];
	
	return barButtonItem;
}

- (UIBarButtonItem*)unorderedListBarButton
{
	NSString* accessibilityLabel = NSLocalizedString(@"Unordered List",
													 @"Accessibility label for unordered list button on formatting toolbar.");
	
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementUnorderedListBarButton
													htmlProperty:@"unorderedList"
													   imageName:@"icon_format_ul"
														  target:self
														selector:@selector(setUnorderedList)
											  accessibilityLabel:accessibilityLabel];
	
	return barButtonItem;
}

- (UIBarButtonItem*)undoBarButton
{
	ZSSBarButtonItem *barButtonItem = [self barButtonItemWithTag:kWPEditorViewControllerElementUndoBarButton
													htmlProperty:@"undo"
													   imageName:@"ZSSundo.png"
														  target:self
														selector:@selector(undo:)
											  accessibilityLabel:nil];
	
	return barButtonItem;
}

#pragma mark - Builders

- (void)buildTextViews
{
    if (!self.editorView) {
        CGFloat viewWidth = CGRectGetWidth(self.view.frame);
        UIViewAutoresizing mask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        CGRect frame = CGRectMake(0.0, 0.0, viewWidth, CGRectGetHeight(self.view.frame));
        
        self.editorView = [[WPEditorView alloc] initWithFrame:frame];
        self.editorView.delegate = self;
        self.editorView.autoresizesSubviews = YES;
        self.editorView.autoresizingMask = mask;
        self.editorView.backgroundColor = [UIColor whiteColor];
        self.editorView.sourceView.inputAccessoryView = self.toolbarView;
        self.editorView.sourceViewTitleField.inputAccessoryView = self.toolbarView;
        
        // Default placeholder text
        self.titlePlaceholderText = NSLocalizedString(@"Post title",  @"Placeholder for the post title.");
        self.bodyPlaceholderText = NSLocalizedString(@"Share your story here...", @"Placeholder for the post body.");
    }
	
    [self.view addSubview:self.editorView];
}

#pragma mark - Getters and Setters

- (NSString*)titleText
{    
    return [self.editorView title];
}

- (void)setTitleText:(NSString*)titleText
{
    [self.editorView.titleField setText:titleText];
    [self.editorView.sourceViewTitleField setText:titleText];
}

- (void)setTitlePlaceholderText:(NSString*)titlePlaceholderText
{
    NSParameterAssert(titlePlaceholderText);
    if (![titlePlaceholderText isEqualToString:_titlePlaceholderText]) {
        _titlePlaceholderText = titlePlaceholderText;
        [self.editorView.titleField setPlaceholderText:_titlePlaceholderText];
        self.editorView.sourceViewTitleField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_titlePlaceholderText
                                                                                                     attributes:@{NSForegroundColorAttributeName: [WPStyleGuide allTAllShadeGrey]}];
    }
}

- (NSString*)bodyText
{
    return [self.editorView contents];
}

- (void)setBodyText:(NSString*)bodyText
{
    [self.editorView.contentField setHtml:bodyText];
}

- (void)setBodyPlaceholderText:(NSString*)bodyPlaceholderText
{
    NSParameterAssert(bodyPlaceholderText);
    if (![bodyPlaceholderText isEqualToString:_bodyPlaceholderText]) {
        _bodyPlaceholderText = bodyPlaceholderText;
        [self.editorView.contentField setPlaceholderText:_bodyPlaceholderText];
    }
}

#pragma mark - Actions

- (void)didTouchMediaOptions
{
    if (self.editorView.isInVisualMode) {
        if ([self.delegate respondsToSelector: @selector(editorDidPressMedia:)]) {
            [self.delegate editorDidPressMedia:self];
        }
    } else {
        // Do not allow users to insert images in HTML mode for now
        __weak __typeof(self)weakSelf = self;
        [UIAlertView showWithTitle:NSLocalizedString(@"Unable to insert image", @"Title of dialog notifing user they cannot insert an image in the editor's HTML mode.")
                           message:NSLocalizedString(@"You cannot insert images while editing HTML directly. Please switch back to visual mode.", @"Body of dialog notifing user they cannot insert an image in the editor's HTML mode.")
                 cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              [weakSelf clearToolbar];
                          }
         ];
    }
    [WPAnalytics track:WPAnalyticsStatEditorTappedImage];
}

#pragma mark - Editor and Misc Methods

- (BOOL)isBodyTextEmpty
{
    if(!self.bodyText
       || self.bodyText.length == 0
       || [[self.bodyText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]
       || [[self.bodyText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"<br>"]
       || [[self.bodyText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"<br />"]) {
        return YES;
    }
    return NO;
}

#pragma mark - Editing

/**
 *	@brief		Enables editing.
 */
- (void)enableEditing
{
	self.editingEnabled = YES;
	
	if (self.didFinishLoadingEditor)
	{
		[self.editorView enableEditing];
	}
}

/**
 *	@brief		Disables editing.
 */
- (void)disableEditing
{
	self.editingEnabled = NO;
	
	if (self.didFinishLoadingEditor)
	{
		[self.editorView disableEditing];
	}
}

/**
 *  @brief      Restored the previously saved edit selection.
 *  @details    Will only really do anything if editing is enabled.
 */
- (void)restoreEditSelection
{
    if (self.isEditing) {
        if ([WPDeviceIdentification isiOSVersionEarlierThan8]){
            [self.focusedField blur];
            [self.focusedField focus];
        }
        [self.editorView restoreSelection];
    }
}

/**
 *  @brief      Saves the current edit selection, if any.
 */
- (void)saveEditSelection
{
    if (self.isEditing) {
        if ([WPDeviceIdentification isiOSVersionEarlierThan8]){
            self.focusedField = self.editorView.focusedField;
        }
        [self.editorView saveSelection];
    }
}

- (void)startEditing
{
	self.editing = YES;
	
	// We need the editor ready before executing the steps in the conditional block below.
	// If it's not ready, this method will be called again on webViewDidFinishLoad:
	//
	if (self.didFinishLoadingEditor)
	{
        [self enableEditing];
		[self tellOurDelegateEditingDidBegin];
	}
}

- (void)stopEditing
{
	self.editing = NO;
	
	[self disableEditing];
	[self tellOurDelegateEditingDidEnd];
}

#pragma mark - WPEditorToolbarViewDelegate

- (void)editorToolbarView:(WPEditorToolbarView *)editorToolbarView
           showHTMLSource:(UIBarButtonItem *)barButtonItem
{
    [self showHTMLSource:barButtonItem];
}

#pragma mark - Editor Interaction

- (void)showHTMLSource:(UIBarButtonItem *)barButtonItem
{	
    if ([self.editorView isInVisualMode]) {
        if ([self askOurDelegateShouldDisplaySourceView]) {
            [self.editorView showHTMLSource];
            barButtonItem.tintColor = [self barButtonItemSelectedDefaultColor];
        } else {
            // Deselect the HTML button so it is in the proper state
            [(UIButton *)barButtonItem setSelected:NO];
        }
    } else {
		[self.editorView showVisualEditor];
		
        barButtonItem.tintColor = [self.toolbarView itemTintColor];
    }
    
    [WPAnalytics track:WPAnalyticsStatEditorTappedHTML];
}

- (void)removeFormat
{
    [self.editorView removeFormat];
}

- (void)alignLeft
{
    [self.editorView alignLeft];
}

- (void)alignCenter
{
    [self.editorView alignCenter];
}

- (void)alignRight
{
    [self.editorView alignRight];
}

- (void)alignFull
{
    [self.editorView alignFull];
}

- (void)setBold
{
    [self.editorView setBold];
    [self clearToolbar];
    [WPAnalytics track:WPAnalyticsStatEditorTappedBold];
}

- (void)setBlockQuote
{
    [self.editorView setBlockQuote];
    [self clearToolbar];
    [WPAnalytics track:WPAnalyticsStatEditorTappedBlockquote];
}

- (void)setItalic
{
    [self.editorView setItalic];
    [self clearToolbar];
    [WPAnalytics track:WPAnalyticsStatEditorTappedItalic];
}

- (void)setSubscript
{
    [self.editorView setSubscript];
}

- (void)setUnderline
{
	[self.editorView setUnderline];
    [self clearToolbar];
    [WPAnalytics track:WPAnalyticsStatEditorTappedUnderline];
}

- (void)setSuperscript
{
	[self.editorView setSuperscript];
}

- (void)setStrikethrough
{
    [self.editorView setStrikethrough];
    [self clearToolbar];
    [WPAnalytics track:WPAnalyticsStatEditorTappedStrikethrough];
}

- (void)setUnorderedList
{
    [self.editorView setUnorderedList];
    [self clearToolbar];
    [WPAnalytics track:WPAnalyticsStatEditorTappedUnorderedList];
}

- (void)setOrderedList
{
    [self.editorView setOrderedList];
    [self clearToolbar];
    [WPAnalytics track:WPAnalyticsStatEditorTappedOrderedList];
}

- (void)setHR
{
    [self.editorView setHR];
}

- (void)setIndent
{
    [self.editorView setIndent];
}

- (void)setOutdent
{
    [self.editorView setOutdent];
}

- (void)heading1
{
	[self.editorView heading1];
}

- (void)heading2
{
    [self.editorView heading2];
}

- (void)heading3
{
    [self.editorView heading3];
}

- (void)heading4
{
	[self.editorView heading4];
}

- (void)heading5
{
	[self.editorView heading5];
}

- (void)heading6
{
	[self.editorView heading6];
}

- (void)textColor
{
    // Save the selection location
	[self.editorView saveSelection];

    // Call the picker
    HRColorPickerViewController *colorPicker = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:[UIColor whiteColor]];
    colorPicker.delegate = self;
    colorPicker.tag = 1;
    colorPicker.title = NSLocalizedString(@"Text Color", nil);
    [self.navigationController pushViewController:colorPicker animated:YES];
}

- (void)bgColor
{
    // Save the selection location
	[self.editorView saveSelection];
    
    // Call the picker
    HRColorPickerViewController *colorPicker = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:[UIColor whiteColor]];
    colorPicker.delegate = self;
    colorPicker.tag = 2;
    colorPicker.title = NSLocalizedString(@"BG Color", nil);
    [self.navigationController pushViewController:colorPicker animated:YES];
}

- (void)setSelectedColor:(UIColor*)color tag:(int)tag
{
    [self.editorView setSelectedColor:color tag:tag];
}

- (void)undo:(ZSSBarButtonItem *)barButtonItem
{
    [self.editorView undo];
}

- (void)redo:(ZSSBarButtonItem *)barButtonItem
{
    [self.editorView redo];
}

- (void)linkBarButtonTapped:(WPEditorToolbarButton*)button
{
	if ([self.editorView isSelectionALink]) {
		[self removeLink];
	} else {
		[self showInsertLinkDialogWithLink:self.editorView.selectedLinkURL
									 title:[self.editorView selectedText]];
		[WPAnalytics track:WPAnalyticsStatEditorTappedLink];
	}
}

- (void)showInsertLinkDialogWithLink:(NSString*)url
							   title:(NSString*)title
{
    
	BOOL isInsertingNewLink = (url == nil);
	
	if (!url) {
		NSURL* pasteboardUrl = [self urlFromPasteboard];
		
		url = [pasteboardUrl absoluteString];
	}
	
	NSString *insertButtonTitle = isInsertingNewLink ? NSLocalizedString(@"Insert", nil) : NSLocalizedString(@"Update", nil);
	NSString *removeButtonTitle = isInsertingNewLink ? nil : NSLocalizedString(@"Remove Link", nil);
	
	self.alertView = [[UIAlertView alloc] initWithTitle:insertButtonTitle
												message:nil
											   delegate:self
									  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
									  otherButtonTitles:insertButtonTitle, removeButtonTitle, nil];
	
	// The reason why we're setting a login & password style, is that it's the only style that
	// supports having two edit fields.  We'll customize the password field to behave as we want.
	//
    self.alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    self.alertView.tag = WPLinkAlertViewTag;
	
	UITextField *linkURL = [self.alertView textFieldAtIndex:0];
	
	linkURL.clearButtonMode = UITextFieldViewModeAlways;
	linkURL.placeholder = NSLocalizedString(@"URL", nil);
	
    if (url) {
        linkURL.text = url;
    }
	
	UITextField *linkNameTextField = [self.alertView textFieldAtIndex:1];
	
	linkNameTextField.clearButtonMode = UITextFieldViewModeAlways;
	linkNameTextField.placeholder = NSLocalizedString(@"Link Name", nil);
	linkNameTextField.secureTextEntry = NO;
	linkNameTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	linkNameTextField.autocorrectionType = UITextAutocorrectionTypeDefault;
	linkNameTextField.spellCheckingType = UITextSpellCheckingTypeDefault;
	
	if (title) {
		linkNameTextField.text = title;
	}
	
    __weak __typeof(self) weakSelf = self;

    self.alertView.willPresentBlock = ^(UIAlertView* alertView) {
        
        [weakSelf.editorView saveSelection];
        [weakSelf.editorView endEditing];
    };
	
	self.alertView.didDismissBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
		[weakSelf.editorView restoreSelection];
		
		if (alertView.tag == WPLinkAlertViewTag) {
			if (buttonIndex == 1) {
				NSString *linkURL = [alertView textFieldAtIndex:0].text;
				NSString *linkTitle = [alertView textFieldAtIndex:1].text;
                
				if ([linkTitle length] == 0) {
					linkTitle = linkURL;
				}
                
				if (isInsertingNewLink) {
					[weakSelf insertLink:linkURL title:linkTitle];
				} else {
					[weakSelf updateLink:linkURL title:linkTitle];
				}
			} else if (buttonIndex == 2) {
				[weakSelf removeLink];
			}
		}
    };
	
    self.alertView.shouldEnableFirstOtherButtonBlock = ^BOOL(UIAlertView *alertView) {
		if (alertView.tag == WPLinkAlertViewTag) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            if ([textField.text length] == 0) {
                return NO;
            }
        }
        return YES;
    };
    
    [self.alertView show];
}

- (void)insertLink:(NSString *)url
			 title:(NSString*)title
{
	[self.editorView insertLink:url title:title];
}

- (void)updateLink:(NSString *)url
			 title:(NSString*)title
{
	[self.editorView updateLink:url title:title];
}

- (void)dismissAlertView
{
    [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:YES];
}

- (void)removeLink
{
    [self.editorView removeLink];
    [WPAnalytics track:WPAnalyticsStatEditorTappedUnlink];
}

- (void)quickLink
{
    [self.editorView quickLink];
}

- (void)insertImage:(NSString *)url alt:(NSString *)alt
{
    [self.editorView insertImage:url alt:alt];
}

- (void)updateImage:(NSString *)url alt:(NSString *)alt
{
    [self.editorView updateImage:url alt:alt];
}

#pragma mark - UIPasteboard interaction

/**
 *	@brief		Returns an URL from the general pasteboard.
 *
 *	@param		The URL or nil if no valid URL is found.
 */
- (NSURL*)urlFromPasteboard
{
	NSURL* url = nil;
	
	UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
	
	NSString* const kURLPasteboardType = (__bridge NSString*)kUTTypeURL;
	NSString* const kTextPasteboardType = (__bridge NSString*)kUTTypeText;
	
	if ([pasteboard containsPasteboardTypes:@[kURLPasteboardType]]) {
		url = [pasteboard valueForPasteboardType:kURLPasteboardType];
	} else if ([pasteboard containsPasteboardTypes:@[kTextPasteboardType]]) {
		NSString* urlString = [pasteboard valueForPasteboardType:kTextPasteboardType];
		
        url = [self urlFromStringOnlyIfValid:urlString];
	}
	
	return url;
}

/**
 *	@brief		Validates a URL.
 *	@details	The validations we perform here are pretty basic.  But the idea of having this
 *				method is to add any additional checks we want to perform, as we come up with them.
 *
 *	@parameter	url		The URL to validate.  You will usually call [NSURL URLWithString] to create
 *						this URL from a string, before passing it to this method.  Cannot be nil.
 */
- (BOOL)isURLValid:(NSURL*)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);
    
    return url && url.scheme && url.host;
}

/**
 *  @brief      Returns the url from a string only if the final URL is valid.
 *
 *  @param      urlString       The url string to normalize.  Cannot be nil.
 *
 *  @returns    The normalized URL.
 */
- (NSURL*)urlFromStringOnlyIfValid:(NSString*)urlString
{
    NSParameterAssert([urlString isKindOfClass:[NSString class]]);
    
    if ([urlString hasPrefix:@"www"]) {
        urlString = [self.editorView normalizeURL:urlString];
    }
    
    NSURL* prevalidatedUrl = [NSURL URLWithString:urlString];
    NSURL* url = nil;
    
    if (prevalidatedUrl && [self isURLValid:prevalidatedUrl]) {
        url = prevalidatedUrl;
    }
    
    return url;
}

#pragma mark - WPEditorViewDelegate

- (void)editorTextDidChange:(WPEditorView*)editorView
{
	if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
		[self.delegate editorTextDidChange:self];
	}
}

- (void)editorTitleDidChange:(WPEditorView *)editorView
{
    if ([self.delegate respondsToSelector: @selector(editorTitleDidChange:)]) {
        [self.delegate editorTitleDidChange:self];
    }
}

- (void)editorViewDidFinishLoadingDOM:(WPEditorView*)editorView
{
	// DRM: the reason why we're doing is when the DOM finishes loading, instead of when the full
	// content finishe loading, is that the content may not finish loading at all when the device is
	// offline and the content has remote subcontent (such as pictures).
	//
    self.didFinishLoadingEditor = YES;
    
	if (self.editing) {
		[self startEditing];
	} else {
		[self.editorView disableEditing];
	}
    
    [self tellOurDelegateEditorDidFinishLoadingDOM];
}

- (void)editorView:(WPEditorView*)editorView
      fieldCreated:(WPEditorField*)field
{
    if (field == self.editorView.titleField) {
        field.inputAccessoryView = self.toolbarView;
        
        [field setRightToLeftTextEnabled:[self isCurrentLanguageDirectionRTL]];
        [field setMultiline:NO];
        [field setPlaceholderColor:[WPStyleGuide allTAllShadeGrey]];
        [field setPlaceholderText:self.titlePlaceholderText];
        self.editorView.sourceViewTitleField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.titlePlaceholderText
                                                                                                     attributes:@{NSForegroundColorAttributeName: [WPStyleGuide allTAllShadeGrey]}];
    } else if (field == self.editorView.contentField) {
        field.inputAccessoryView = self.toolbarView;
        
        [field setRightToLeftTextEnabled:[self isCurrentLanguageDirectionRTL]];
        [field setMultiline:YES];
        [field setPlaceholderText:self.bodyPlaceholderText];
        [field setPlaceholderColor:[WPStyleGuide allTAllShadeGrey]];
    }
    
    if ([self.delegate respondsToSelector:@selector(editorViewController:fieldCreated:)]) {
        [self.delegate editorViewController:self fieldCreated:field];
    }
}

- (void)editorView:(WPEditorView*)editorView
      fieldFocused:(WPEditorField*)field
{
    if (field == self.editorView.titleField) {
        [self.toolbarView enableToolbarItems:NO shouldShowSourceButton:YES];
        [self tellOurDelegateFormatBarStatusHasChanged:NO];
    } else if (field == self.editorView.contentField) {
        [self.toolbarView enableToolbarItems:YES shouldShowSourceButton:YES];
        [self tellOurDelegateFormatBarStatusHasChanged:YES];
    }
}

- (void)editorView:(WPEditorView*)editorView sourceFieldFocused:(UIView*)view
{
    [self.toolbarView enableToolbarItems:NO shouldShowSourceButton:YES];
    
    // Enable the toolbar if the HTML editor has focus
    if (view == self.editorView.sourceView) {
        [self.toolbarView enableToolbarItems:YES shouldShowSourceButton:YES];
    } else {
        [self.toolbarView enableToolbarItems:NO shouldShowSourceButton:YES];
    }
}

- (BOOL)editorView:(WPEditorView*)editorView
		linkTapped:(NSURL *)url
			 title:(NSString*)title
{
	if (self.isEditing) {
        [self showInsertLinkDialogWithLink:url.absoluteString
                                     title:title];
	} else {
		[[UIApplication sharedApplication] openURL:url];
	}
	
	return YES;
}

- (void)editorView:(WPEditorView*)editorView
       imageTapped:(NSString *)imageId
               url:(NSURL *)url
         imageMeta:(WPImageMeta *)imageMeta
{
    if ([self.delegate respondsToSelector:@selector(editorViewController:imageTapped:url:imageMeta:)]) {
        [self.delegate editorViewController:self imageTapped:imageId url:url imageMeta:imageMeta];
    }
}

- (BOOL)editorView:(WPEditorView*)editorView
       imageTapped:(NSString *)imageId
               url:(NSURL *)url
{
    if ([self.delegate respondsToSelector:@selector(editorViewController:imageTapped:url:)]) {
        [self.delegate editorViewController:self imageTapped:imageId url:url];
    }
    return YES;
}

- (void)editorView:(WPEditorView*)editorView
       videoTapped:(NSString *)videoId
               url:(NSURL *)url
{
    if ([self.delegate respondsToSelector:@selector(editorViewController:videoTapped:url:)]) {
        [self.delegate editorViewController:self videoTapped:videoId url:url];
    }
}

- (void)editorView:(WPEditorView*)editorView
       imageReplaced:(NSString *)imageId
{
    if ([self.delegate respondsToSelector:@selector(editorViewController:imageReplaced:)]) {
        [self.delegate editorViewController:self imageReplaced:imageId];
    }
}

- (void)editorView:(WPEditorView*)editorView
     videoReplaced:(NSString *)videoId
{
    if ([self.delegate respondsToSelector:@selector(editorViewController:videoReplaced:)]) {
        [self.delegate editorViewController:self videoReplaced:videoId];
    }
}

- (void)editorView:(WPEditorView *)editorView videoPressInfoRequest:(NSString *)videoPressID
{
    if ([self.delegate respondsToSelector:@selector(editorViewController:videoPressInfoRequest:)]) {
        [self.delegate editorViewController:self videoPressInfoRequest:videoPressID];
    }

}

- (void)editorView:(WPEditorView *)editorView mediaRemoved:(NSString *)mediaID
{
    if ([self.delegate respondsToSelector:@selector(editorViewController:mediaRemoved:)]) {
        [self.delegate editorViewController:self mediaRemoved:mediaID];
    }
    
}

- (void)editorView:(WPEditorView*)editorView stylesForCurrentSelection:(NSArray*)styles
{
    self.editorItemsEnabled = styles;
	
	[self.toolbarView selectToolbarItemsForStyles:styles];
}


#ifdef DEBUG
-      (void)webView:(UIWebView *)webView
didFailLoadWithError:(NSError *)error
{
	DDLogError(@"Loading error: %@", error);
	NSAssert(NO,
			 @"This should never happen since the editor is a local HTML page of our own making.");
}
#endif

#pragma mark - Asset Picker

- (void)showInsertURLAlternatePicker
{
    // Blank method. User should implement this in their subclass
	NSAssert(NO, @"Blank method. User should implement this in their subclass");
}

- (void)showInsertImageAlternatePicker
{
    // Blank method. User should implement this in their subclass
	NSAssert(NO, @"Blank method. User should implement this in their subclass");
}

#pragma mark - Utilities

- (UIColor *)barButtonItemDefaultColor
{
    if (self.toolbarView.itemTintColor) {
        return self.toolbarView.itemTintColor;
    }
    
    return [WPStyleGuide allTAllShadeGrey];
}

- (UIColor *)barButtonItemSelectedDefaultColor
{
    if (self.toolbarView.selectedItemTintColor) {
        return self.toolbarView.selectedItemTintColor;
    }
    return [WPStyleGuide wordPressBlue];
}

- (BOOL)isCurrentLanguageDirectionRTL
{
    return ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft);
}

#pragma mark - Delegate calls

- (void)tellOurDelegateEditingDidBegin
{
	NSAssert(self.isEditing,
			 @"Can't call this delegate method if not editing.");
	
	if ([self.delegate respondsToSelector: @selector(editorDidBeginEditing:)]) {
		[self.delegate editorDidBeginEditing:self];
	}
}

- (void)tellOurDelegateEditingDidEnd
{
	NSAssert(!self.isEditing,
			 @"Can't call this delegate method if editing.");
	
	if ([self.delegate respondsToSelector: @selector(editorDidEndEditing:)]) {
		[self.delegate editorDidEndEditing:self];
	}
}

- (void)tellOurDelegateEditorDidFinishLoadingDOM
{
    if ([self.delegate respondsToSelector:@selector(editorDidFinishLoadingDOM:)]) {
        [self.delegate editorDidFinishLoadingDOM:self];
    }
}

- (BOOL)askOurDelegateShouldDisplaySourceView
{
    if ([self.delegate respondsToSelector:@selector(editorShouldDisplaySourceView:)]) {
        return [self.delegate editorShouldDisplaySourceView:self];
    }
    return YES;
}

- (void)tellOurDelegateFormatBarStatusHasChanged:(BOOL)isEnabled
{
    if ([self.delegate respondsToSelector:@selector(editorFormatBarStatusChanged:enabled:)]) {
        [self.delegate editorFormatBarStatusChanged:self enabled:isEnabled];
    }
}

@end
