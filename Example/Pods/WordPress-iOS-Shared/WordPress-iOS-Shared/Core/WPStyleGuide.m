#import "WPStyleGuide.h"
#import "WPTextFieldTableViewCell.h"
#import "UIColor+Helpers.h"
#import "WPFontManager.h"

@implementation WPStyleGuide

#pragma mark - Fonts and Text

+ (UIFont *)largePostTitleFont
{
    return [WPFontManager openSansLightFontOfSize:32.0];
}

+ (NSDictionary *)largePostTitleAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 35;
    paragraphStyle.maximumLineHeight = 35;
    return @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName : [self largePostTitleFont]};
}

+ (UIFont *)postTitleFont
{
    return [WPFontManager openSansRegularFontOfSize:16.0];
}

+ (UIFont *)postTitleFontBold
{
    return [WPFontManager openSansBoldFontOfSize:16.0];
}

+ (NSDictionary *)postTitleAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 19;
    paragraphStyle.maximumLineHeight = 19;
    return @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName : [self postTitleFont]};
}

+ (NSDictionary *)postTitleAttributesBold {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 19;
    paragraphStyle.maximumLineHeight = 19;
    return @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName : [self postTitleFontBold]};
}

+ (UIFont *)subtitleFont
{
    return [WPFontManager openSansRegularFontOfSize:12.0];
}

+ (NSDictionary *)subtitleAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 14;
    paragraphStyle.maximumLineHeight = 14;
    return @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName : [self subtitleFont]};
}

+ (UIFont *)subtitleFontItalic
{
    return [WPFontManager openSansItalicFontOfSize:12.0];
}

+ (NSDictionary *)subtitleItalicAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 14;
    paragraphStyle.maximumLineHeight = 14;
    return @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName : [self subtitleFontItalic]};
}

+ (UIFont *)subtitleFontBold
{
    return [WPFontManager openSansBoldFontOfSize:12.0];
}

+ (NSDictionary *)subtitleAttributesBold
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 14;
    paragraphStyle.maximumLineHeight = 14;
    return @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName : [self subtitleFontBold]};
}

+ (UIFont *)labelFont
{
    return [WPFontManager openSansBoldFontOfSize:10.0];
}

+ (UIFont *)labelFontNormal
{
    return [WPFontManager openSansRegularFontOfSize:10.0];
}

+ (NSDictionary *)labelAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 12;
    paragraphStyle.maximumLineHeight = 12;
    return @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName : [self labelFont]};
}

+ (UIFont *)regularTextFont
{
    return [WPFontManager openSansRegularFontOfSize:16.0];
}

+ (UIFont *)regularTextFontSemiBold
{
    return [WPFontManager openSansSemiBoldFontOfSize:16.0];
}

+ (UIFont *)regularTextFontBold
{
    return [WPFontManager openSansBoldFontOfSize:16.0];
}

+ (NSDictionary *)regularTextAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 24;
    paragraphStyle.maximumLineHeight = 24;
    return @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName : [self regularTextFont]};
}

+ (UIFont *)tableviewTextFont
{
    return [WPFontManager openSansRegularFontOfSize:17.0];
}

+ (UIFont *)tableviewSubtitleFont
{
    return [WPFontManager openSansRegularFontOfSize:17.0];
}

+ (UIFont *)tableviewSectionHeaderFont
{
    return [WPFontManager openSansRegularFontOfSize:13.0];
}


#pragma mark - Colors
// https://wordpress.com/design-handbook/colors/

+ (UIColor *)colorWithR:(NSInteger)red G:(NSInteger)green B:(NSInteger)blue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:(CGFloat)red/255.0 green:(CGFloat)green/255.0 blue:(CGFloat)blue/255.0 alpha:alpha];
}


#pragma mark - Blues

+ (UIColor *)wordPressBlue
{
    return [self colorWithR:0 G:135 B:190 alpha:1.0];
}

+ (UIColor *)lightBlue
{
    return [self colorWithR:120 G:220 B:250 alpha:1.0];
}

+ (UIColor *)mediumBlue
{
    return [self colorWithR:0 G:170 B:220 alpha:1.0];
}

+ (UIColor *)darkBlue
{
    return [self colorWithR:0 G:80 B:130 alpha:1.0];
}


#pragma mark - Greys

+ (UIColor *)grey
{
    return [self colorWithR:135 G:166 B:188 alpha:1.0];
}

+ (UIColor *)lightGrey
{
    return [self colorWithR:243 G:246 B:248 alpha:1.0];
}

+ (UIColor *)greyLighten30
{
    return [self colorWithR:233 G:239 B:243 alpha:1.0];
}

+ (UIColor *)greyLighten20
{
    return [self colorWithR:200 G:215 B:225 alpha:1.0];
}

+ (UIColor *)greyLighten10
{
    return [self colorWithR:168 G:190 B:206 alpha:1.0];
}

+ (UIColor *)greyDarken10
{
    return [self colorWithR:102 G:142 B:170 alpha:1.0];
}

+ (UIColor *)greyDarken20
{
    return [self colorWithR:79 G:116 B:142 alpha:1.0];
}

+ (UIColor *)greyDarken30
{
    return [self colorWithR:61 G:89 B:109 alpha:1.0];
}

+ (UIColor *)darkGrey
{
    return [self colorWithR:46 G:68 B:83 alpha:1.0];
}


#pragma mark - Oranges

+ (UIColor *)jazzyOrange
{
    return [self colorWithR:240 G:130 B:30 alpha:1.0];
}

+ (UIColor *)fireOrange
{
    return [self colorWithR:213 G:78 B:33 alpha:1.0];
}


#pragma mark - Validations / Alerts

+ (UIColor *)validGreen
{
    return [self colorWithR:74 G:184 B:102 alpha:1.0];
}

+ (UIColor *)warningYellow
{
    return [self colorWithR:240 G:184 B:73 alpha:1.0];
}

+ (UIColor *)errorRed
{
    return [self colorWithR:217 G:79 B:79 alpha:1.0];
}

+ (UIColor *)alertYellowDark
{
    return [self colorWithR:0xF0 G:0xB8 B:0x49 alpha:0xFF];
}

+ (UIColor *)alertYellowLighter
{
    return [self colorWithR:0xFE G:0xF8 B:0xEE alpha:0xFF];
}

+ (UIColor *)alertRedDarker
{
    return [self colorWithR:0x6D G:0x18 B:0x18 alpha:0xFF];
}


#pragma mark - Misc Colors

+ (UIColor *)keyboardColor {
    // Pre iOS 7.1 uses a the lighter keyboard background.
    // There doesn't seem to be a good way to get the keyboard background color
    // programatically so we'll rely on checking the OS version.
    // Approach based on http://stackoverflow.com/a/5337804
    NSString *versionStr = [[UIDevice currentDevice] systemVersion];
    BOOL hasLighterKeyboard = [versionStr compare:@"7.1" options:NSNumericSearch] == NSOrderedAscending;

    if (hasLighterKeyboard) {
        if (IS_IPAD) {
            return [UIColor colorWithRed:207.0f/255.0f green:210.0f/255.0f blue:213.0f/255.0f alpha:1.0];
        } else {
            return [UIColor colorWithRed:220.0f/255.0f green:223.0f/255.0f blue:226.0f/255.0f alpha:1.0];
        }
    }

    if (IS_IPAD) {
        return [UIColor colorWithRed:217.0f/255.0f green:220.0f/255.0f blue:223.0f/255.0f alpha:1.0];
    } else {
        return [UIColor colorWithRed:204.0f/255.0f green:208.0f/255.0f blue:214.0f/255.0f alpha:1.0];
    }
}

+ (UIColor *)textFieldPlaceholderGrey
{
    return [self grey];
}

+ (UIColor *)tableViewActionColor
{
    return [self wordPressBlue];
}

// TODO: Move to feature category
+ (UIColor *)buttonActionColor
{
    return [self wordPressBlue];
}

// TODO: Move to feature category
+ (UIColor *)nuxFormText {
    return [self darkGrey];
}

// TODO: Move to feature category
+ (UIColor *)nuxFormPlaceholderText {
    return [self grey];
}


#pragma mark - Bar styles

+ (UIBarButtonItemStyle)barButtonStyleForDone
{
    return UIBarButtonItemStylePlain;
}

+ (UIBarButtonItemStyle)barButtonStyleForBordered
{
    return UIBarButtonItemStylePlain;
}

+ (void)setLeftBarButtonItemWithCorrectSpacing:(UIBarButtonItem *)barButtonItem forNavigationItem:(UINavigationItem *)navigationItem
{
    navigationItem.leftBarButtonItems = @[[self spacerForNavigationBarButtonItems], barButtonItem];
}

+ (void)setRightBarButtonItemWithCorrectSpacing:(UIBarButtonItem *)barButtonItem forNavigationItem:(UINavigationItem *)navigationItem
{
    navigationItem.rightBarButtonItems = @[[self spacerForNavigationBarButtonItems], barButtonItem];
}

+ (UIBarButtonItem *)spacerForNavigationBarButtonItems
{
    UIBarButtonItem *spacerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacerButton.width = -16.0;
    return spacerButton;
}


#pragma mark - View and TableView Styles

+ (void)configureColorsForView:(UIView *)view andTableView:(UITableView *)tableView
{
    tableView.backgroundView = nil;
    view.backgroundColor = [WPStyleGuide greyLighten30];
    tableView.backgroundColor = [WPStyleGuide greyLighten30];
    tableView.separatorColor = [WPStyleGuide greyLighten20];
}

+ (void)configureColorsForView:(UIView *)view collectionView:(UICollectionView *)collectionView
{
    collectionView.backgroundView = nil;
    collectionView.backgroundColor = [WPStyleGuide greyLighten30];
    view.backgroundColor = [WPStyleGuide greyLighten30];
}

+ (void)configureTableViewCell:(UITableViewCell *)cell
{
    cell.textLabel.font = [self tableviewTextFont];
    [cell.textLabel sizeToFit];

    cell.detailTextLabel.font = [self tableviewSubtitleFont];
    [cell.detailTextLabel sizeToFit];
    
    cell.textLabel.textColor = [self darkGrey];
    cell.detailTextLabel.textColor = [self grey];
}

+ (void)configureTableViewSmallSubtitleCell:(UITableViewCell *)cell
{
    [self configureTableViewCell:cell];
    cell.detailTextLabel.font = [self subtitleFont];
    cell.detailTextLabel.textColor = [self darkGrey];
}

+ (void)configureTableViewActionCell:(UITableViewCell *)cell
{
    [self configureTableViewCell:cell];
    cell.textLabel.font = [self tableviewTextFont];
    cell.textLabel.textColor = [self tableViewActionColor];
}

+ (void)configureTableViewDestructiveActionCell:(UITableViewCell *)cell
{
    [self configureTableViewActionCell:cell];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [self errorRed];
}

+ (void)configureTableViewTextCell:(WPTextFieldTableViewCell *)cell
{
    [self configureTableViewCell:cell];
    cell.textField.font = [self tableviewSubtitleFont];
    
    if (cell.textField.enabled) {
        cell.textField.textColor = [self darkBlue];
        cell.textField.textAlignment = NSTextAlignmentLeft;
    } else {
        cell.textField.textColor = [self grey];
        cell.textField.textAlignment = NSTextAlignmentRight;
    }
}

+ (void)configureTableViewSectionHeader:(UITableViewHeaderFooterView *)header
{
    if (![header isKindOfClass:[UITableViewHeaderFooterView class]]) {
        return;
    }
    header.textLabel.font = [self tableviewSectionHeaderFont];
    header.textLabel.textColor = [self whisperGrey];
}

+ (void)configureTableViewSectionFooter:(UITableViewHeaderFooterView *)footer
{
    if (![footer isKindOfClass:[UITableViewHeaderFooterView class]]) {
        return;
    }
    footer.textLabel.font = [self subtitleFont];
    footer.textLabel.textColor = [self greyDarken10];
}

// TODO: Move to fetaure category
+ (void)configureFollowButton:(UIButton *)followButton {
    followButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    followButton.backgroundColor = [UIColor clearColor];
    followButton.titleLabel.font = [WPStyleGuide subtitleFont];
    NSString *followString = NSLocalizedString(@"Follow", @"Prompt to follow a blog.");
    NSString *followedString = NSLocalizedString(@"Following", @"User is following the blog.");
    [followButton setTitle:followString forState:UIControlStateNormal];
    [followButton setTitle:followedString forState:UIControlStateSelected];
    [followButton setImage:[UIImage imageNamed:@"reader-postaction-follow"] forState:UIControlStateNormal];
    [followButton setImage:[UIImage imageNamed:@"reader-postaction-following"] forState:UIControlStateSelected];
    [followButton setTitleColor:[self allTAllShadeGrey] forState:UIControlStateNormal];
}


#pragma mark - Deprecated Colors

+ (UIColor *)baseLighterBlue __deprecated
{
    return [self wordPressBlue];
}

+ (UIColor *)baseDarkerBlue __deprecated
{
    return [self wordPressBlue];
}

+ (UIColor *)newKidOnTheBlockBlue __deprecated
{
    return [self mediumBlue];
}

+ (UIColor *)midnightBlue __deprecated
{
    return [self darkBlue];
}

+ (UIColor *)bigEddieGrey __deprecated
{
    return [self darkGrey];
}

+ (UIColor *)littleEddieGrey __deprecated
{
    return [self darkGrey];
}

+ (UIColor *)whisperGrey __deprecated
{
    return [self greyDarken20];
}

+ (UIColor *)allTAllShadeGrey __deprecated
{
    return [self grey];
}

+ (UIColor *)readGrey __deprecated
{
    return [self greyLighten20];
}

+ (UIColor *)itsEverywhereGrey __deprecated
{
    return [self greyLighten30];
}

+ (UIColor *)darkAsNightGrey __deprecated
{
    return [self darkBlue];
}

+ (UIColor *)validationErrorRed __deprecated
{
    return [self errorRed];
}

@end
