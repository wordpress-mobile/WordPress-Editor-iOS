//
//  WPDeviceIdentification.h
//  Pods
//
//  Created by Diego E. Rey Mendez on 11/12/14.
//
//

#import <Foundation/Foundation.h>

/**
 *  @class      WPDeviceIdentification
 *  @brief      Methods for device identification should go here.
 *  @todo       We should really move this class to WordPress-iOS-Shared at some point.  Not doing
 *              it right now because I think it's best to go for a step-by-step approach by first
 *              separating this method from the rest of the code.
 */
@interface WPDeviceIdentification : NSObject

/**
 *  @brief      Call this method to know if the current device is an iPhone6+.
 *
 *  @returns    YES if the device is an iPhone6+.  NO otherwise.
 */
+ (BOOL)isIPhoneSixPlus;

@end
