#import "WPEditorViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>
#import <WordPressComAnalytics/WPAnalytics.h>
#import <WordPressShared/WPFontManager.h>
#import <WordPressShared/WPStyleGuide.h>
#import <WordPressShared/WPTableViewCell.h>
#import <WordPressShared/UIImage+Util.h>
#import <WordPressShared/UIColor+Helpers.h>
#import <WordPressShared/WPDeviceIdentification.h>

#import "WPEditorField.h"
#import "WPEditorToolbarButton.h"
#import "WPEditorView.h"
#import "WPImageMeta.h"
#import "WPEditorFormatbarView.h"
#import "ZSSBarButtonItem.h"

CGFloat const EPVCStandardOffset = 10.0;
NSInteger const WPImageAlertViewTag = 91;
NSInteger const WPLinkAlertViewTag = 92;

@interface WPEditorViewController () <HRColorPickerViewControllerDelegate, WPEditorFormatbarViewDelegate, WPEditorViewDelegate>

@property (nonatomic, strong) NSString *htmlString;
@property (nonatomic, strong) NSArray *editorItemsEnabled;
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

@property (nonatomic, strong, readwrite) WPEditorFormatbarView* toolbarView;

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

    NSBundle *editorBundle = [NSBundle bundleForClass:[WPEditorFormatbarView class]];
    _toolbarView = (WPEditorFormatbarView *)[[editorBundle loadNibNamed:NSStringFromClass([WPEditorFormatbarView class]) owner:nil options:nil] firstObject];
    _toolbarView.delegate = self;
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFirstSetupComplete) {
        [self restoreEditSelection];
    } else {
        // Note: Very important this is set here otherwise the post will not initially
        // load properly in the editor. Please be careful if you make a change here and
        // test the editor within WPiOS!
        self.isFirstSetupComplete = YES;
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

- (void)traitCollectionDidChange:(UITraitCollection *) previousTraitCollection
{
    [super traitCollectionDidChange: previousTraitCollection];
    [self recoverFromViewSizeChange];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self recoverFromViewSizeChange];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self.toolbarView setNeedsLayout];
}

#pragma mark - Toolbar: helper methods

- (void)clearToolbar
{
    if (!self.editorView.isInVisualMode) {
        [self.toolbarView clearSelectedToolbarItems];
    }
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
    [self.editorView title:^(NSString *title) {
        
    }];
    return @"";
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
    [self.editorView contents:^(NSString *contents) {
    }];
    return @"";
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
        NSString *title = NSLocalizedString(@"Unable to insert image",
                                            @"Title of dialog notifing user they cannot insert an image in the editor's HTML mode.");
        NSString *message = NSLocalizedString(@"You cannot insert images while editing HTML directly. Please switch back to visual mode.",
                                              @"Body of dialog notifing user they cannot insert an image in the editor's HTML mode.");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Label text to dismiss an alert view.") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [weakSelf clearToolbar];
        }];
        
        [alertController addAction:defaultAction];
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
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

#pragma mark - WPEditorFormatBarViewDelegate

- (void)editorToolbarView:(WPEditorFormatbarView *)editorToolbarView
           showHTMLSource:(UIBarButtonItem *)barButtonItem
{
    [self showHTMLSource:barButtonItem];
}

- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
              insertImage:(UIBarButtonItem *)barButtonItem
{
    [self didTouchMediaOptions];
}

- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
                  setBold:(UIBarButtonItem *)barButtonItem
{
    [self setBold];
}

- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
                setItalic:(UIBarButtonItem *)barButtonItem
{
    [self setItalic];
}

- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
            setBlockquote:(UIBarButtonItem *)barButtonItem
{
    [self setBlockQuote];
}

- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
         setUnorderedList:(UIBarButtonItem *)barButtonItem
{
    [self setUnorderedList];
}

- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
           setOrderedList:(UIBarButtonItem *)barButtonItem
{
    [self setOrderedList];
}

- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
           setStrikeThrough:(UIBarButtonItem *)barButtonItem
{
    [self setStrikethrough];
}

- (void)editorToolbarView:(WPEditorFormatbarView*)editorToolbarView
               insertLink:(UIBarButtonItem *)barButtonItem
{
    [self linkBarButtonTapped:(WPEditorToolbarButton *)barButtonItem];
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
        [self.editorView selectedText:^(NSString *text) {
            [self showInsertLinkDialogWithLink:self.editorView.selectedLinkURL
                                         title:text];
        }];
		[WPAnalytics track:WPAnalyticsStatEditorTappedLink];
	}
}

- (void)showInsertLinkDialogWithLink:(NSString*)url
							   title:(NSString*)title
{
    __weak __typeof(self) weakSelf = self;
    BOOL isInsertingNewLink = (url == nil);
    
    if (!url) {
        NSURL* pasteboardUrl = [self urlFromPasteboard];
        url = [pasteboardUrl absoluteString];
    }
    
    NSString *insertButtonTitle = isInsertingNewLink ? NSLocalizedString(@"Insert", nil) : NSLocalizedString(@"Update", nil);
    NSString *removeButtonTitle = NSLocalizedString(@"Remove Link", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", @"Cancel button");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:insertButtonTitle
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.placeholder = NSLocalizedString(@"URL", @"URL text field placeholder");
        
        if (url) {
            textField.text = url;
        }
        
        [textField addTarget:weakSelf
                      action:@selector(alertTextFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.placeholder = NSLocalizedString(@"Link Name", @"Link name field placeholder");
        textField.secureTextEntry = NO;
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.autocorrectionType = UITextAutocorrectionTypeDefault;
        textField.spellCheckingType = UITextSpellCheckingTypeDefault;
        
        if (title) {
            textField.text = title;
        }
    }];
    
    UIAlertAction* insertAction = [UIAlertAction actionWithTitle:insertButtonTitle
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [weakSelf.editorView restoreSelection];
                                                             
                                                             NSString *linkURL = alertController.textFields.firstObject.text;
                                                             NSString *linkTitle = alertController.textFields.lastObject.text;
                                                             
                                                             if ([linkTitle length] == 0) {
                                                                 linkTitle = linkURL;
                                                             }
                                                             
                                                             if (isInsertingNewLink) {
                                                                 [weakSelf insertLink:linkURL title:linkTitle];
                                                             } else {
                                                                 [weakSelf updateLink:linkURL title:linkTitle];
                                                             }
                                                         }];
    
    UIAlertAction* removeAction = [UIAlertAction actionWithTitle:removeButtonTitle
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * action) {
                                                             [weakSelf.editorView restoreSelection];
                                                             [weakSelf removeLink];
                                                         }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             [weakSelf.editorView restoreSelection];
                                                         }];
    
    [alertController addAction:insertAction];
    if (!isInsertingNewLink) {
        [alertController addAction:removeAction];
    }
    [alertController addAction:cancelAction];
    
    // Disabled until url is entered into field
    UITextField *urlField = alertController.textFields.firstObject;
    insertAction.enabled = urlField.text.length > 0;
    
    [self.editorView saveSelection];
    [self.editorView endEditing];
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

- (void)alertTextFieldDidChange:(UITextField *)sender
{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController)
    {
        UITextField *urlField = alertController.textFields.firstObject;
        UIAlertAction *insertAction = alertController.actions.firstObject;
        insertAction.enabled = urlField.text.length > 0;
    }
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
    [self.toolbarView enableToolbarItems:NO shouldShowSourceButton:YES];
    if (field == self.editorView.titleField) {
        [self.toolbarView enableToolbarItems:NO shouldShowSourceButton:YES];
        [self tellOurDelegateFormatBarStatusHasChanged:NO];
    } else {
        [self.toolbarView enableToolbarItems:YES shouldShowSourceButton:YES];
        [self tellOurDelegateFormatBarStatusHasChanged:YES];
    }
}

- (void)editorView:(WPEditorView*)editorView sourceFieldFocused:(UIView*)view
{
    if (view == self.editorView.sourceViewTitleField) {
        [self.toolbarView enableToolbarItems:NO shouldShowSourceButton:YES];
    } else {
        [self.toolbarView enableToolbarItems:YES shouldShowSourceButton:YES];
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

- (void)recoverFromViewSizeChange
{
    if (self.isFirstSetupComplete) {
        // Important: This is a complete and utter hack that compensates for the input accessory view
        // not properly changing size classes (resizing) when the rest of the views in the editor VC do.
        // Toggling the HTML button on the input bar quickly does not affect the view and forces the
        // input accessory view (the format bar) to update itself. FWIW, setNeedsDisplay and
        // setNeedsLayout do NOT work.
        if ([self.editorView isInVisualMode]) {
            [self.editorView showVisualEditor];
        } else {
            [self.editorView showHTMLSource];
        }
    }
}

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
