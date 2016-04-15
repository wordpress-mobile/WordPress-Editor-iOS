#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  @class      WPDeviceIdentification
 *  @brief      Methods for device and iOS identification should go here.
 */
@interface WPDeviceIdentification : NSObject

/**
 *  @brief      Call this method to know if the current device is an iPhone.
 *
 *  @returns    YES if the device is an iPhone.  NO otherwise.
 */
+ (BOOL)isiPhone;

/**
 *  @brief      Call this method to know if the current device is an iPad.
 *
 *  @returns    YES if the device is an iPad.  NO otherwise.
 */
+ (BOOL)isiPad;

/**
 *  @brief      Call this method to know if the current device has a retina screen.
 *
 *  @returns    YES if the device has a retina screen.  NO otherwise.
 */
+ (BOOL)isRetina;

/**
 *  @brief      Call this method to know if the current device is an iPhone6.
 *
 *  @returns    YES if the device is an iPhone6.  NO otherwise.
 */
+ (BOOL)isiPhoneSix;

/**
 *  @brief      Call this method to know if the current device is an iPhone6+.
 *
 *  @returns    YES if the device is an iPhone6+.  NO otherwise.
 */
+ (BOOL)isiPhoneSixPlus;

/**
 *  @brief      Call this method to know if the current device is running iOS version older than 8.
 *
 *  @returns    YES if the device is running iOS version older than 8.  NO otherwise.
 */
+ (BOOL)isiOSVersionEarlierThan8;

@end
