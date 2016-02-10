#import <UIKit/UIKit.h>

@class WPTextFieldTableViewCell;
@interface WPStyleGuide : NSObject

// Fonts
+ (UIFont *)largePostTitleFont;
+ (NSDictionary *)largePostTitleAttributes;
+ (UIFont *)postTitleFont;
+ (UIFont *)postTitleFontBold;
+ (NSDictionary *)postTitleAttributes;
+ (NSDictionary *)postTitleAttributesBold;
+ (UIFont *)subtitleFont;
+ (NSDictionary *)subtitleAttributes;
+ (UIFont *)subtitleFontItalic;
+ (NSDictionary *)subtitleItalicAttributes;
+ (UIFont *)subtitleFontBold;
+ (NSDictionary *)subtitleAttributesBold;
+ (UIFont *)labelFont;
+ (UIFont *)labelFontNormal;
+ (NSDictionary *)labelAttributes;
+ (UIFont *)regularTextFont;
+ (UIFont *)regularTextFontSemiBold;
+ (UIFont *)regularTextFontBold;
+ (NSDictionary *)regularTextAttributes;
+ (UIFont *)tableviewTextFont;
+ (UIFont *)tableviewSubtitleFont;
+ (UIFont *)tableviewSectionHeaderFont;

// Color
+ (UIColor *)wordPressBlue;
+ (UIColor *)lightBlue;
+ (UIColor *)mediumBlue;
+ (UIColor *)darkBlue;
+ (UIColor *)grey;
+ (UIColor *)lightGrey;
+ (UIColor *)greyLighten30;
+ (UIColor *)greyLighten20;
+ (UIColor *)greyLighten10;
+ (UIColor *)greyDarken10;
+ (UIColor *)greyDarken20;
+ (UIColor *)greyDarken30;
+ (UIColor *)darkGrey;
+ (UIColor *)jazzyOrange;
+ (UIColor *)fireOrange;
+ (UIColor *)validGreen;
+ (UIColor *)warningYellow;
+ (UIColor *)errorRed;
+ (UIColor *)alertYellowDark;
+ (UIColor *)alertYellowLighter;
+ (UIColor *)alertRedDarker;

// Misc
+ (UIColor *)keyboardColor;
+ (UIColor *)textFieldPlaceholderGrey;
+ (UIColor *)tableViewActionColor;

// Bar Button Styles
+ (UIBarButtonItemStyle)barButtonStyleForDone;
+ (UIBarButtonItemStyle)barButtonStyleForBordered;
+ (void)setLeftBarButtonItemWithCorrectSpacing:(UIBarButtonItem *)barButtonItem forNavigationItem:(UINavigationItem *)navigationItem;
+ (void)setRightBarButtonItemWithCorrectSpacing:(UIBarButtonItem *)barButtonItem forNavigationItem:(UINavigationItem *)navigationItem;

// View and TableView Helpers
+ (void)configureColorsForView:(UIView *)view andTableView:(UITableView *)tableView;
+ (void)configureColorsForView:(UIView *)view collectionView:(UICollectionView *)collectionView;
+ (void)configureTableViewCell:(UITableViewCell *)cell;
+ (void)configureTableViewSmallSubtitleCell:(UITableViewCell *)cell;
+ (void)configureTableViewActionCell:(UITableViewCell *)cell;
+ (void)configureTableViewDestructiveActionCell:(UITableViewCell *)cell;
+ (void)configureTableViewTextCell:(WPTextFieldTableViewCell *)cell;
+ (void)configureTableViewSectionHeader:(UIView *)header;
+ (void)configureTableViewSectionFooter:(UIView *)footer;

// Move to a feature category
+ (UIColor *)buttonActionColor;
+ (UIColor *)nuxFormText;
+ (UIColor *)nuxFormPlaceholderText;
+ (void)configureFollowButton:(UIButton *)followButton;

// Deprecated Colors
+ (UIColor *)baseLighterBlue;
+ (UIColor *)baseDarkerBlue;
+ (UIColor *)newKidOnTheBlockBlue;
+ (UIColor *)midnightBlue;
+ (UIColor *)bigEddieGrey;
+ (UIColor *)littleEddieGrey;
+ (UIColor *)whisperGrey;
+ (UIColor *)allTAllShadeGrey;
+ (UIColor *)readGrey;
+ (UIColor *)itsEverywhereGrey;
+ (UIColor *)darkAsNightGrey;
+ (UIColor *)validationErrorRed;

@end
