#import <UIKit/UIKit.h>

@interface WPTableViewSectionFooterView : UITableViewHeaderFooterView

@property (nonatomic, strong) NSString *title;

// By default, fixedWidth will be enabled, which means for iPads
// the title label width will be <= WPTableViewFixedWidth. There
// will be equal padding before and after the label, if you want the label
// to have a default padding and a full width instead, you can disable the fixedWidth flag.
@property (nonatomic) BOOL fixedWidthEnabled;

// By default, fixedWidth flag will assumed to be enabled and the title label width
// will be treated for <= WPTableViewFixedWidth for iPads.
+ (CGFloat)heightForTitle:(NSString *)title andWidth:(CGFloat)width;

// If you disable the fixedWidth flag for the instance, you should pass `NO` as the
// fixedWidthEnabled parameter, so it will use the full width for the calculation
+ (CGFloat)heightForTitle:(NSString *)title andWidth:(CGFloat)width fixedWidthEnabled:(BOOL)fixedWidthEnabled;

@end
