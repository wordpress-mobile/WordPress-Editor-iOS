#import <UIKit/UIKit.h>

@interface WPFontManager : NSObject

+ (UIFont *)openSansLightFontOfSize:(CGFloat)size;
+ (UIFont *)openSansItalicFontOfSize:(CGFloat)size;
+ (UIFont *)openSansLightItalicFontOfSize:(CGFloat)size;
+ (UIFont *)openSansBoldFontOfSize:(CGFloat)size;
+ (UIFont *)openSansBoldItalicFontOfSize:(CGFloat)size;
+ (UIFont *)openSansSemiBoldFontOfSize:(CGFloat)size;
+ (UIFont *)openSansSemiBoldItalicFontOfSize:(CGFloat)size;
+ (UIFont *)openSansRegularFontOfSize:(CGFloat)size;

+ (UIFont *)merriweatherBoldFontOfSize:(CGFloat)size;

@end
