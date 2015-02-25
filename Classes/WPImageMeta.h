#import <Foundation/Foundation.h>

@interface WPImageMeta : NSObject

@property (nonatomic, copy) NSString *align;
@property (nonatomic, copy) NSString *alt;
@property (nonatomic, copy) NSString *attachmentId;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSString *captionClassName;
@property (nonatomic, readonly) NSString *captionId;
@property (nonatomic, copy) NSString *classes;
@property (nonatomic, copy) NSString *height;
@property (nonatomic, copy) NSString *linkClassName;
@property (nonatomic, copy) NSString *linkRel;
@property (nonatomic) BOOL linkTargetBlank;
@property (nonatomic, copy) NSString *linkURL;
@property (nonatomic, copy) NSString *size;
@property (nonatomic, copy) NSString *src;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *width;
@property (nonatomic, copy) NSString *naturalWidth;
@property (nonatomic, copy) NSString *naturalHeight;

/**
 Creates a WPImageMeta instance, populated with values from the passed JSON string.

 @param str A JSON formatted object string. Keys are any of the "MetaKey" consts.
 Values should be strings, or a string boolean (true, false) in the case of linkTargetBlank.

 @return WPImageMeta object
 */
+ (instancetype)imageMetaFromJSONString:(NSString *)str;

/**
 The WPImageMeta instance as a JSON formatted object string. 

 @return A JSON formatted string
 */
- (NSString *)jsonStringRepresentation;

@end
