#import "WPLegacyEditorFormatToolbar.h"
#import <WordPressShared/WPStyleGuide.h>

@interface WPLegacyEditorFormatToolbar()

@property (nonatomic, strong) WPLegacyKeyboardToolbarButtonItem *mediaButton;
@property (nonatomic, strong) WPLegacyKeyboardToolbarButtonItem *boldButton;
@property (nonatomic, strong) WPLegacyKeyboardToolbarButtonItem *italicsButton;
@property (nonatomic, strong) WPLegacyKeyboardToolbarButtonItem *underlineButton;
@property (nonatomic, strong) WPLegacyKeyboardToolbarButtonItem *delButton;
@property (nonatomic, strong) WPLegacyKeyboardToolbarButtonItem *linkButton;
@property (nonatomic, strong) WPLegacyKeyboardToolbarButtonItem *quoteButton;
@property (nonatomic, strong) WPLegacyKeyboardToolbarButtonItem *moreButton;

@end

@implementation WPLegacyEditorFormatToolbar

- (id)init {
    self = [super init];
    if (self) {
        [self setupToolbar];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupToolbar];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupToolbar];
    }
    return self;
}

- (void)setupToolbar {
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

- (UIBarButtonItem *)mediaButton {
    if (_mediaButton == nil) {
        _mediaButton = [[WPLegacyKeyboardToolbarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
        [_mediaButton setImageName:@"icon_format_media"];
        _mediaButton.actionTag = @"add_media";
        _mediaButton.accessibilityIdentifier = @"add media";
        _mediaButton.actionName = NSLocalizedString(@"add media", @"Add media in the Post Editor. This string will be used in the Undo message if the last change was adding formatting.");
        _mediaButton.accessibilityLabel = NSLocalizedString(@"add media", nil);
    }
    return _mediaButton;
}

- (UIBarButtonItem *)boldButton {
    if (_boldButton == nil) {
        _boldButton = [[WPLegacyKeyboardToolbarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
        [_boldButton setImageName:@"icon_format_bold"];
        _boldButton.actionTag = @"strong";
        _boldButton.accessibilityIdentifier = @"strong";
        _boldButton.actionName = NSLocalizedString(@"bold", @"Bold text formatting in the Post Editor. This string will be used in the Undo message if the last change was adding formatting.");
        _boldButton.accessibilityLabel = NSLocalizedString(@"bold", nil);
    }
    return _boldButton;
}

- (UIBarButtonItem *)italicsButton {
    if (_italicsButton == nil) {
        _italicsButton = [[WPLegacyKeyboardToolbarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
        [_italicsButton setImageName:@"icon_format_italic"];
        _italicsButton.actionTag = @"em";
        _italicsButton.accessibilityIdentifier = @"em";
        _italicsButton.actionName = NSLocalizedString(@"italic", @"Italic text formatting in the Post Editor. This string will be used in the Undo message if the last change was adding formatting.");
        _italicsButton.accessibilityLabel = NSLocalizedString(@"italic", nil);
    }
    return _italicsButton;
}

- (UIBarButtonItem *)underlineButton {
    if (_underlineButton == nil) {
        _underlineButton = [[WPLegacyKeyboardToolbarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
        [_underlineButton setImageName:@"icon_format_underline"];
        _underlineButton.actionTag = @"u";
        _underlineButton.accessibilityIdentifier = @"u";
        _underlineButton.actionName = NSLocalizedString(@"underline", @"Underline text formatting in the Post Editor. This string will be used in the Undo message if the last change was adding formatting.");
        _underlineButton.accessibilityLabel = NSLocalizedString(@"underline", nil);        
    }
    return _underlineButton;
}

- (UIBarButtonItem *)delButton {
    if (_delButton == nil) {
        _delButton = [[WPLegacyKeyboardToolbarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
        [_delButton setImageName:@"icon_format_strikethrough"];
        _delButton.actionTag = @"del";
        _delButton.accessibilityIdentifier = @"del";
        _delButton.actionName = NSLocalizedString(@"del", @"<del> (deleted text) HTML formatting in the Post Editor. This string will be used in the Undo message if the last change was adding a <del> HTML element.");
        _delButton.accessibilityLabel = NSLocalizedString(@"delete", nil);
    }
    return _delButton;
}

- (UIBarButtonItem *)linkButton {
    if (_linkButton == nil) {
        _linkButton = [[WPLegacyKeyboardToolbarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
        [_linkButton setImageName:@"icon_format_link"];
        _linkButton.actionTag = @"link";
        _linkButton.accessibilityIdentifier = @"link";
        _linkButton.actionName = NSLocalizedString(@"link", @"Link helper button in the Post Editor. This string will be used in the Undo message if the last change was adding a link.");
        _linkButton.accessibilityLabel = NSLocalizedString(@"link", nil);
    }
    return _linkButton;
}

- (UIBarButtonItem *)quoteButton {
    if (_quoteButton == nil) {
        _quoteButton = [[WPLegacyKeyboardToolbarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
        [_quoteButton setImageName:@"icon_format_quote"];
        _quoteButton.actionTag = @"blockquote";
        _quoteButton.accessibilityIdentifier = @"blockquote";
        _quoteButton.actionName = NSLocalizedString(@"quote", @"Blockquote HTML formatting in the Post Editor. This string will be used in the Undo message if the last change was adding a blockquote.");
        _quoteButton.accessibilityLabel = NSLocalizedString(@"quote", nil);
    }
    return _quoteButton;
}

- (UIBarButtonItem *)moreButton {
    if (_moreButton == nil) {
        _moreButton = [[WPLegacyKeyboardToolbarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
        [_moreButton setImageName:@"icon_format_more"];        
        _moreButton.actionTag = @"more";
        _moreButton.accessibilityIdentifier = @"more";
        _moreButton.actionName = NSLocalizedString(@"more", @"Adding a More excerpt cut-off in the Post Editor. This string will be used in the Undo message if the last change was adding this formatting.");
        _moreButton.accessibilityLabel = NSLocalizedString(@"more", nil);
    }
    return _moreButton;
}

- (UIBarButtonItem *)flexibleSpaceItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (UIBarButtonItem *)fixedSpaceItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item.width = -15.0f;
    return item;
}

- (void)disableAllButtons {
    for (UIBarButtonItem *button in self.items) {
        button.enabled = NO;
    }
}

- (void)buttonAction:(WPLegacyKeyboardToolbarButtonItem *)sender {
    DDLogInfo(@"%@ %@", self, NSStringFromSelector(_cmd));
    if (self.formatDelegate) {
        [self.formatDelegate keyboardToolbarButtonItemPressed:sender];
    }
}

#pragma mark - UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

@end
