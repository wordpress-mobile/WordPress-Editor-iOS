#import "WPEditorViewController.h"
#import "WPEditorViewController_Internal.h"
#import <UIKit/UIKit.h>
#import <WordPress-iOS-Shared/WPStyleGuide.h>
#import <WordPress-iOS-Shared/WPTableViewCell.h>
#import <WordPress-iOS-Shared/UIImage+Util.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import "ZSSBarButtonItem.h"
#import "HRColorUtil.h"
#import "ZSSTextView.h"
#import "UIWebView+GUIFixes.h"
#import "WPInsetTextField.h"

CGFloat const EPVCTextfieldHeight = 44.0f;
CGFloat const EPVCStandardOffset = 10.0;
NSInteger const WPImageAlertViewTag = 91;
NSInteger const WPLinkAlertViewTag = 92;

@interface WPEditorViewController () <UIWebViewDelegate, HRColorPickerViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView *toolBarScroll;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) NSString *htmlString;
@property (nonatomic, strong) ZSSTextView *sourceView;
@property (assign) BOOL resourcesLoaded;
@property (nonatomic, strong) NSString *editorPlaceholderText;
@property (nonatomic, strong) NSArray *editorItemsEnabled;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) NSString *selectedLinkURL;
@property (nonatomic, strong) NSString *selectedLinkTitle;
@property (nonatomic, strong) NSString *selectedImageURL;
@property (nonatomic, strong) NSString *selectedImageAlt;
@property (nonatomic, strong) NSMutableArray *customBarButtonItems;
@property (nonatomic) BOOL didFinishLoadingEditor;

#pragma mark - Properties: Editability
@property (nonatomic, assign, readwrite, getter=isEditingEnabled) BOOL editingEnabled;
@property (nonatomic, assign, readwrite, getter=isEditing) BOOL editing;
@property (nonatomic, assign, readwrite) BOOL wasEditing;

#pragma mark - Properties: Editor View
@property (nonatomic, strong, readwrite) UIWebView *editorView;
@property (nonatomic, assign, readwrite) BOOL editorViewIsEditing;

#pragma mark - Properties: Title Text View
@property (nonatomic, strong) WPInsetTextField *titleTextField;

#pragma mark - Properties: Toolbar Holders
@property (nonatomic, strong) UIView *rightToolbarHolder;
@property (nonatomic, strong) UIView *toolbarHolder;

#pragma mark - Properties: Toolbar items
@property (nonatomic, strong, readwrite) UIBarButtonItem* htmlBarButtonItem;

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
		_editing = YES;
	}
	
	return self;
}

- (instancetype)initWithMode:(WPEditorViewControllerMode)mode
{
	self = [super init];
	
	if (self) {
		if (mode == kWPEditorViewControllerModePreview) {
			_editing = NO;
		} else {
			_editing = YES;
		}
	}
	
	return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.didFinishLoadingEditor = NO;
    
    // iPad gets the HTML source button
    if (IS_IPAD) {
        self.enabledToolbarItems = ZSSRichTextEditorToolbarInsertImage | ZSSRichTextEditorToolbarBold |
                                ZSSRichTextEditorToolbarItalic | ZSSRichTextEditorToolbarUnderline |
                                ZSSRichTextEditorToolbarBlockQuote | ZSSRichTextEditorToolbarInsertLink |
                                ZSSRichTextEditorToolbarUnorderedList | ZSSRichTextEditorToolbarOrderedList |
                                ZSSRichTextEditorToolbarRemoveLink | ZSSRichTextEditorToolbarViewSource;
    } else {
        self.enabledToolbarItems = ZSSRichTextEditorToolbarInsertImage | ZSSRichTextEditorToolbarBold |
                                ZSSRichTextEditorToolbarItalic | ZSSRichTextEditorToolbarUnderline |
                                ZSSRichTextEditorToolbarBlockQuote | ZSSRichTextEditorToolbarInsertLink |
                                ZSSRichTextEditorToolbarUnorderedList | ZSSRichTextEditorToolbarOrderedList |
                                ZSSRichTextEditorToolbarRemoveLink;
    }
    
    [self buildTextViews];
    [self buildToolbar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    [super viewWillAppear:animated];
	
    self.view.backgroundColor = [UIColor whiteColor];
    
    // When restoring state, the navigationController is nil when the view loads,
    // so configure its appearance here instead.
    self.navigationController.navigationBar.translucent = NO;

    UIToolbar *toolbar = self.navigationController.toolbar;
    toolbar.barTintColor = [WPStyleGuide itsEverywhereGrey];
    toolbar.translucent = NO;
    toolbar.barStyle = UIBarStyleDefault;
    
    for (UIView *view in self.navigationController.toolbar.subviews) {
        [view setExclusiveTouch:YES];
    }
    
	[self startObservingKeyboardNotifications];
	
	if (self.isEditing) {
		[self startEditing];
	}
	
    [self refreshUI];
    [self.titleTextField becomeFirstResponder];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	
	[self stopObservingKeyboardNotifications];
}

#pragma mark - Getters

- (UIBarButtonItem*)htmlBarButtonItem
{
	if (!_htmlBarButtonItem) {
		UIBarButtonItem* htmlBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"HTML"
																			   style:UIBarButtonItemStylePlain
																			  target:self
																			  action:@selector(showHTMLSource:)];
		
		UIFont * font = [UIFont boldSystemFontOfSize:10];
		NSDictionary * attributes = @{NSFontAttributeName: font};
		[htmlBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
		htmlBarButtonItem.accessibilityLabel = NSLocalizedString(@"Display HTML",
																 @"Accessibility label for display HTML button on formatting toolbar.");
		
		UIButton* customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
		[customButton setTitle:@"HTML" forState:UIControlStateNormal];
		[customButton setTitleColor:self.barButtonItemDefaultColor forState:UIControlStateNormal];
		customButton.font = font;
		htmlBarButtonItem.customView = customButton;
		
		_htmlBarButtonItem = htmlBarButtonItem;
	}
	
	return _htmlBarButtonItem;
}

- (UIView*)rightToolbarHolder
{
	if (!_rightToolbarHolder) {
		
		UIView *rightToolbarHolder = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-44, 0, 44, 44)];
		rightToolbarHolder.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		rightToolbarHolder.clipsToBounds = YES;
		
		UIToolbar *htmlItemToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
		[rightToolbarHolder addSubview:htmlItemToolbar];
		
		static int kiPodToolbarMarginWidth = 16;
		
		UIBarButtonItem *negativeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
																						   target:nil
																						   action:nil];
		negativeSeparator.width = -kiPodToolbarMarginWidth;
		
		htmlItemToolbar.items = @[negativeSeparator, [self htmlBarButtonItem]];
		htmlItemToolbar.barTintColor = [WPStyleGuide itsEverywhereGrey];
		
		UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.6f, 44)];
		line.backgroundColor = [UIColor lightGrayColor];
		line.alpha = 0.7f;
		[rightToolbarHolder addSubview:line];

		_rightToolbarHolder = rightToolbarHolder;
	}
	
	return _rightToolbarHolder;
}

#pragma mark - Keyboard notifications

- (void)startObservingKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)stopObservingKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Toolbar

- (void)setEnabledToolbarItems:(ZSSRichTextEditorToolbar)enabledToolbarItems
{
    _enabledToolbarItems = enabledToolbarItems;
    [self buildToolbar];
}

- (void)setToolbarItemTintColor:(UIColor *)toolbarItemTintColor
{
    _toolbarItemTintColor = toolbarItemTintColor;
    
    // Update the color
    for (ZSSBarButtonItem *item in self.toolbar.items) {
        item.tintColor = [self barButtonItemDefaultColor];
    }
	
    self.htmlBarButtonItem.tintColor = toolbarItemTintColor;
}

- (void)setToolbarItemSelectedTintColor:(UIColor *)toolbarItemSelectedTintColor
{
    _toolbarItemSelectedTintColor = toolbarItemSelectedTintColor;
}

- (BOOL)hasSomeEnabledToolbarItems
{
	return !(self.enabledToolbarItems & ZSSRichTextEditorToolbarNone);
}

- (NSArray *)itemsForToolbar
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    if ([self hasSomeEnabledToolbarItems]) {
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
		
		if ([self canShowBlockQuoteBarButton]) {
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
		
		if ([self canShowInsertLinkBarButton]) {
			[items addObject:[self inserLinkBarButton]];
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
		
    return [NSArray arrayWithArray:items];
}

#pragma mark - Toolbar: helper methods

- (BOOL)canShowToolbarOption:(ZSSRichTextEditorToolbar)toolbarOption
{
	return (self.enabledToolbarItems & toolbarOption
			|| self.enabledToolbarItems & ZSSRichTextEditorToolbarAll);
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

- (ZSSBarButtonItem*)alignLeftBarButton
{
	ZSSBarButtonItem *alignLeft = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSleftjustify.png"]
																	style:UIBarButtonItemStylePlain
																   target:self
																   action:@selector(alignLeft)];
	alignLeft.label = @"justifyLeft";
	
	return alignLeft;
}

- (ZSSBarButtonItem*)alignCenterBarButton
{
	ZSSBarButtonItem *alignCenter = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSScenterjustify.png"]
																	  style:UIBarButtonItemStylePlain
																	 target:self
																	 action:@selector(alignCenter)];
	alignCenter.label = @"justifyCenter";
	
	return alignCenter;
}

- (ZSSBarButtonItem*)alignFullBarButton
{
	ZSSBarButtonItem *alignFull = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSforcejustify.png"]
																	style:UIBarButtonItemStylePlain
																   target:self
																   action:@selector(alignFull)];
	alignFull.label = @"justifyFull";
	
	return alignFull;
}

- (ZSSBarButtonItem*)alignRightBarButton
{
	ZSSBarButtonItem *alignRight = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSrightjustify.png"]
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(alignRight)];
	alignRight.label = @"justifyRight";
	
	return alignRight;
}

- (ZSSBarButtonItem*)backgroundColorBarButton
{
	ZSSBarButtonItem *bgColor = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSbgcolor.png"]
																  style:UIBarButtonItemStylePlain
																 target:self
																 action:@selector(bgColor)];
	bgColor.label = @"backgroundColor";
	
	return bgColor;
}

- (ZSSBarButtonItem*)blockQuoteBarButton
{
	ZSSBarButtonItem *blockQuote = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_format_quote"]
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(setBlockQuote)];
	blockQuote.label = @"blockQuote";
	blockQuote.accessibilityLabel = NSLocalizedString(@"Block Quote",
													  @"Accessibility label for block quote button on formatting toolbar.");
	
	return blockQuote;
}

- (ZSSBarButtonItem*)boldBarButton
{
	ZSSBarButtonItem *bold = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_format_bold"]
															   style:UIBarButtonItemStylePlain
															  target:self
															  action:@selector(setBold)];
	bold.label = @"bold";
	bold.accessibilityLabel = NSLocalizedString(@"Bold",
												@"Accessibility label for bold button on formatting toolbar.");
	
	return bold;
}

- (ZSSBarButtonItem*)header1BarButton
{
	ZSSBarButtonItem *h1 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh1.png"]
															 style:UIBarButtonItemStylePlain
															target:self
															action:@selector(heading1)];
	h1.label = @"h1";
	
	return h1;
}

- (ZSSBarButtonItem*)header2BarButton
{
	ZSSBarButtonItem *h2 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh2.png"]
															 style:UIBarButtonItemStylePlain
															target:self
															action:@selector(heading2)];
	h2.label = @"h2";
	
	return h2;
}

- (ZSSBarButtonItem*)header3BarButton
{
	ZSSBarButtonItem *h3 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh3.png"]
															 style:UIBarButtonItemStylePlain
															target:self
															action:@selector(heading3)];
	h3.label = @"h3";
	
	return h3;
}

- (ZSSBarButtonItem*)header4BarButton
{
	ZSSBarButtonItem *h4 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh4.png"]
															 style:UIBarButtonItemStylePlain
															target:self
															action:@selector(heading4)];
	h4.label = @"h4";
	
	return h4;
}

- (ZSSBarButtonItem*)header5BarButton
{
	ZSSBarButtonItem *h5 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh5.png"]
															 style:UIBarButtonItemStylePlain
															target:self
															action:@selector(heading5)];
	h5.label = @"h5";
	
	return h5;
}

- (ZSSBarButtonItem*)header6BarButton
{
	ZSSBarButtonItem *h6 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh6.png"]
															 style:UIBarButtonItemStylePlain
															target:self
															action:@selector(heading6)];
	h6.label = @"h6";
	
	return h6;
}
		
- (ZSSBarButtonItem*)horizontalRuleBarButton
{
	ZSSBarButtonItem *hr = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSShorizontalrule.png"]
															 style:UIBarButtonItemStylePlain
															target:self
															action:@selector(setHR)];
	hr.label = @"horizontalRule";
	
	return hr;
}

- (ZSSBarButtonItem*)indentBarButton
{
	ZSSBarButtonItem *indent = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSindent.png"]
																 style:UIBarButtonItemStylePlain
																target:self
																action:@selector(setIndent)];
	indent.label = @"indent";
	
	return indent;
}

- (ZSSBarButtonItem*)insertImageBarButton
{
	ZSSBarButtonItem *insertImage = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_media"]
																	  style:UIBarButtonItemStylePlain
																	 target:self
																	 action:@selector(didTouchMediaOptions)];
	insertImage.label = @"image";
	insertImage.accessibilityLabel = NSLocalizedString(@"Insert Image",
													   @"Accessibility label for insert image button on formatting toolbar.");
	
	return insertImage;
}

- (ZSSBarButtonItem*)inserLinkBarButton
{
	ZSSBarButtonItem *insertLink = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_format_link"]
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(insertLink)];
	insertLink.label = @"link";
	insertLink.accessibilityLabel = NSLocalizedString(@"Insert Link",
													  @"Accessibility label for insert link button on formatting toolbar.");
	
	return insertLink;
}

- (ZSSBarButtonItem*)italicBarButton
{
	ZSSBarButtonItem *italic = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_format_italic"]
																 style:UIBarButtonItemStylePlain
																target:self
																action:@selector(setItalic)];
	italic.label = @"italic";
	italic.accessibilityLabel = NSLocalizedString(@"Italic",
												  @"Accessibility label for italic button on formatting toolbar.");
	
	return italic;
}

- (ZSSBarButtonItem*)orderedListBarButton
{
	ZSSBarButtonItem *ol = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSorderedlist.png"]
															 style:UIBarButtonItemStylePlain
															target:self
															action:@selector(setOrderedList)];
	ol.label = @"orderedList";
	ol.accessibilityLabel = NSLocalizedString(@"Ordered List", @"Accessibility label for ordered list button on formatting toolbar.");
	
	return ol;
}

- (ZSSBarButtonItem*)outdentBarButton
{
	ZSSBarButtonItem *outdent = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSoutdent.png"]
																  style:UIBarButtonItemStylePlain
																 target:self
																 action:@selector(setOutdent)];
	outdent.label = @"outdent";
	
	return outdent;
}

- (ZSSBarButtonItem*)quickLinkBarButton
{
	ZSSBarButtonItem *quickLink = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSquicklink.png"]
																	style:UIBarButtonItemStylePlain
																   target:self
																   action:@selector(quickLink)];
	quickLink.label = @"quickLink";
	
	return quickLink;
}

- (ZSSBarButtonItem*)redoBarButton
{
	ZSSBarButtonItem *redoButton = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSredo.png"]
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(redo:)];
	redoButton.label = @"redo";
	
	return redoButton;
}

- (ZSSBarButtonItem*)removeFormatBarButton
{
	ZSSBarButtonItem *removeFormat = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSclearstyle.png"]
																	   style:UIBarButtonItemStylePlain
																	  target:self
																	  action:@selector(removeFormat)];
	removeFormat.label = @"removeFormat";
	
	return removeFormat;
}

- (ZSSBarButtonItem*)removeLinkBarButton
{
	ZSSBarButtonItem *removeLink = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSunlink.png"]
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(removeLink)];
	removeLink.label = @"removeLink";
	removeLink.accessibilityLabel = NSLocalizedString(@"Remove Link", @"Accessibility label for remove link button on formatting toolbar.");
	
	return removeLink;
}

- (ZSSBarButtonItem*)showSourceBarButton
{
	ZSSBarButtonItem *showSource = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSviewsource.png"]
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(showHTMLSource:)];
	showSource.label = @"source";
	
	return showSource;
}

- (ZSSBarButtonItem*)strikeThroughBarButton
{
	ZSSBarButtonItem *strikeThrough = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_format_strikethrough"]
																		style:UIBarButtonItemStylePlain
																	   target:self
																	   action:@selector(setStrikethrough)];
	strikeThrough.label = @"strikeThrough";
	strikeThrough.accessibilityLabel = NSLocalizedString(@"Strike Through",
														 @"Accessibility label for strikethrough button on formatting toolbar.");
	
	return strikeThrough;
}

- (ZSSBarButtonItem*)subscriptBarButton
{
	ZSSBarButtonItem *subscript = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSsubscript.png"]
																	style:UIBarButtonItemStylePlain
																   target:self
																   action:@selector(setSubscript)];
	subscript.label = @"subscript";
	
	return subscript;
}

- (ZSSBarButtonItem*)superscriptBarButton
{
	ZSSBarButtonItem *superscript = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSsuperscript.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setSuperscript)];
	superscript.label = @"superscript";
	
	return superscript;
}

- (ZSSBarButtonItem*)textColorBarButton
{
	ZSSBarButtonItem *textColor = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSStextcolor.png"]
																	style:UIBarButtonItemStylePlain
																   target:self
																   action:@selector(textColor)];
	textColor.label = @"textColor";
	
	return textColor;
}

- (ZSSBarButtonItem*)underlineBarButton
{
	ZSSBarButtonItem *underline = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_format_underline"]
																	style:UIBarButtonItemStylePlain
																   target:self
																   action:@selector(setUnderline)];
	underline.label = @"underline";
	underline.accessibilityLabel = NSLocalizedString(@"Underline",
													 @"Accessibility label for underline button on formatting toolbar.");
	
	return underline;
}

- (ZSSBarButtonItem*)unorderedListBarButton
{
	ZSSBarButtonItem *ul = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSunorderedlist.png"]
															 style:UIBarButtonItemStylePlain
															target:self
															action:@selector(setUnorderedList)];
	ul.label = @"unorderedList";
	ul.accessibilityLabel = NSLocalizedString(@"Unordered List", @"Accessibility label for unordered list button on formatting toolbar.");
	
	return ul;
}

- (ZSSBarButtonItem*)undoBarButton
{
	ZSSBarButtonItem *undoButton = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSundo.png"]
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(undo:)];
	undoButton.label = @"undo";
	
	return undoButton;
}

#pragma mark - Builders

- (void)buildToolbar
{
    // Scrolling View
    if (!self.toolBarScroll) {
        self.toolBarScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, IS_IPAD ? self.view.frame.size.width : self.view.frame.size.width - 44, 44)];
        self.toolBarScroll.backgroundColor = [WPStyleGuide itsEverywhereGrey];
        self.toolBarScroll.showsHorizontalScrollIndicator = NO;
    }
    
    // Toolbar with icons
    if (!self.toolbar) {
        self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.toolbar.backgroundColor = [UIColor whiteColor];
    }
    [self.toolBarScroll addSubview:self.toolbar];
    self.toolBarScroll.autoresizingMask = self.toolbar.autoresizingMask;
    
    // Background Toolbar
    UIToolbar *backgroundToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    backgroundToolbar.backgroundColor = [UIColor whiteColor];
    backgroundToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Parent holding view
    self.toolbarHolder = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 44)];
    self.toolbarHolder.autoresizingMask = self.toolbar.autoresizingMask;
    self.toolbarHolder.backgroundColor = [UIColor whiteColor];
    [self.toolbarHolder addSubview:self.toolBarScroll];
    [self.toolbarHolder insertSubview:backgroundToolbar atIndex:0];
    
    if (!IS_IPAD) {
        [self.toolbarHolder addSubview:[self rightToolbarHolder]];
    }
	
	self.editorView.usesGUIFixes = YES;
	self.editorView.customInputAccessoryView = self.toolbarHolder;
	self.titleTextField.inputAccessoryView = self.toolbarHolder;
    
    // Check to see if we have any toolbar items, if not, add them all
    NSArray *items = [self itemsForToolbar];
    if (items.count == 0 && !(_enabledToolbarItems & ZSSRichTextEditorToolbarNone)) {
        _enabledToolbarItems = ZSSRichTextEditorToolbarAll;
        items = [self itemsForToolbar];
    }
    
    // get the width before we add custom buttons
    CGFloat toolbarWidth = items.count == 0 ? 0.0f : (CGFloat)(items.count * 55);
    
    if (self.customBarButtonItems != nil)
    {
        items = [items arrayByAddingObjectsFromArray:self.customBarButtonItems];
        for(ZSSBarButtonItem *buttonItem in self.customBarButtonItems)
        {
            toolbarWidth += buttonItem.customView.frame.size.width + 11.0f;
        }
    }
    for (ZSSBarButtonItem *item in items) {
        item.tintColor = [self barButtonItemDefaultColor];
    }
    self.toolbar.items = items;
    self.toolbar.frame = CGRectMake(0, 0, toolbarWidth, 44);
	self.toolbar.barTintColor = [WPStyleGuide itsEverywhereGrey];
    self.toolBarScroll.contentSize = CGSizeMake(self.toolbar.frame.size.width, 44);
}

- (void)buildTextViews
{
    if (!self.editorPlaceholderText) {
        NSString *placeholderText = NSLocalizedString(@"Write your story here ...", @"Placeholder for the main body text.");
        self.editorPlaceholderText = [NSString stringWithFormat:@"<div style=\"color:#A1BCCD;\">%@<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br></div>", placeholderText];
    }
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    UIViewAutoresizing mask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    CGRect frame = CGRectMake(0.0f, 0.0f, viewWidth, EPVCTextfieldHeight);
    
    // Title TextField.
    if (!self.titleTextField) {
        self.titleTextField = [[WPInsetTextField alloc] initWithFrame:frame];
        self.titleTextField.returnKeyType = UIReturnKeyDone;
        self.titleTextField.delegate = self;
        self.titleTextField.font = [WPStyleGuide postTitleFont];
        self.titleTextField.backgroundColor = [UIColor whiteColor];
        self.titleTextField.textColor = [WPStyleGuide bigEddieGrey];
        self.titleTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:(NSLocalizedString(@"Post title", @"Label for the title of the post field.")) attributes:(@{NSForegroundColorAttributeName: [WPStyleGuide textFieldPlaceholderGrey]})];
        self.titleTextField.accessibilityLabel = NSLocalizedString(@"Title", @"Post title");
        self.titleTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.titleTextField.returnKeyType = UIReturnKeyNext;
    }
    [self.view addSubview:self.titleTextField];
    
    // Editor View
    frame = CGRectMake(0.0f, frame.size.height, viewWidth, CGRectGetHeight(self.view.frame) - EPVCTextfieldHeight);
    if (!self.editorView) {
        self.editorView = [[UIWebView alloc] initWithFrame:frame];
        self.editorView.delegate = self;
        self.editorView.autoresizesSubviews = YES;
        self.editorView.autoresizingMask = mask;
        self.editorView.scalesPageToFit = YES;
        self.editorView.dataDetectorTypes = UIDataDetectorTypeNone;
        self.editorView.scrollView.bounces = NO;
        self.editorView.backgroundColor = [UIColor whiteColor];
    }
    [self.view addSubview:self.editorView];
    
    // Source View
    if (!self.sourceView) {
        self.sourceView = [[ZSSTextView alloc] initWithFrame:frame];
        self.sourceView.hidden = YES;
        self.sourceView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.sourceView.autocorrectionType = UITextAutocorrectionTypeNo;
        self.sourceView.autoresizingMask =  UIViewAutoresizingFlexibleHeight;
        self.sourceView.autoresizesSubviews = YES;
        self.sourceView.delegate = self;
    }
    [self.view addSubview:self.sourceView];
}

#pragma mark - Getters and Setters

- (NSString*)titleText
{
    return self.titleTextField.text;
}

- (void) setTitleText:(NSString*)titleText
{
    [self.titleTextField setText:titleText];
}

- (NSString*)bodyText
{
    return [self getHTML];
}

- (void) setBodyText:(NSString*)bodyText
{
    [self setHtml:bodyText];
    [self refreshUI];
}

#pragma mark - Actions

- (void)didTouchMediaOptions
{
    if ([self.delegate respondsToSelector: @selector(editorDidPressMedia:)]) {
        [self.delegate editorDidPressMedia:self];
    }
}

#pragma mark - UI Refreshing

- (void)refreshUI
{
    if (self.didFinishLoadingEditor) {
		
		if (!self.isEditing && [self isBodyTextEmpty]) {
			[self setHtml:self.editorPlaceholderText];
		}
    }
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

- (BOOL)isEditorPlaceholderTextVisible
{
    if([[self.bodyText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:self.editorPlaceholderText]) {
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
		[self enableEditingInHTMLEditor];
	}
}

- (void)enableEditingInHTMLEditor
{
	NSAssert(self.editingEnabled,
			 @"This method should not be called directly, unless you know editingEnabled is configured already.");
	
	NSString *js = [NSString stringWithFormat:@"zss_editor.enableEditing();"];
	[self.editorView stringByEvaluatingJavaScriptFromString:js];
}

/**
 *	@brief		Disables editing.
 */
- (void)disableEditing
{
	self.editingEnabled = NO;
	
	if (self.didFinishLoadingEditor)
	{
		[self disableEditingInHTMLEditor];
	}
}

- (void)disableEditingInHTMLEditor
{
	NSAssert(!self.editingEnabled,
			 @"This method should not be called directly, unless you know editingEnabled is configured already.");
	
	NSString *js = [NSString stringWithFormat:@"zss_editor.disableEditing();"];
	[self.editorView stringByEvaluatingJavaScriptFromString:js];
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
		
		[self.titleTextField becomeFirstResponder];

		[self tellOurDelegateEditingDidBegin];
	}
}

- (void)stopEditing
{
	self.editing = NO;
	
	[self disableEditing];
    [self dismissKeyboard];
    [self.view endEditing:YES];
	
	[self tellOurDelegateEditingDidEnd];
}

#pragma mark - Editor focus

- (void)focusTextEditor
{
    self.editorView.keyboardDisplayRequiresUserAction = NO;
    NSString *js = [NSString stringWithFormat:@"zss_editor.focusEditor();"];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}

- (void)blurTextEditor
{
    NSString *js = [NSString stringWithFormat:@"zss_editor.blurEditor();"];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark - Editor Interaction

// Sets the HTML for the entire editor
- (void)setHtml:(NSString *)html
{
    if (!self.resourcesLoaded) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"editor" ofType:@"html"];
        NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
        NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
        NSString *source = [[NSBundle mainBundle] pathForResource:@"ZSSRichTextEditor" ofType:@"js"];
        NSString *jsString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:source] encoding:NSUTF8StringEncoding];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!--editor-->" withString:jsString];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!--content-->" withString:html];
        
        [self.editorView loadHTMLString:htmlString baseURL:self.baseURL];
        self.resourcesLoaded = YES;
    }
    
    self.sourceView.text = html;
    NSString *cleanedHTML = [self removeQuotesFromHTML:self.sourceView.text];
	NSString *trigger = [NSString stringWithFormat:@"zss_editor.setHTML(\"%@\");", cleanedHTML];
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

// Inserts HTML at the caret position
- (void)insertHTML:(NSString *)html
{
    NSString *cleanedHTML = [self removeQuotesFromHTML:html];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertHTML(\"%@\");", cleanedHTML];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (NSString *)getHTML
{
    NSString *html = [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.getHTML();"];
//    html = [self removeQuotesFromHTML:html];
//    html = [self tidyHTML:html];
	return html;
}

- (void)dismissKeyboard
{
    [self.editorView stringByEvaluatingJavaScriptFromString:@"document.activeElement.blur()"];
    [self.sourceView resignFirstResponder];
    [self.view endEditing:YES];
}

- (void)showHTMLSource:(ZSSBarButtonItem *)barButtonItem
{
    if (self.sourceView.hidden) {
        self.sourceView.text = [self getHTML];
        self.sourceView.hidden = NO;
        barButtonItem.tintColor = [self barButtonItemSelectedDefaultColor];
        self.editorView.hidden = YES;
        [self enableToolbarItems:NO shouldShowSourceButton:YES];
    } else {
        [self setHtml:self.sourceView.text];
        barButtonItem.tintColor = [self barButtonItemDefaultColor];
        self.sourceView.hidden = YES;
        self.editorView.hidden = NO;
        [self enableToolbarItems:YES shouldShowSourceButton:YES];
    }
}

- (void)removeFormat
{
    NSString *trigger = @"zss_editor.removeFormating();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)alignLeft
{
    NSString *trigger = @"zss_editor.setJustifyLeft();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)alignCenter
{
    NSString *trigger = @"zss_editor.setJustifyCenter();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)alignRight
{
    NSString *trigger = @"zss_editor.setJustifyRight();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)alignFull
{
    NSString *trigger = @"zss_editor.setJustifyFull();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)setBold
{
    NSString *trigger = @"zss_editor.setBold();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)setBlockQuote
{
    NSString *trigger = @"zss_editor.setBlockquote();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)setItalic
{
    NSString *trigger = @"zss_editor.setItalic();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)setSubscript
{
    NSString *trigger = @"zss_editor.setSubscript();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)setUnderline
{
    NSString *trigger = @"zss_editor.setUnderline();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)setSuperscript
{
    NSString *trigger = @"zss_editor.setSuperscript();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)setStrikethrough
{
    NSString *trigger = @"zss_editor.setStrikeThrough();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)setUnorderedList
{
    NSString *trigger = @"zss_editor.setUnorderedList();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)setOrderedList
{
    NSString *trigger = @"zss_editor.setOrderedList();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)setHR
{
    NSString *trigger = @"zss_editor.setHorizontalRule();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)setIndent
{
    NSString *trigger = @"zss_editor.setIndent();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)setOutdent
{
    NSString *trigger = @"zss_editor.setOutdent();";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)heading1
{
    NSString *trigger = @"zss_editor.setHeading('h1');";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)heading2
{
    NSString *trigger = @"zss_editor.setHeading('h2');";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)heading3
{
    NSString *trigger = @"zss_editor.setHeading('h3');";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)heading4
{
    NSString *trigger = @"zss_editor.setHeading('h4');";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)heading5
{
    NSString *trigger = @"zss_editor.setHeading('h5');";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)heading6
{
    NSString *trigger = @"zss_editor.setHeading('h6');";
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)textColor
{
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    
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
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    
    // Call the picker
    HRColorPickerViewController *colorPicker = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:[UIColor whiteColor]];
    colorPicker.delegate = self;
    colorPicker.tag = 2;
    colorPicker.title = NSLocalizedString(@"BG Color", nil);
    [self.navigationController pushViewController:colorPicker animated:YES];
}

- (void)setSelectedColor:(UIColor*)color tag:(int)tag
{
    NSString *hex = [NSString stringWithFormat:@"#%06x",HexColorFromUIColor(color)];
    NSString *trigger;
    if (tag == 1) {
        trigger = [NSString stringWithFormat:@"zss_editor.setTextColor(\"%@\");", hex];
    } else if (tag == 2) {
        trigger = [NSString stringWithFormat:@"zss_editor.setBackgroundColor(\"%@\");", hex];
    }
	[self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)undo:(ZSSBarButtonItem *)barButtonItem
{
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.undo();"];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)redo:(ZSSBarButtonItem *)barButtonItem
{
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.redo();"];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)insertLink
{
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    
    // Show the dialog for inserting or editing a link
    [self showInsertLinkDialogWithLink:self.selectedLinkURL title:self.selectedLinkTitle];
}

- (void)showInsertLinkDialogWithLink:(NSString *)url title:(NSString *)title
{
    // Insert Button Title
    NSString *insertButtonTitle = !self.selectedLinkURL ? NSLocalizedString(@"Insert", nil) : NSLocalizedString(@"Update", nil);
    
    self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Insert Link", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:insertButtonTitle, nil];
    self.alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    self.alertView.tag = WPLinkAlertViewTag;
    UITextField *linkURL = [self.alertView textFieldAtIndex:0];
    linkURL.placeholder = NSLocalizedString(@"URL (required)", nil);
    if (url) {
        linkURL.text = url;
    }
    
    // Picker Button
    UIButton *am = [UIButton buttonWithType:UIButtonTypeCustom];
    am.frame = CGRectMake(0, 0, 25, 25);
    [am setImage:[UIImage imageNamed:@"ZSSpicker.png"] forState:UIControlStateNormal];
    [am addTarget:self action:@selector(showInsertURLAlternatePicker) forControlEvents:UIControlEventTouchUpInside];
    linkURL.rightView = am;
    linkURL.rightViewMode = UITextFieldViewModeAlways;
    
    __weak __typeof(self)weakSelf = self;
    self.alertView.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (alertView.tag == WPLinkAlertViewTag) {
            if (buttonIndex == 1) {
                UITextField *linkURL = [alertView textFieldAtIndex:0];
                if (!self.selectedLinkURL) {
                    [self insertLink:linkURL.text title:@""];
                } else {
                    [self updateLink:linkURL.text title:@""];
                }
            }
        }
        
        // Don't dismiss the keyboard
        // Hack from http://stackoverflow.com/a/7601631
        dispatch_async(dispatch_get_main_queue(), ^{
            if([weakSelf.editorView resignFirstResponder] || [weakSelf.titleTextField resignFirstResponder]){
                [weakSelf.editorView becomeFirstResponder];
            }
        });
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

- (void)insertLink:(NSString *)url title:(NSString *)title
{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertLink(\"%@\", \"%@\");", url, title];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)updateLink:(NSString *)url title:(NSString *)title
{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateLink(\"%@\", \"%@\");", url, title];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)dismissAlertView
{
    [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:YES];
}

- (void)addCustomToolbarItemWithButton:(UIButton *)button
{
    if(self.customBarButtonItems == nil)
    {
        self.customBarButtonItems = [NSMutableArray array];
    }
    
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:28.5f];
    [button setTitleColor:[self barButtonItemDefaultColor] forState:UIControlStateNormal];
    [button setTitleColor:[self barButtonItemSelectedDefaultColor] forState:UIControlStateHighlighted];
    
    ZSSBarButtonItem *barButtonItem = [[ZSSBarButtonItem alloc] initWithCustomView:button];
    [self.customBarButtonItems addObject:barButtonItem];
    
    [self buildToolbar];
}

- (void)removeLink
{
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.unlink();"];
}

- (void)quickLink
{
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.quickLink();"];
}

- (void)insertImage
{
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    
    [self showInsertImageDialogWithLink:self.selectedImageURL alt:self.selectedImageAlt];
}

- (void)showInsertImageDialogWithLink:(NSString *)url alt:(NSString *)alt
{    
    // Insert Button Title
    NSString *insertButtonTitle = !self.selectedImageURL ? NSLocalizedString(@"Insert", nil) : NSLocalizedString(@"Update", nil);
    
    self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Insert Image", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:insertButtonTitle, nil];
    self.alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    self.alertView.tag = WPImageAlertViewTag;
    UITextField *imageURL = [self.alertView textFieldAtIndex:0];
    imageURL.placeholder = NSLocalizedString(@"URL (required)", nil);
    if (url) {
        imageURL.text = url;
    }
    
    // Picker Button
    UIButton *am = [UIButton buttonWithType:UIButtonTypeCustom];
    am.frame = CGRectMake(0, 0, 25, 25);
    [am setImage:[UIImage imageNamed:@"ZSSpicker.png"] forState:UIControlStateNormal];
    [am addTarget:self action:@selector(showInsertImageAlternatePicker) forControlEvents:UIControlEventTouchUpInside];
    imageURL.rightView = am;
    imageURL.rightViewMode = UITextFieldViewModeAlways;
    imageURL.clearButtonMode = UITextFieldViewModeAlways;
    
    UITextField *alt1 = [self.alertView textFieldAtIndex:1];
    alt1.secureTextEntry = NO;
    UIView *test = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    test.backgroundColor = [UIColor redColor];
    alt1.rightView = test;
    alt1.placeholder = NSLocalizedString(@"Alt", nil);
    alt1.clearButtonMode = UITextFieldViewModeAlways;
    if (alt) {
        alt1.text = alt;
    }
    
    __weak __typeof(self)weakSelf = self;
    self.alertView.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (alertView.tag == WPImageAlertViewTag) {
            if (buttonIndex == 1) {
                UITextField *imageURL = [alertView textFieldAtIndex:0];
                UITextField *alt = [alertView textFieldAtIndex:1];
                if (!self.selectedImageURL) {
                    [self insertImage:imageURL.text alt:alt.text];
                } else {
                    [self updateImage:imageURL.text alt:alt.text];
                }
            }
        }
        
        // Don't dismiss the keyboard
        // Hack from http://stackoverflow.com/a/7601631
        dispatch_async(dispatch_get_main_queue(), ^{
            if([weakSelf.editorView resignFirstResponder] || [weakSelf.titleTextField resignFirstResponder]){
                [weakSelf.editorView becomeFirstResponder];
            }
        });
    };
    
    self.alertView.shouldEnableFirstOtherButtonBlock = ^BOOL(UIAlertView *alertView) {
        if (alertView.tag == WPImageAlertViewTag) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            UITextField *textField2 = [alertView textFieldAtIndex:1];
            if ([textField.text length] == 0 || [textField2.text length] == 0) {
                return NO;
            }
        }
        return YES;
    };
    
    [self.alertView show];
}

- (void)insertImage:(NSString *)url alt:(NSString *)alt
{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertImage(\"%@\", \"%@\");", url, alt];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)updateImage:(NSString *)url alt:(NSString *)alt
{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateImage(\"%@\", \"%@\");", url, alt];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)updateToolBarWithButtonName:(NSString *)name
{
    // Items that are enabled
    NSArray *itemNames = [name componentsSeparatedByString:@","];
    
    // Special case for link
    NSMutableArray *itemsModified = [[NSMutableArray alloc] init];
    for (NSString *linkItem in itemNames) {
        NSString *updatedItem = linkItem;
        if ([linkItem hasPrefix:@"link:"]) {
            updatedItem = @"link";
            self.selectedLinkURL = [linkItem stringByReplacingOccurrencesOfString:@"link:" withString:@""];
        } else if ([linkItem hasPrefix:@"link-title:"]) {
            self.selectedLinkTitle = [self stringByDecodingURLFormat:[linkItem stringByReplacingOccurrencesOfString:@"link-title:" withString:@""]];
        } else if ([linkItem hasPrefix:@"image:"]) {
            updatedItem = @"image";
            self.selectedImageURL = [linkItem stringByReplacingOccurrencesOfString:@"image:" withString:@""];
        } else if ([linkItem hasPrefix:@"image-alt:"]) {
            self.selectedImageAlt = [self stringByDecodingURLFormat:[linkItem stringByReplacingOccurrencesOfString:@"image-alt:" withString:@""]];
        } else {
            self.selectedImageURL = nil;
            self.selectedImageAlt = nil;
            self.selectedLinkURL = nil;
            self.selectedLinkTitle = nil;
        }
        [itemsModified addObject:updatedItem];
    }
    itemNames = [NSArray arrayWithArray:itemsModified];
    NSLog(@"%@", itemNames);
    self.editorItemsEnabled = itemNames;
    
    // Highlight items
    NSArray *items = self.toolbar.items;
    for (ZSSBarButtonItem *item in items) {
        if ([itemNames containsObject:item.label]) {
            item.tintColor = [self barButtonItemSelectedDefaultColor];
        } else {
            item.tintColor = [self barButtonItemDefaultColor];
        }
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	BOOL result = NO;
	
	if (self.editingEnabled)
	{
		result = YES;
	}
	
    return result;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (textField == self.titleTextField) {
		
		[self enableToolbarItems:NO shouldShowSourceButton:NO];
		
		[self refreshUI];
	}
}
    
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.titleTextField) {
        if ([self.delegate respondsToSelector: @selector(editorTitleDidChange:)]) {
            [self.delegate editorTitleDidChange:self];
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (textField == self.titleTextField) {
		[self refreshUI];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

#pragma mark - UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.didFinishLoadingEditor = YES;
	
	if (self.editing) {
		[self startEditing];
	} else {
		[self disableEditingInHTMLEditor];
	}
	
    [self refreshUI];
}

-            (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
			navigationType:(UIWebViewNavigationType)navigationType
{
	static NSString* const kCallbackScheme = @"callback";
	BOOL result = YES;
	
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		result = NO;
	} else {
		NSURL *url = [request URL];
		BOOL isCallbackURL = [[url scheme] isEqualToString:kCallbackScheme];
		
		if (isCallbackURL) {
			result = ![self handleWebViewCallbackURL:url];
		}
    }
    
    return result;
}

#pragma mark - UIWebView Delegate helpers

/**
 *	@brief		Handles UIWebView callbacks.
 *
 *	@param		url		The url for the callback.  Cannot be nil.
 *
 *	@returns	YES if the callback was handled, NO otherwise.
 */
- (BOOL)handleWebViewCallbackURL:(NSURL*)url
{
	NSAssert([url isKindOfClass:[NSURL class]],
			 @"Expected param url to be a non-nil, NSURL object.");
	
	BOOL result = NO;
	
	NSString* resourceSpecifier = [[url resourceSpecifier] stringByReplacingOccurrencesOfString:@"//" withString:@""];
	
	static NSString* kUserTriggeredChangeSpecifier = @"user-triggered-change";
	static NSString* kFocusInSpecifier = @"focusin";
	static NSString* kFocusOutSpecifier = @"focusout";
	
	if ([resourceSpecifier isEqualToString:kUserTriggeredChangeSpecifier]) {
		if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
			[self.delegate editorTextDidChange:self];
		}
		
		result = YES;
	} else if ([resourceSpecifier isEqualToString:kFocusInSpecifier]){
		
		self.editorViewIsEditing = YES;
		
		[self enableToolbarItems:YES shouldShowSourceButton:NO];
		
		result = YES;
	} else if ([resourceSpecifier isEqualToString:kFocusOutSpecifier]){

		self.editorViewIsEditing = NO;
		
		result = YES;
	} else {
		NSString *className = resourceSpecifier;
		[self updateToolBarWithButtonName:className];
		
		result = YES;
	}
	
	return result;
}

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


#pragma mark - Keyboard status

- (void)keyboardWillShow:(NSNotification *)notification
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSUInteger curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardHeight = UIInterfaceOrientationIsLandscape(orientation) ? keyboardEnd.size.width : keyboardEnd.size.height;
    UIViewAnimationOptions animationOptions = curve;
	
	// DRM: WORKAROUND: for some weird reason, we are receiving multiple UIKeyboardWillShow notifications.
	// We will simply ignore repeated notifications.
	//
	if (!self.isShowingKeyboard) {
		
		self.isShowingKeyboard = YES;
		
		// Hide the placeholder if visible before editing
		if (!self.titleTextField.isFirstResponder && [self isEditorPlaceholderTextVisible]) {
			[self setHtml:@""];
		}
		
		CGRect localizedKeyboardEnd = [self.view convertRect:keyboardEnd fromView:nil];
		CGPoint keyboardOrigin = localizedKeyboardEnd.origin;
		CGFloat vOffset = self.view.frame.size.height - keyboardOrigin.y;
		
		CGRect editorFrame = self.editorView.frame;
		editorFrame.size.height -= vOffset;
		
		CGRect sourceFrame = self.sourceView.frame;
		sourceFrame.size.height -= vOffset;
		
		[self setEditorFrame:editorFrame
				 sourceFrame:sourceFrame
					animated:YES
			animationOptions:animationOptions
					duration:duration];
	}
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSUInteger curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIViewAnimationOptions animationOptions = curve;
	
	// DRM: WORKAROUND: for some weird reason, we are receiving multiple UIKeyboardWillHide notifications.
	// We will simply ignore repeated notifications.
	//
	if (self.isShowingKeyboard) {

        self.isShowingKeyboard = NO;
        [self refreshUI];
		
		CGRect editorFrame = self.editorView.frame;
		editorFrame.size.height = self.view.frame.size.height - editorFrame.origin.y;
		
		CGRect sourceFrame = self.sourceView.frame;
		sourceFrame.size.height = self.view.frame.size.height - sourceFrame.origin.y;
		
		[self setEditorFrame:editorFrame
				 sourceFrame:sourceFrame
					animated:YES
			animationOptions:animationOptions
					duration:duration];
	}
}

#pragma mark - Editor frame

- (void)setEditorFrame:(CGRect)editorFrame
		   sourceFrame:(CGRect)sourceFrame
			  animated:(BOOL)animated
	  animationOptions:(UIViewAnimationOptions)animationOptions
			  duration:(CGFloat)duration
{
	__weak typeof(self) weakSelf = self;
	
	void (^privateSetFrames)(CGRect frame, CGRect sourceFrame) = ^void(CGRect editorFrame,
																	   CGRect sourceFrame)
	{
		weakSelf.editorView.frame = editorFrame;
		weakSelf.sourceView.frame = sourceFrame;
	};
	
	if (animated) {
		[UIView animateWithDuration:duration
							  delay:0
							options:animationOptions
						 animations:^{
			privateSetFrames(editorFrame, sourceFrame);
		} completion:nil];
	} else {
		privateSetFrames(editorFrame, sourceFrame);
	}
}

#pragma mark - Utilities

- (NSString *)removeQuotesFromHTML:(NSString *)html
{
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"“" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"”" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    return html;
}

- (NSString *)tidyHTML:(NSString *)html
{
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br />"];
    html = [html stringByReplacingOccurrencesOfString:@"<hr>" withString:@"<hr />"];
    if (self.formatHTML) {
        html = [self.editorView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"style_html(\"%@\");", html]];
    }
    return html;
}

- (UIColor *)barButtonItemDefaultColor
{
    if (self.toolbarItemTintColor) {
        return self.toolbarItemTintColor;
    }
    
    return [WPStyleGuide allTAllShadeGrey];
}

- (UIColor *)barButtonItemSelectedDefaultColor
{
    if (self.toolbarItemSelectedTintColor) {
        return self.toolbarItemSelectedTintColor;
    }
    return [WPStyleGuide newKidOnTheBlockBlue];
}

- (NSString *)stringByDecodingURLFormat:(NSString *)string
{
    NSString *result = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

- (void)enableToolbarItems:(BOOL)enable shouldShowSourceButton:(BOOL)showSource
{
    NSArray *items = self.toolbar.items;
	
    for (ZSSBarButtonItem *item in items) {
        if ([item.label isEqualToString:@"source"]) {
            item.enabled = showSource;
        } else {
            item.enabled = enable;
        }
    }
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


@end
