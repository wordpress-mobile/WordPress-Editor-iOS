#import <UIKit/UIKit.h>



/**
 *  @enum   WPTableViewSectionStyle
 *  @brief  The WPTableViewSectionHeaderFooterView helper class has two default styles: Header and Footer.
 *          By means of this simple enum, we'll be able to initialize the HeaderFooterView with the
 *          standard styles that should be applied when using this tool as a Header, or a Footer.
 */

typedef NS_ENUM(NSInteger, WPTableViewSectionStyle)
{
    WPTableViewSectionStyleHeader,
    WPTableViewSectionStyleFooter
};



/**
 *  @class  WPTableViewSectionHeaderFooterView
 *  @brief  This class is meant to be used as TableView Section Footer, and provides a custom style that
 *          should be used app-wide.
 */

@interface WPTableViewSectionHeaderFooterView : UITableViewHeaderFooterView

@property (nonatomic, assign, readonly) WPTableViewSectionStyle style;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSAttributedString *attributedTitle;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, assign) NSTextAlignment titleAlignment;
@property (nonatomic, assign) UIEdgeInsets titleInsets;
@property (nonatomic, assign) BOOL uppercase;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier style:(WPTableViewSectionStyle)style;


/**
 *  @brief      Calculates the Height required to display a View with the default Header Styles.
 *
 *  @param      headerText  The text to be rendered.
 *  @param      width       The container's width.
 *  @returns                Required Height
 */

+ (CGFloat)heightForHeader:(NSString *)headerText width:(CGFloat)width;


/**
 *  @brief      Calculates the Height required to display a View with the default Footer Styles.
 *
 *  @param      headerText  The text to be rendered.
 *  @param      width       The container's width.
 *  @returns                Required Height
 */

+ (CGFloat)heightForFooter:(NSString *)footerText width:(CGFloat)width;


/**
 *  @brief      Calculates the Height required to display a View with a custom Font and Title Insets.
 *
 *  @param      text        The text to be rendered.
 *  @param      width       The container's width.
 *  @param      font        The font that should be used.
 *  @returns                Required Height
 */

+ (CGFloat)heightForText:(NSString *)text width:(CGFloat)width titleInsets:(UIEdgeInsets)titleInsets font:(UIFont *)font;

@end
