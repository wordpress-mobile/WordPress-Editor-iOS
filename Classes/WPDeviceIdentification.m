//
//  WPDeviceIdentification.m
//  Pods
//
//  Created by Diego E. Rey Mendez on 11/12/14.
//
//

#import "WPDeviceIdentification.h"

@implementation WPDeviceIdentification

+ (BOOL)isIPhoneSixPlus
{
    return IS_IPHONE && ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)] && [[UIScreen mainScreen] nativeScale] > 2.5f);
}

@end
