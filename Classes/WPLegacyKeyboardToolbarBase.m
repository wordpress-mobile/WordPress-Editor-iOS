#import "WPLegacyKeyboardToolbarBase.h"
#import <WordPressShared/WPStyleGuide.h>

@interface WPLegacyKeyboardToolbarBase()

@property (nonatomic, strong) WPLegacyKeyboardToolbarButtonItem *mediaButton;
@property (nonatomic, strong) WPLegacyKeyboardToolbarButtonItem *boldButton;
@property (nonatomic, strong) WPLegacyKeyboardToolbarButtonItem *italicsButton;
@property (nonatomic, strong) WPLegacyKeyboardToolbarButtonItem *underlineButton;
@property (nonatomic, strong) WPLegacyKeyboardToolbarButtonItem *delButton;
@property (nonatomic, strong) WPLegacyKeyboardToolbarButtonItem *linkButton;
@property (nonatomic, strong) WPLegacyKeyboardToolbarButtonItem *quoteButton;
@property (nonatomic, strong) WPLegacyKeyboardToolbarButtonItem *moreButton;

@end

@implementation WPLegacyKeyboardToolbarBase

- (void)buttonAction:(WPLegacyKeyboardToolbarButtonItem *)sender {
    DDLogInfo(@"%@ %@", self, NSStringFromSelector(_cmd));
    if (self.delegate) {
        [self.delegate keyboardToolbarButtonItemPressed:sender];
    }
}

- (void)buildFormatButtons {
    CGFloat x = 0.0f;
    UIColor *highlightColor = [UIColor whiteColor];
    if (self.mediaButton == nil) {
        self.mediaButton = [[WPLegacyKeyboardToolbarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
        [self.mediaButton setImageName:@"icon_format_media"];
        self.mediaButton.actionTag = @"add_media";
        self.mediaButton.accessibilityIdentifier = @"add media";
        self.mediaButton.actionName = NSLocalizedString(@"add media", @"Add media in the Post Editor. This string will be used in the Undo message if the last change was adding formatting.");
        self.mediaButton.accessibilityLabel = NSLocalizedString(@"add media", nil);
    }
    if (self.boldButton == nil) {
        self.boldButton = [[WPLegacyKeyboardToolbarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
        [self.boldButton setImageName:@"icon_format_bold"];
        self.boldButton.actionTag = @"strong";
        self.boldButton.accessibilityIdentifier = @"strong";
        self.boldButton.actionName = NSLocalizedString(@"bold", @"Bold text formatting in the Post Editor. This string will be used in the Undo message if the last change was adding formatting.");
        self.boldButton.accessibilityLabel = NSLocalizedString(@"bold", nil);
    }
    if (self.italicsButton == nil) {
        self.italicsButton = [[WPLegacyKeyboardToolbarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
        [self.italicsButton setImageName:@"icon_format_italic"];
        self.italicsButton.actionTag = @"em";
        self.italicsButton.accessibilityIdentifier = @"em";
        self.italicsButton.actionName = NSLocalizedString(@"italic", @"Italic text formatting in the Post Editor. This string will be used in the Undo message if the last change was adding formatting.");
        self.italicsButton.accessibilityLabel = NSLocalizedString(@"italic", nil);
    }
    if (self.underlineButton == nil) {
        self.underlineButton = [[WPLegacyKeyboardToolbarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
        [self.underlineButton setImageName:@"icon_format_underline"];
        self.underlineButton.actionTag = @"u";
        self.underlineButton.accessibilityIdentifier = @"u";
        self.underlineButton.actionName = NSLocalizedString(@"underline", @"Underline text formatting in the Post Editor. This string will be used in the Undo message if the last change was adding formatting.");
        self.underlineButton.accessibilityLabel = NSLocalizedString(@"underline", nil);        
    }
    if (self.delButton == nil) {
        self.delButton = [[WPLegacyKeyboardToolbarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
        [self.delButton setImageName:@"icon_format_strikethrough"];
        self.delButton.actionTag = @"del";
        self.delButton.accessibilityIdentifier = @"del";
        self.delButton.actionName = NSLocalizedString(@"del", @"<del> (deleted text) HTML formatting in the Post Editor. This string will be used in the Undo message if the last change was adding a <del> HTML element.");
        self.delButton.accessibilityLabel = NSLocalizedString(@"delete", nil);
    }
    if (self.linkButton == nil) {
        self.linkButton = [[WPLegacyKeyboardToolbarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
        [self.linkButton setImageName:@"icon_format_link"];
        self.linkButton.actionTag = @"link";
        self.linkButton.accessibilityIdentifier = @"link";
        self.linkButton.actionName = NSLocalizedString(@"link", @"Link helper button in the Post Editor. This string will be used in the Undo message if the last change was adding a link.");
        self.linkButton.accessibilityLabel = NSLocalizedString(@"link", nil);
    }
    if (self.quoteButton == nil) {
        self.quoteButton = [[WPLegacyKeyboardToolbarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
        [self.quoteButton setImageName:@"icon_format_quote"];
        self.quoteButton.actionTag = @"blockquote";
        self.quoteButton.accessibilityIdentifier = @"blockquote";
        self.quoteButton.actionName = NSLocalizedString(@"quote", @"Blockquote HTML formatting in the Post Editor. This string will be used in the Undo message if the last change was adding a blockquote.");
        self.quoteButton.accessibilityLabel = NSLocalizedString(@"quote", nil);
    }
    if (self.moreButton == nil) {
        self.moreButton = [[WPLegacyKeyboardToolbarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
        [self.moreButton setImageName:@"icon_format_more"];        
        self.moreButton.actionTag = @"more";
        self.moreButton.accessibilityIdentifier = @"more";
        self.moreButton.actionName = NSLocalizedString(@"more", @"Adding a More excerpt cut-off in the Post Editor. This string will be used in the Undo message if the last change was adding this formatting.");
        self.moreButton.accessibilityLabel = NSLocalizedString(@"more", nil);
    }
}

- (void)setupFormatView {
    [self buildFormatButtons];

    self.items = @[
                   [self flexibleSpaceItem],
                   self.mediaButton,
                   [self flexibleSpaceItem],
                   self.boldButton,
                   [self fixedSpaceItem],
                   self.italicsButton,
                   [self fixedSpaceItem],
                   self.underlineButton,
                   [self fixedSpaceItem],
                   self.delButton,
                   [self flexibleSpaceItem],
                   self.linkButton,
                   [self fixedSpaceItem],
                   self.quoteButton,
                   [self fixedSpaceItem],
                   self.moreButton,
                   [self flexibleSpaceItem]
                   ];
}

- (UIBarButtonItem *)flexibleSpaceItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (UIBarButtonItem *)fixedSpaceItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item.width = item.width / 2.0f;
    return item;
}

- (void)setupView {
    [self setupFormatView];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)disableAllButtons {
    for (UIBarButtonItem *button in self.items) {
        button.enabled = NO;
    }
}

#pragma mark - UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

@end
