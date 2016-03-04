#import <UIKit/UIKit.h>

@interface WPFontManager : NSObject

+ (UIFont *)openSansLightFontOfSize:(CGFloat)size __deprecated_msg("Use systemLightFontOfSize instead");
+ (UIFont *)openSansItalicFontOfSize:(CGFloat)size __deprecated_msg("Use systemItalicFontOfSize instead");
+ (UIFont *)openSansLightItalicFontOfSize:(CGFloat)size __deprecated_msg("Use systemLightItalicFontOfSize instead");
+ (UIFont *)openSansBoldFontOfSize:(CGFloat)size __deprecated_msg("Use systemBoldFontOfSize instead");
+ (UIFont *)openSansBoldItalicFontOfSize:(CGFloat)size __deprecated_msg("Use systemBoldItalicFontOfSize instead");
+ (UIFont *)openSansSemiBoldFontOfSize:(CGFloat)size __deprecated_msg("Use systemSemiBoldFontOfSize instead");
+ (UIFont *)openSansSemiBoldItalicFontOfSize:(CGFloat)size __deprecated_msg("Use systemSemiBoldItalicFontOfSize instead");
+ (UIFont *)openSansRegularFontOfSize:(CGFloat)size __deprecated_msg("Use systemRegularFontOfSize instead");

+ (UIFont *)systemLightFontOfSize:(CGFloat)size;
+ (UIFont *)systemItalicFontOfSize:(CGFloat)size;
+ (UIFont *)systemBoldFontOfSize:(CGFloat)size;
+ (UIFont *)systemSemiBoldFontOfSize:(CGFloat)size;
+ (UIFont *)systemRegularFontOfSize:(CGFloat)size;

+ (UIFont *)merriweatherBoldFontOfSize:(CGFloat)size;
+ (UIFont *)merriweatherBoldItalicFontOfSize:(CGFloat)size;
+ (UIFont *)merriweatherItalicFontOfSize:(CGFloat)size;
+ (UIFont *)merriweatherLightFontOfSize:(CGFloat)size;
+ (UIFont *)merriweatherLightItalicFontOfSize:(CGFloat)size;
+ (UIFont *)merriweatherRegularFontOfSize:(CGFloat)size;

@end
