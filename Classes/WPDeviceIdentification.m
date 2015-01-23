#import "WPDeviceIdentification.h"

@implementation WPDeviceIdentification

+ (BOOL)isIPhoneSixPlus
{
    return IS_IPHONE && ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]
                     && [[UIScreen mainScreen] nativeScale] > 2.5f);
}

+ (BOOL)isIPhoneSix
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone &&
            MAX([UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width) == 667);
}

@end
