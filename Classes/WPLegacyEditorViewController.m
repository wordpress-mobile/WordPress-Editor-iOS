#import "WPLegacyEditorViewController.h"
#import "WPLegacyEditorFormatToolbar.h"
#import "WPLegacyEditorFormatAction.h"
#import <WordPressComAnalytics/WPAnalytics.h>

CGFloat const WPLegacyEPVCStandardOffset = 15.0;
CGFloat const WPLegacyEPVCTextViewOffset = 10.0;

@interface WPLegacyEditorViewController ()<UITextFieldDelegate, UITextViewDelegate, WPLegacyEditorFormatToolbarDelegate>

@property (nonatomic) CGPoint scrollOffsetRestorePoint;
@property (nonatomic, strong) UIButton *optionsButton;
@property (nonatomic, strong) UILabel *tapToStartWritingLabel;
@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIView *activeField;
@property (nonatomic, strong) WPLegacyEditorFormatToolbar *editorToolbar;
@property (nonatomic, strong) WPLegacyEditorFormatToolbar *titleToolbar;

@end

@implementation WPLegacyEditorViewController

-(instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit {
    _titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _titleColor = [UIColor darkTextColor];

    _bodyFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _bodyColor = [UIColor darkTextColor];

    _separatorColor = [UIColor lightGrayColor];
    _placeholderColor = [UIColor lightGrayColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeAppearance];
    [self setupTextView];
    [self.editorToolbar configureForHorizontalSizeClass:self.traitCollection.horizontalSizeClass];
    [self.titleToolbar configureForHorizontalSizeClass:self.traitCollection.horizontalSizeClass];
}

#pragma mark - Appearance
- (void)customizeAppearance
{
    self.navigationController.navigationBar.translucent = NO;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // When restoring state, the navigationController is nil when the view loads,
    // so configure its appearance here instead.
    self.navigationController.navigationBar.translucent = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [self.textView setContentOffset:CGPointMake(0, 0)];
    if (self.activeField ) {
        [self.activeField becomeFirstResponder];
        self.tapToStartWritingLabel.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Refresh the UI when the view appears or the options
    // button won't be visible when restoring state.
    [self refreshUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.activeField = nil;
    if ([self.textView isFirstResponder]) {
        self.activeField = self.textView;
    } else if ([self.titleTextField isFirstResponder]) {
        self.activeField = self.titleTextField;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[self stopEditing];

}

#pragma mark - Getters and Setters

- (NSString*)titleText
{
    return self.titleTextField.text;
}

- (void) setTitleText:(NSString*)titleText
{
    [self.titleTextField setText:titleText];
    [self refreshUI];
}

- (NSString*)bodyText
{
    return self.textView.text;
}

- (void) setBodyText:(NSString*)bodyText
{
    [self.textView setText:bodyText];
    [self refreshUI];
}

#pragma mark - View Setup

- (void)setupTextView
{
    CGFloat x = 0.0f;
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat width = viewWidth;
    UIViewAutoresizing mask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    CGRect frame = CGRectMake(x, 0.0f, width, CGRectGetHeight(self.view.frame));

    // Height should never be smaller than what is required to display its text.
    if (!self.textView) {
        self.textView = [[UITextView alloc] initWithFrame:frame];
        self.textView.autoresizingMask = mask;
        self.textView.delegate = self;
        self.textView.font =  self.bodyFont;
        self.textView.textColor = self.bodyColor;
        self.textView.accessibilityLabel = NSLocalizedString(@"Content", @"Post content");
    }
    [self.view addSubview:self.textView];
    
    // Formatting bar for the textView's inputAccessoryView.
    if (self.editorToolbar == nil) {
        self.editorToolbar = [[WPLegacyEditorFormatToolbar alloc] init];
        self.editorToolbar.formatDelegate = self;
        [self.editorToolbar sizeToFit];
        self.textView.inputAccessoryView = self.editorToolbar;
    }
    
    // Title TextField.
    if (!self.titleTextField) {
        CGFloat textWidth = CGRectGetWidth(self.textView.frame) - (2 * WPLegacyEPVCStandardOffset);
        frame = CGRectMake(WPLegacyEPVCStandardOffset, 0.0, textWidth, self.titleFont.lineHeight * 2.0);
        self.titleTextField = [[UITextField alloc] initWithFrame:frame];
        self.titleTextField.frame = frame;
        self.titleTextField.delegate = self;
        self.titleTextField.font = self.titleFont;
        self.titleTextField.textColor = self.titleColor;
        self.titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:(NSLocalizedString(@"Enter title here", @"Label for the title of the post field. Should be the same as WP core.")) attributes:(@{NSForegroundColorAttributeName: self.placeholderColor})];
        self.titleTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.titleTextField.accessibilityLabel = NSLocalizedString(@"Title", @"Post title");
        self.titleTextField.returnKeyType = UIReturnKeyNext;
    }
    [self.textView addSubview:self.titleTextField];
    
    // InputAccessoryView for title textField.
    if (!self.titleToolbar) {
        self.titleToolbar = [[WPLegacyEditorFormatToolbar alloc] init];
        [self.titleToolbar disableAllButtons];
        self.titleToolbar.formatDelegate = self;
        [self.titleToolbar sizeToFit];
        self.titleTextField.inputAccessoryView = self.titleToolbar;
    }
    
    // One pixel separator bewteen title and content text fields.
    if (!self.separatorView) {
        CGFloat y = CGRectGetMaxY(self.titleTextField.frame);
        CGFloat separatorWidth = width - (WPLegacyEPVCStandardOffset * 2.0);
        frame = CGRectMake(WPLegacyEPVCStandardOffset, y, separatorWidth, 1.0);
        self.separatorView = [[UIView alloc] initWithFrame:frame];
        self.separatorView.backgroundColor = self.separatorColor;
        self.separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    [self.textView addSubview:self.separatorView];
    
    // Update the textView's textContainerInsets so text does not overlap content.
    CGFloat left = WPLegacyEPVCTextViewOffset;
    CGFloat right = WPLegacyEPVCTextViewOffset;
    CGFloat top = CGRectGetMaxY(self.separatorView.frame) + self.textView.font.lineHeight;
    CGFloat bottom = self.textView.font.lineHeight;
    self.textView.textContainerInset = UIEdgeInsetsMake(top, left, bottom, right);

    if (!self.tapToStartWritingLabel) {
        frame = CGRectZero;
        frame.origin.x = WPLegacyEPVCStandardOffset;
        frame.origin.y = self.textView.textContainerInset.top;
        frame.size.width = width - (WPLegacyEPVCStandardOffset * 2);
        frame.size.height = self.bodyFont.lineHeight;
        self.tapToStartWritingLabel = [[UILabel alloc] initWithFrame:frame];
        self.tapToStartWritingLabel.text = NSLocalizedString(@"Tap here to begin writing", @"Placeholder for the main body text. Should hint at tapping to enter text (not specifying body text).");
        self.tapToStartWritingLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.tapToStartWritingLabel.font = self.bodyFont;
        self.tapToStartWritingLabel.textColor = self.placeholderColor;
        self.tapToStartWritingLabel.isAccessibilityElement = NO;
    }
    [self.textView addSubview:self.tapToStartWritingLabel];
}

- (void)positionTextView:(NSNotification *)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect originalKeyboardFrame = [[keyboardInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:[self.view.window convertRect:originalKeyboardFrame fromWindow:nil]
                                         fromView:nil];
    CGRect frame = self.textView.frame;
    
    if (self.isShowingKeyboard) {
        frame.size.height = CGRectGetMinY(keyboardFrame) - CGRectGetMinY(frame);
    } else {
        frame.size.height = CGRectGetHeight(self.view.frame);
    }
    self.textView.frame = frame;
}

#pragma mark - Actions

- (void)didTouchSettings
{
    if ([self.delegate respondsToSelector: @selector(editorDidPressSettings:)]) {
        [self.delegate editorDidPressSettings:self];
    }
}

- (void)didTouchPreview
{
    if ([self.delegate respondsToSelector: @selector(editorDidPressPreview:)]) {
        [self.delegate editorDidPressPreview:self];
    }
}

- (void)didTouchMediaOptions
{
    if ([self.delegate respondsToSelector: @selector(editorDidPressMedia:)]) {
        [self.delegate editorDidPressMedia:self];
    }
}

#pragma mark - Editor and Misc Methods

- (void)startEditing
{
    [self.textView becomeFirstResponder];
}

- (void)stopEditing
{
    // With the titleTextField as a subview of textField, we need to resign and
    // end editing to prevent the textField from becoming first responder.
    if ([self.titleTextField isFirstResponder]) {
        [self.titleTextField resignFirstResponder];
    }
    [self.view endEditing:YES];
}

- (void)refreshUI
{
    if(!self.bodyText || self.bodyText.length == 0) {
        self.tapToStartWritingLabel.hidden = NO;
        self.textView.text = @"";
    } else {
        self.tapToStartWritingLabel.hidden = YES;
    }
}

- (void)showLinkView
{
    __weak __typeof(self)weakSelf = self;
    NSRange range = self.textView.selectedRange;
    [self.textView resignFirstResponder];
    
    NSString *infoText = nil;
    if (range.length > 0) {
        infoText = [self.textView.text substringWithRange:range];
    }
    self.scrollOffsetRestorePoint = self.textView.contentOffset;
    
    NSString *alertViewTitle = NSLocalizedString(@"Add a Link", @"Title of the Link Helper popup to aid in creating a Link in the Post Editor.");
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    alertViewTitle = [alertViewTitle stringByTrimmingCharactersInSet:charSet];
    
    NSString *insertButtonTitle = NSLocalizedString(@"Insert", @"Insert content (link, media) button");
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", @"Cancel button");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertViewTitle
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Link URL", @"Popup to aid in creating a Link in the Post Editor, URL field (where you can type or paste a URL that the text should link.");
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.keyboardAppearance = UIKeyboardAppearanceAlert;
        textField.keyboardType = UIKeyboardTypeURL;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        [textField addTarget:weakSelf
                      action:@selector(alertTextFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.secureTextEntry = NO;
        textField.placeholder = NSLocalizedString(@"Text to be linked", @"Popup to aid in creating a Link in the Post Editor.");
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.keyboardAppearance = UIKeyboardAppearanceAlert;
        textField.keyboardType = UIKeyboardTypeDefault;
        
        if (infoText) {
            textField.text = infoText;
        }
    }];
    
    UIAlertAction* insertAction = [UIAlertAction actionWithTitle:insertButtonTitle
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             // Insert link
                                                             UITextField *urlField = alertController.textFields.firstObject;
                                                             UITextField *infoText = alertController.textFields.lastObject;
                                                             
                                                             if ((urlField.text == nil) || ([urlField.text isEqualToString:@""])) {
                                                                 return;
                                                             }
                                                             
                                                             if ((infoText.text == nil) || ([infoText.text isEqualToString:@""])) {
                                                                 infoText.text = urlField.text;
                                                             }
                                                             
                                                             [weakSelf.textView becomeFirstResponder];
                                                             weakSelf.textView.selectedRange = range;
                                                             
                                                             NSString *urlString = [weakSelf validateNewLinkInfo:[urlField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                                                             NSString *aTagText = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", urlString, infoText.text];
                                                             
                                                             [weakSelf.textView insertText:aTagText];
                                                             [weakSelf textViewDidChange:weakSelf.textView];
                                                         }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];
    
    [alertController addAction:insertAction];
    [alertController addAction:cancelAction];
    
    // Disabled until url is entered into field
    insertAction.enabled = NO;
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

// Appends http:// if protocol part is not there as part of urlText.
- (NSString *)validateNewLinkInfo:(NSString *)urlText
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[\\w]+:" options:0 error:&error];
    
    if ([regex numberOfMatchesInString:urlText options:0 range:NSMakeRange(0, [urlText length])] > 0) {
        return urlText;
    } else if([urlText hasPrefix:@"#"]) {
        // link to named anchor
        return urlText;
    } else {
        return [NSString stringWithFormat:@"http://%@", urlText];
    }
}

- (UIImage *)imageNamed:(NSString *)imageName {
    NSBundle* editorBundle = [NSBundle bundleForClass:[self class]];
    return [UIImage imageNamed:imageName inBundle:editorBundle compatibleWithTraitCollection:nil];
}

#pragma mark - Formatting

- (void)wrapSelectionWithTag:(NSString *)tag
{
    NSRange range = self.textView.selectedRange;
    NSString *selection = [self.textView.text substringWithRange:range];
    NSString *prefix, *suffix;
    if ([tag isEqualToString:@"more"]) {
        prefix = @"<!--more-->";
        suffix = @"\n";
    } else if ([tag isEqualToString:@"blockquote"]) {
        prefix = [NSString stringWithFormat:@"\n<%@>", tag];
        suffix = [NSString stringWithFormat:@"</%@>\n", tag];
    } else {
        prefix = [NSString stringWithFormat:@"<%@>", tag];
        suffix = [NSString stringWithFormat:@"</%@>", tag];
    }
    
    NSString *replacement = [NSString stringWithFormat:@"%@%@%@",prefix,selection,suffix];
    [self.textView insertText:replacement];
    [self textViewDidChange:self.textView];
}

#pragma mark - WPKeyboardToolbar Delegate

- (void)formatToolbar:(WPLegacyEditorFormatToolbar *)formatToolbar actionPressed:(WPLegacyEditorFormatAction)formatAction
{
    switch (formatAction) {
        case WPLegacyEditorFormatActionBold:
            [WPAnalytics track:WPAnalyticsStatEditorTappedBold];
            break;
        case WPLegacyEditorFormatActionItalic:
            [WPAnalytics track:WPAnalyticsStatEditorTappedItalic];
            break;
        case WPLegacyEditorFormatActionUnderline:
            [WPAnalytics track:WPAnalyticsStatEditorTappedUnderline];
            break;
        case WPLegacyEditorFormatActionDelete:
            [WPAnalytics track:WPAnalyticsStatEditorTappedStrikethrough];
            break;
        case WPLegacyEditorFormatActionLink:
            [WPAnalytics track:WPAnalyticsStatEditorTappedLink];
            break;
        case WPLegacyEditorFormatActionQuote:
            [WPAnalytics track:WPAnalyticsStatEditorTappedBlockquote];
            break;
        case WPLegacyEditorFormatActionMore:
            [WPAnalytics track:WPAnalyticsStatEditorTappedMore];
            break;
        case WPLegacyEditorFormatActionMedia:
            [WPAnalytics track:WPAnalyticsStatEditorTappedImage];
            break;

    }

    if (formatAction == WPLegacyEditorFormatActionMedia) {
        [self didTouchMediaOptions];
    } else if (formatAction == WPLegacyEditorFormatActionLink) {
        [self showLinkView];
    } else {
        [self wrapSelectionWithTag:WPLegacyEditorFormatActionToTag(formatAction)];
        [self.textView.undoManager setActionName:WPLegacyEditorFormatActionToTag(formatAction)];
    }
}

#pragma mark - TextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector: @selector(editorShouldBeginEditing:)]) {
        return [self.delegate editorShouldBeginEditing:self];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.tapToStartWritingLabel.hidden = YES;
}

- (void)textViewDidChange:(UITextView *)aTextView
{
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)aTextView
{
    if ([self.textView.text isEqualToString:@""]) {
        self.tapToStartWritingLabel.hidden = NO;
    }
}

#pragma mark - TextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector: @selector(editorShouldBeginEditing:)]) {
        return [self.delegate editorShouldBeginEditing:self];
    }
    return YES;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textView becomeFirstResponder];
    return NO;
}

#pragma mark - Size management

- (void)recoverFromViewSizeChange
{
    if ([self.titleTextField isFirstResponder]) {
        [self.titleTextField resignFirstResponder];
        [self.titleTextField becomeFirstResponder];
    }
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
        [self.textView becomeFirstResponder];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *) previousTraitCollection
{
    [super traitCollectionDidChange: previousTraitCollection];
    [self recoverFromViewSizeChange];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self recoverFromViewSizeChange];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self.editorToolbar configureForHorizontalSizeClass:newCollection.horizontalSizeClass];
    [self.titleToolbar configureForHorizontalSizeClass:newCollection.horizontalSizeClass];
}

#pragma mark - Keyboard management

- (void)keyboardWillShow:(NSNotification *)notification
{
	self.isShowingKeyboard = YES;
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    if ([self.textView isFirstResponder]) {
        if (!CGPointEqualToPoint(CGPointZero, self.scrollOffsetRestorePoint)) {
            self.textView.contentOffset = self.scrollOffsetRestorePoint;
            self.scrollOffsetRestorePoint = CGPointZero;
        }
    }
    [self positionTextView:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	self.isShowingKeyboard = NO;
    [self positionTextView:notification];
}

@end
