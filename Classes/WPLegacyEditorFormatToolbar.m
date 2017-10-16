#import "WPLegacyEditorFormatToolbar.h"
#import "WPLegacyEditorFormatAction.h"

@interface WPLegacyEditorFormatToolbar()

@property (nonatomic, strong) UIBarButtonItem *mediaButton;
@property (nonatomic, strong) UIBarButtonItem *boldButton;
@property (nonatomic, strong) UIBarButtonItem *italicsButton;
@property (nonatomic, strong) UIBarButtonItem *underlineButton;
@property (nonatomic, strong) UIBarButtonItem *delButton;
@property (nonatomic, strong) UIBarButtonItem *linkButton;
@property (nonatomic, strong) UIBarButtonItem *quoteButton;
@property (nonatomic, strong) UIBarButtonItem *moreButton;

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

- (void)layoutSubviews {
    [super layoutSubviews];
    // HACK: Sergio Estevao (2017-10-10): Change the size of the items whe running on a device with a width smaller or equal than 320 (iPhone SE)
    if (self.frame.size.width <= 320) {
        for (UIBarButtonItem *item in self.items) {
            item.width = roundf(item.image.size.width * 0.75);
        }
    }
}

- (void)setupToolbar {
    [self configureForHorizontalSizeClass:UIUserInterfaceSizeClassCompact];
}

- (void)configureForHorizontalSizeClass:(UIUserInterfaceSizeClass)sizeClass
{
    if (sizeClass == UIUserInterfaceSizeClassCompact) {
        self.items = @[

                       [self flexibleSpaceItem],
                       self.mediaButton,
                       [self flexibleSpaceItem],
                       self.boldButton,
                       [self flexibleSpaceItem],
                       self.italicsButton,
                       [self flexibleSpaceItem],
                       self.underlineButton,
                       [self flexibleSpaceItem],
                       self.delButton,
                       [self flexibleSpaceItem],
                       self.linkButton,
                       [self flexibleSpaceItem],
                       self.quoteButton,
                       [self flexibleSpaceItem],
                       self.moreButton,
                       [self flexibleSpaceItem]
                       ];    }

    if (sizeClass == UIUserInterfaceSizeClassRegular) {
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
}

- (UIBarButtonItem *)createButtonWithImageNamed:(NSString *)imageNamed tag:(WPLegacyEditorFormatAction)action
{
    UIImage *image = [self imageNamed:imageNamed];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [button setImage:image forState:UIControlStateNormal];
    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = action;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    barButton.width = image.size.width;
    barButton.image = image;
    return barButton;
}

- (UIBarButtonItem *)mediaButton {
    if (_mediaButton == nil) {
        _mediaButton = [self createButtonWithImageNamed:@"icon_format_media" tag:WPLegacyEditorFormatActionMedia];
        _mediaButton.accessibilityIdentifier = @"add media";
        _mediaButton.accessibilityLabel = NSLocalizedString(@"add media", nil);
    }
    return _mediaButton;
}

- (UIBarButtonItem *)boldButton {
    if (_boldButton == nil) {
        _boldButton = [self createButtonWithImageNamed:@"icon_format_bold" tag:WPLegacyEditorFormatActionBold];
        _boldButton.accessibilityIdentifier = @"strong";
        _boldButton.accessibilityLabel = NSLocalizedString(@"bold", nil);
    }
    return _boldButton;
}

- (UIBarButtonItem *)italicsButton {
    if (_italicsButton == nil) {
        _italicsButton = [self createButtonWithImageNamed:@"icon_format_italic" tag:WPLegacyEditorFormatActionItalic];
        _italicsButton.accessibilityIdentifier = @"em";
        _italicsButton.accessibilityLabel = NSLocalizedString(@"italic", nil);
    }
    return _italicsButton;
}

- (UIBarButtonItem *)underlineButton {
    if (_underlineButton == nil) {
        _underlineButton = [self createButtonWithImageNamed:@"icon_format_underline" tag:WPLegacyEditorFormatActionUnderline];
        _underlineButton.accessibilityIdentifier = @"u";
        _underlineButton.accessibilityLabel = NSLocalizedString(@"underline", nil);
    }
    return _underlineButton;
}

- (UIBarButtonItem *)delButton {
    if (_delButton == nil) {
        _delButton = [self createButtonWithImageNamed:@"icon_format_strikethrough" tag:WPLegacyEditorFormatActionDelete];
        _delButton.accessibilityIdentifier = @"del";
        _delButton.accessibilityLabel = NSLocalizedString(@"delete", nil);
    }
    return _delButton;
}

- (UIBarButtonItem *)linkButton {
    if (_linkButton == nil) {
        _linkButton = [self createButtonWithImageNamed:@"icon_format_link" tag:WPLegacyEditorFormatActionLink];
        _linkButton.accessibilityIdentifier = @"link";
        _linkButton.accessibilityLabel = NSLocalizedString(@"link", nil);
    }
    return _linkButton;
}

- (UIBarButtonItem *)quoteButton {
    if (_quoteButton == nil) {
        _quoteButton =[self createButtonWithImageNamed:@"icon_format_quote" tag:WPLegacyEditorFormatActionQuote];
        _quoteButton.accessibilityIdentifier = @"blockquote";
        _quoteButton.accessibilityLabel = NSLocalizedString(@"quote", nil);
    }
    return _quoteButton;
}

- (UIBarButtonItem *)moreButton {
    if (_moreButton == nil) {
        _moreButton = [self createButtonWithImageNamed:@"icon_format_more" tag:WPLegacyEditorFormatActionMore];
        _moreButton.accessibilityIdentifier = @"more";
        _moreButton.accessibilityLabel = NSLocalizedString(@"more", nil);
    }
    return _moreButton;
}

- (UIBarButtonItem *)flexibleSpaceItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (UIBarButtonItem *)fixedSpaceItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    return item;
}

- (void)disableAllButtons {
    for (UIBarButtonItem *button in self.items) {
        button.enabled = NO;
    }
}

- (void)buttonAction:(UIButton *)sender {
    DDLogInfo(@"%@ %@", self, NSStringFromSelector(_cmd));
    if (self.formatDelegate) {
        [self.formatDelegate formatToolbar:self actionPressed:sender.tag];
    }
}

- (UIImage *)imageNamed:(NSString *)imageName {
    NSBundle* editorBundle = [NSBundle bundleForClass:[self class]];
    return [[UIImage imageNamed:imageName inBundle:editorBundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

#pragma mark - UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

@end
