#import "WPTableViewSectionHeaderView.h"
#import "WPTableViewCell.h"
#import "WPStyleGuide.h"
#import "NSString+Util.h"

@interface WPTableViewSectionHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

CGFloat const WPTableViewSectionHeaderViewStandardOffset = 16.0;
CGFloat const WPTableViewSectionHeaderViewTopVerticalPadding = 21.0;
CGFloat const WPTableViewSectionHeaderViewBottomVerticalPadding = 8.0;

@implementation WPTableViewSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.font = [WPStyleGuide tableviewSectionHeaderFont];
        _titleLabel.textColor = [WPStyleGuide whisperGrey];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.shadowOffset = CGSizeMake(0.0, 0.0);
        [self addSubview:_titleLabel];

        // fixed width should be enabled by default
        _fixedWidthEnabled = YES;
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = [title uppercaseStringWithLocale:[NSLocale currentLocale]];
    self.titleLabel.text = _title;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat sectionWidth = CGRectGetWidth(self.bounds);
    CGFloat titleWidth = [[self class] titleLabelWidthFromSectionWidth:sectionWidth fixedWidthEnabled:self.fixedWidthEnabled];
    CGSize titleSize = [[self class] sizeForTitle:self.titleLabel.text andTitleWidth:titleWidth];
    CGFloat padding = (sectionWidth - titleWidth) / 2.0;

    self.titleLabel.frame = CGRectIntegral(CGRectMake(padding, WPTableViewSectionHeaderViewTopVerticalPadding, titleWidth, titleSize.height));
}

// fixedWidth is enabled by default
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
    return [self sizeForTitle:title andTitleWidth:titleWidth].height + WPTableViewSectionHeaderViewTopVerticalPadding + WPTableViewSectionHeaderViewBottomVerticalPadding;
}

#pragma mark - Private Methods

+ (CGSize)sizeForTitle:(NSString *)title andTitleWidth:(CGFloat)titleWidth
{
    // since we use uppercase title by default, it's important to override it here in case
    // this method is called with a lowercase string which would cause a difference in the height calculation
    NSString *upppercaseTitle = [title uppercaseStringWithLocale:[NSLocale currentLocale]];
    return [upppercaseTitle suggestedSizeWithFont:[WPStyleGuide tableviewSectionHeaderFont] width:titleWidth];
}

+ (CGFloat)titleLabelWidthFromSectionWidth:(CGFloat)sectionWidth fixedWidthEnabled:(BOOL)fixedWidthEnabled
{
    CGFloat titleLabelWidth = sectionWidth;
    CGFloat fixedWidth = [[self class] fixedWidth];
    if (fixedWidthEnabled && fixedWidth > 0) {
        titleLabelWidth = MIN(fixedWidth, titleLabelWidth);
    }
    return titleLabelWidth - (2 * WPTableViewSectionHeaderViewStandardOffset);
}

+ (CGFloat)fixedWidth
{
    return IS_IPAD ? WPTableViewFixedWidth : 0.0;
}

@end
