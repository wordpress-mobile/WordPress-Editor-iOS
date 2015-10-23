#import "WPTableViewSectionHeaderFooterView.h"
#import "WPTableViewCell.h"
#import "WPStyleGuide.h"
#import "NSString+Util.h"



@interface WPTableViewSectionHeaderFooterView ()
@property (nonatomic, strong) UILabel *titleLabel;
@end


@implementation WPTableViewSectionHeaderFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithReuseIdentifier:reuseIdentifier style:WPTableViewSectionStyleHeader];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier style:(WPTableViewSectionStyle)style
{
    NSParameterAssert(style == WPTableViewSectionStyleHeader || style == WPTableViewSectionStyleFooter);
    
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        _style = style;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    BOOL isHeader = self.style == WPTableViewSectionStyleHeader;
    
    UIEdgeInsets titleInsets = isHeader ? [[self class] headerTitleInsets] : [[self class] footerTitleInsets];
    UIColor *titleColor = isHeader ? [[self class] headerTitleColor]  : [[self class] footerTitleColor];
    UIFont *titleFont = isHeader ? [[self class] headerTitleFont]   : [[self class] footerTitleFont];
    
    // Title Label
    UILabel *titleLabel = [UILabel new];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.font = titleFont;
    titleLabel.textColor = titleColor;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.shadowOffset = CGSizeZero;
    [self addSubview:titleLabel];
    
    // Background
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [UIColor clearColor];
    
    // Initialize Prperties
    _uppercase = isHeader;
    _titleLabel = titleLabel;
    _titleInsets = titleInsets;
    self.backgroundView = backgroundView;
    
    // Make sure this view is laid ut
    [self setNeedsLayout];
}



#pragma mark - Overriden Properties

/**
    Note:
    The purpose of the following overrides are to prevent UI glitches, caused by users accessing the
    default textLabel and detailTextLabel provided by the superclass.
    We're effectively disabling those fields!
 */

- (UILabel *)textLabel
{
    return nil;
}

- (UILabel *)detailTextLabel
{
    return nil;
}



#pragma mark - Properties

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = self.uppercase ? [title uppercaseStringWithLocale:[NSLocale currentLocale]] : title;
    [self setNeedsLayout];
}

- (UIColor *)titleColor
{
    return self.titleLabel.textColor;
}

- (void)setTitleColor:(UIColor *)color
{
    self.titleLabel.textColor = color;
}

- (UIFont *)titleFont
{
    return self.titleLabel.font;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    self.titleLabel.font = titleFont;
    [self setNeedsLayout];
}

- (void)setTitleAlignment:(NSTextAlignment)textAlignment
{
    self.titleLabel.textAlignment = textAlignment;
}

- (NSTextAlignment)titleAlignment
{
    return self.titleLabel.textAlignment;
}

- (void)setTitleInsets:(UIEdgeInsets)titleInsets
{
    _titleInsets = titleInsets;
    [self setNeedsLayout];
}

- (void)setUppercase:(BOOL)uppercase
{
    _uppercase = uppercase;
    [self setNeedsLayout];
}



#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat sectionWidth    = CGRectGetWidth(self.bounds);
    CGFloat titleWidth      = [[self class] titleLabelWidthFromSectionWidth:sectionWidth titleInsets:self.titleInsets];
    CGSize titleSize        = [[self class] sizeForTitle:self.titleLabel.text titleWidth:titleWidth font:self.titleFont];
    CGFloat padding         = (sectionWidth - titleWidth) * 0.5;

    self.titleLabel.frame   = CGRectIntegral(CGRectMake(padding, self.titleInsets.top, titleWidth, titleSize.height));
}



#pragma mark - Public Static Helpers

+ (CGFloat)heightForHeader:(NSString *)headerText width:(CGFloat)width
{
    return [self heightForText:headerText width:width titleInsets:[self headerTitleInsets] font:[self headerTitleFont]];
}

+ (CGFloat)heightForFooter:(NSString *)footerText width:(CGFloat)width
{
    return [self heightForText:footerText width:width titleInsets:[self footerTitleInsets] font:[self footerTitleFont]];
}

+ (CGFloat)heightForText:(NSString *)text width:(CGFloat)width titleInsets:(UIEdgeInsets)titleInsets font:(UIFont *)font
{
    if (text.length == 0) {
        return 0.0;
    }

    CGFloat titleWidth  = [self titleLabelWidthFromSectionWidth:width titleInsets:titleInsets];
    CGSize titleSize    = [self sizeForTitle:text titleWidth:titleWidth font:font];
    
    return titleSize.height + titleInsets.top + titleInsets.bottom;
}



#pragma mark - Private Methods

+ (CGSize)sizeForTitle:(NSString *)title titleWidth:(CGFloat)titleWidth font:(UIFont *)font
{
    return [title suggestedSizeWithFont:font width:titleWidth];
}

+ (CGFloat)titleLabelWidthFromSectionWidth:(CGFloat)sectionWidth titleInsets:(UIEdgeInsets)titleInsets
{
    CGFloat fixedWidth      = self.fixedWidth;
    CGFloat titleLabelWidth = (fixedWidth > 0) ? MIN(fixedWidth, sectionWidth) : sectionWidth;

    return titleLabelWidth - titleInsets.left - titleInsets.right;
}

+ (CGFloat)fixedWidth
{
    return IS_IPAD ? WPTableViewFixedWidth : 0.0;
}


#pragma mark - Defaults

+ (UIEdgeInsets)headerTitleInsets
{
    return UIEdgeInsetsMake(21.0, 16.0, 8.0, 16.0);
}

+ (UIEdgeInsets)footerTitleInsets
{
    return UIEdgeInsetsMake(6.0,  16.0, 24.0, 16.0);
}

+ (UIColor *)headerTitleColor
{
    return [WPStyleGuide whisperGrey];
}

+ (UIColor *)footerTitleColor
{
    return [WPStyleGuide greyDarken10];
}

+ (UIFont *)headerTitleFont
{
    return [WPStyleGuide tableviewSectionHeaderFont];
}

+ (UIFont *)footerTitleFont
{
    return [WPStyleGuide subtitleFont];
}

@end
