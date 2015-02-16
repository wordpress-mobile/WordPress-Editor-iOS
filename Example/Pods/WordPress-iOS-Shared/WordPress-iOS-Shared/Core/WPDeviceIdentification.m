#import "WPDeviceIdentification.h"

static NSString* const WPDeviceModelNameiPhone6 = @"iPhone 6";
static NSString* const WPDeviceModelNameiPhone6Plus = @"iPhone 6 Plus";
static NSString* const WPDeviceModelNameiPadSimulator = @"iPad Simulator";
static NSString* const WPDeviceModelNameiPhoneSimulator = @"iPhone Simulator";

@implementation WPDeviceIdentification

#pragma mark - Device identification

+ (BOOL)isiPhoneSix
{
    return (IS_IPHONE
            && [[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]
            && [[UIScreen mainScreen] nativeScale] == 2
            && [UIScreen mainScreen].bounds.size.height == 568);
}

+ (BOOL)isiPhoneSixPlus
{
    return (IS_IPHONE
            && [[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]
            && [[UIScreen mainScreen] nativeScale] > 2.5
            && [UIScreen mainScreen].bounds.size.height == 568);
}

+ (BOOL)isiOSVersionEarlierThan8
{
    return [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0;
}

@end
