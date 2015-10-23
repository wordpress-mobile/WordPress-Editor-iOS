#import "WPFontManager.h"
#import <CoreText/CoreText.h>

@implementation WPFontManager

static NSString * const SharedBundle = @"WordPress-iOS-Shared.bundle";
static NSString * const FontTypeTTF = @"ttf";
static NSString * const FontTypeOTF = @"otf";

#pragma mark - Open Sans Fonts

+ (UIFont *)openSansLightFontOfSize:(CGFloat)size
{
    NSString *resourceName = @"OpenSans-Light";
    NSString *fontName = @"OpenSans-Light";
    return [self fontNamed:fontName resourceName:resourceName fontType:FontTypeTTF size:size];
}

+ (UIFont *)openSansItalicFontOfSize:(CGFloat)size
{
    NSString *resourceName = @"OpenSans-Italic";
    NSString *fontName = @"OpenSans-Italic";
    return [self fontNamed:fontName resourceName:resourceName fontType:FontTypeTTF size:size];
}

+ (UIFont *)openSansLightItalicFontOfSize:(CGFloat)size
{
    NSString *resourceName = @"OpenSans-LightItalic";
    NSString *fontName = @"OpenSans-LightItalic";
    return [self fontNamed:fontName resourceName:resourceName fontType:FontTypeTTF size:size];
}

+ (UIFont *)openSansBoldFontOfSize:(CGFloat)size
{
    NSString *resourceName = @"OpenSans-Bold";
    NSString *fontName = @"OpenSans-Bold";
    return [self fontNamed:fontName resourceName:resourceName fontType:FontTypeTTF size:size];
}

+ (UIFont *)openSansBoldItalicFontOfSize:(CGFloat)size
{
    NSString *resourceName = @"OpenSans-BoldItalic";
    NSString *fontName = @"OpenSans-BoldItalic";
    return [self fontNamed:fontName resourceName:resourceName fontType:FontTypeTTF size:size];
}

+ (UIFont *)openSansSemiBoldFontOfSize:(CGFloat)size
{
    NSString *resourceName = @"OpenSans-Semibold";
    NSString *fontName = @"OpenSans-Semibold";
    return [self fontNamed:fontName resourceName:resourceName fontType:FontTypeTTF size:size];
}

+ (UIFont *)openSansSemiBoldItalicFontOfSize:(CGFloat)size
{
    NSString *resourceName = @"OpenSans-SemiboldItalic";
    NSString *fontName = @"OpenSans-SemiboldItalic";
    return [self fontNamed:fontName resourceName:resourceName fontType:FontTypeTTF size:size];
}

+ (UIFont *)openSansRegularFontOfSize:(CGFloat)size
{
    NSString *resourceName = @"OpenSans-Regular";
    NSString *fontName = @"OpenSans";
    return [self fontNamed:fontName resourceName:resourceName fontType:FontTypeTTF size:size];
}


#pragma mark - Merryweather Fonts

+ (UIFont *)merriweatherBoldFontOfSize:(CGFloat)size
{
    NSString *resourceName = @"Merriweather-Bold";
    NSString *fontName = @"Merriweather-Bold";
    return [self fontNamed:fontName resourceName:resourceName fontType:FontTypeTTF size:size];
}

+ (UIFont *)merriweatherBoldItalicFontOfSize:(CGFloat)size;
{
    NSString *resourceName = @"Merriweather-BoldItalic";
    NSString *fontName = @"Merriweather-BoldItalic";
    return [self fontNamed:fontName resourceName:resourceName fontType:FontTypeTTF size:size];
}

+ (UIFont *)merriweatherItalicFontOfSize:(CGFloat)size;
{
    NSString *resourceName = @"Merriweather-Italic";
    NSString *fontName = @"Merriweather-Italic";
    return [self fontNamed:fontName resourceName:resourceName fontType:FontTypeTTF size:size];
}

+ (UIFont *)merriweatherLightFontOfSize:(CGFloat)size;
{
    NSString *resourceName = @"Merriweather-Light";
    NSString *fontName = @"Merriweather-Light";
    return [self fontNamed:fontName resourceName:resourceName fontType:FontTypeTTF size:size];
}

+ (UIFont *)merriweatherLightItalicFontOfSize:(CGFloat)size
{
    NSString *resourceName = @"Merriweather-LightItalic";
    NSString *fontName = @"Merriweather-LightItalic";
    return [self fontNamed:fontName resourceName:resourceName fontType:FontTypeTTF size:size];
}

+ (UIFont *)merriweatherRegularFontOfSize:(CGFloat)size
{
    NSString *resourceName = @"Merriweather-Regular";
    NSString *fontName = @"Merriweather";
    return [self fontNamed:fontName resourceName:resourceName fontType:FontTypeTTF size:size];
}


#pragma mark - Private Methods

+ (UIFont *)fontNamed:(NSString *)fontName resourceName:(NSString *)resourceName fontType:(NSString *)fontType size:(CGFloat)size
{
    UIFont *font = [UIFont fontWithName:fontName size:size];
    if (!font) {
        [[self class] dynamicallyLoadFontResourceNamed:resourceName withExtension:fontType];
        font = [UIFont fontWithName:fontName size:size];

        // safe fallback
        if (!font) {
            font = [UIFont systemFontOfSize:size];
        }
    }

    return font;
}

+ (void)dynamicallyLoadFontResourceNamed:(NSString *)name withExtension:(NSString *)extension
{
    NSString *resourceName = [NSString stringWithFormat:@"%@/%@", SharedBundle, name];
    NSURL *url = [[NSBundle bundleForClass:self] URLForResource:resourceName withExtension:extension];
    NSData *fontData = [NSData dataWithContentsOfURL:url];
    
    if (fontData) {
        CFErrorRef error;
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)fontData);
        CGFontRef font = CGFontCreateWithDataProvider(provider);
        if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
            CFStringRef errorDescription = CFErrorCopyDescription(error);
            DDLogError(@"Failed to load font: %@", errorDescription);
            CFRelease(errorDescription);
        }
        CFRelease(font);
        CFRelease(provider);
    }
}

@end
