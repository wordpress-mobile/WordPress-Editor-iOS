#import "WPTableViewSectionFooterView.h"
#import "WPTableViewCell.h"
#import "WPStyleGuide.h"
#import "NSString+Util.h"

@interface WPTableViewSectionFooterView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

CGFloat const WPTableViewSectionFooterViewStandardOffset        = 16.0;
CGFloat const WPTableViewSectionFooterViewTopVerticalPadding    = 6.0;
CGFloat const WPTableViewSectionFooterViewBottomVerticalPadding = 24.0;

@implementation WPTableViewSectionFooterView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.font = [WPStyleGuide subtitleFont];
        _titleLabel.textColor = [WPStyleGuide greyDarken10];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.shadowOffset = CGSizeZero;
        [self addSubview:_titleLabel];

        // fixed width should be enabled by default
        _fixedWidthEnabled = YES;
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = _title;
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

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat sectionWidth = CGRectGetWidth(self.bounds);
    CGFloat titleWidth = [[self class] titleLabelWidthFromSectionWidth:sectionWidth fixedWidthEnabled:self.fixedWidthEnabled];
    CGSize titleSize = [[self class] sizeForTitle:self.titleLabel.text andTitleWidth:titleWidth];
    CGFloat padding = (sectionWidth - titleWidth) / 2.0;

    self.titleLabel.frame = CGRectIntegral(CGRectMake(padding, WPTableViewSectionFooterViewTopVerticalPadding, titleWidth, titleSize.height));
}

+ (CGFloat)heightForTitle:(NSString *)title andWidth:(CGFloat)width
{
    return [self heightForTitle:title andWidth:width fixedWidthEnabled:YES];
}

+ (CGFloat)heightForTitle:(NSString *)title andWidth:(CGFloat)width fixedWidthEnabled:(BOOL)fixedWidthEnabled
{
    if ([title length] == 0) {
        return 0.0;
    }

    CGFloat titleWidth = [[self class] titleLabelWidthFromSectionWidth:width fixedWidthEnabled:fixedWidthEnabled];
    return [self sizeForTitle:title andTitleWidth:titleWidth].height + WPTableViewSectionFooterViewTopVerticalPadding + WPTableViewSectionFooterViewBottomVerticalPadding;
}

#pragma mark - Private Methods

+ (CGSize)sizeForTitle:(NSString *)title andTitleWidth:(CGFloat)titleWidth
{
    return [title suggestedSizeWithFont:[WPStyleGuide subtitleFont] width:titleWidth];
}

+ (CGFloat)titleLabelWidthFromSectionWidth:(CGFloat)sectionWidth fixedWidthEnabled:(BOOL)fixedWidthEnabled
{
    CGFloat titleLabelWidth = sectionWidth;
    CGFloat fixedWidth = [[self class] fixedWidth];
    if (fixedWidthEnabled && fixedWidth > 0) {
        titleLabelWidth = MIN(fixedWidth, titleLabelWidth);
    }
    return titleLabelWidth - (2 * WPTableViewSectionFooterViewStandardOffset);
}

+ (CGFloat)fixedWidth
{
    return IS_IPAD ? WPTableViewFixedWidth : 0.0;
}

@end
